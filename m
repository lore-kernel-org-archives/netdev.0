From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] tcpdump may trace some outbound packets twice.
Date: Mon, 15 May 2006 23:41:52 +0200
Message-ID: <4468F5A0.3040404@trash.net>
References: <20060514031034.5d0396e7.akpm@osdl.org>	<20060514.134231.101346572.davem@davemloft.net>	<Pine.LNX.4.56.0605151409110.25064@ranjit.corp.google.com> <20060515.142645.94689626.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: ranjitm@google.com, akpm@osdl.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:29655 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S964920AbWEOVlx
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 May 2006 17:41:53 -0400
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20060515.142645.94689626.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> From: Ranjit Manomohan <ranjitm@google.com>
> Date: Mon, 15 May 2006 14:19:06 -0700 (PDT)
> 
> 
>>Heres a new version which does a copy instead of the clone to avoid
>>the double cloning issue.
> 
> 
> I still very much dislike this patch because it is creating
> 1 more clone per packet than is actually necessary and that
> is very expensive.
> 
> dev_queue_xmit_nit() is going to clone whatever SKB you send into
> there, so better to just bump the reference count (with skb_get())
> instead of cloning or copying.


I think this would break the tc actions. Some actions call
pskb_expand_head() on input, which BUGs on skb_shared(skb).
They can't clone the skb instead because the functions
doing that don't own it, the caller would continue with the
old skb.
