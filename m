From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] tcpdump may trace some outbound packets twice.
Date: Mon, 15 May 2006 14:26:45 -0700 (PDT)
Message-ID: <20060515.142645.94689626.davem@davemloft.net>
References: <20060514031034.5d0396e7.akpm@osdl.org>
	<20060514.134231.101346572.davem@davemloft.net>
	<Pine.LNX.4.56.0605151409110.25064@ranjit.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:26061
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S965256AbWEOV1A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 May 2006 17:27:00 -0400
To: ranjitm@google.com
In-Reply-To: <Pine.LNX.4.56.0605151409110.25064@ranjit.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ranjit Manomohan <ranjitm@google.com>
Date: Mon, 15 May 2006 14:19:06 -0700 (PDT)

> Heres a new version which does a copy instead of the clone to avoid
> the double cloning issue.

I still very much dislike this patch because it is creating
1 more clone per packet than is actually necessary and that
is very expensive.

dev_queue_xmit_nit() is going to clone whatever SKB you send into
there, so better to just bump the reference count (with skb_get())
instead of cloning or copying.
