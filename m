From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: add documentation for skb recycling
Date: Mon, 20 Oct 2008 22:17:50 -0700 (PDT)
Message-ID: <20081020.221750.248214690.davem@davemloft.net>
References: <20081020190654.49d4e5d2@extreme>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: buytenh@wantstofly.org, rdunlap@xenotime.net,
	netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55135
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751754AbYJUFSM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Oct 2008 01:18:12 -0400
In-Reply-To: <20081020190654.49d4e5d2@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 20 Oct 2008 19:06:54 -0700

"Randy.Dunlap" needs to be fully quoted when it appears in email
headers otherwise it is a syntax error, as a result this posting
was rejected by vger.kernel.org

> Include description of function from Lennert's original checkin.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

I'll apply this, thanks Stephen.

> As a matter of policy, any exported function should have docbook.

I don't think this is a reasonable black and white rule, sometimes
things are exported so that two subsystems or pieces of code can
communicate (and only those specific pieces of code), in which case
docbook is not all that useful.  Especially if it's an inteface
which might change a lot.

But in this case it is definitely warranted, as this interface is
meant to be used by drivers.

> --- a/net/core/skbuff.c	2008-10-20 16:10:44.000000000 -0700
> +++ b/net/core/skbuff.c	2008-10-20 16:16:01.000000000 -0700
> @@ -449,6 +449,18 @@ void kfree_skb(struct sk_buff *skb)
>  	__kfree_skb(skb);
>  }
>  
> +/**
> + * 	skb_recycle_check - check if skb can be reused for receive
> + *	@skb: buffer
> + * 	@skb_size: minimum receive buffer size
> + *
> + * 	Checks that the skb is not shared or cloned, and that it is
> + * 	linear and its head portion large enough (as determined by
> + * 	the driver) to be recycled as a receive buffer.  If these
> + * 	conditions are met, it does any necessary reference count
> + * 	dropping and cleans up the skbuff as if it just came from
> + * 	__alloc_skb().
> + */
>  int skb_recycle_check(struct sk_buff *skb, int skb_size)
>  {
>  	struct skb_shared_info *shinfo;
