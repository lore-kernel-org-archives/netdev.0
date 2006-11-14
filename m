From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/8] netpoll: skb private pool management
Date: Mon, 13 Nov 2006 17:00:41 -0800 (PST)
Message-ID: <20061113.170041.17866097.davem@davemloft.net>
References: <20061026180402.32c1c511@localhost.localdomain>
	<20061026.180812.34605098.davem@davemloft.net>
	<20061026192934.58c20e2a@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp-2
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:62392
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S933281AbWKNBAc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Nov 2006 20:00:32 -0500
To: shemminger@osdl.org
In-Reply-To: <20061026192934.58c20e2a@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Thu, 26 Oct 2006 19:29:34 -0700

> It was a dark and stormy night when Steve first saw the
> netpoll beast. The beast was odd, and misshapen but not
> extremely ugly.
> 
> "Let me take off one of your warts" he said. This wart
> is where you tried to make an skb list yourself. If the
> beast had ever run out of memory, he would have stupefied
> himself unnecessarily.
> 
> The first try was painful, so he tried again till the bleeding
> stopped.

Maybe spend some time with compile tests instead of the cute
story line? :-)

> -static DEFINE_SPINLOCK(skb_list_lock);
> -static int nr_skbs;
> -static struct sk_buff *skbs;
> +static struct sk_buff_head skb_pool;

skb_pool is a scaler.

> +	spin_lock_irqsave(&skb_pool->lock, flags);

Yet is being accessed as a pointer.

net/core/netpoll.c:191: error: invalid type argument of $,1rx(B->$,1ry(B
