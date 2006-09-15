From: Jon Mason <jdmason@kudzu.us>
Subject: Re: [PATCH] bridge: add ETH_HLEN to packet_length
Date: Thu, 14 Sep 2006 19:31:40 -0500
Message-ID: <20060915003140.GA15650@kudzu.us>
References: <20060914182751.GA15203@kudzu.us> <4509C15C.6080308@kolumbus.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@osdl.org, netdev@vger.kernel.org,
	Dwayne.Shows@3leafnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from proof.pobox.com ([207.106.133.28]:47533 "EHLO proof.pobox.com")
	by vger.kernel.org with ESMTP id S932139AbWIOAae (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Sep 2006 20:30:34 -0400
To: Mika Penttil? <mika.penttila@kolumbus.fi>
Content-Disposition: inline
In-Reply-To: <4509C15C.6080308@kolumbus.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 14, 2006 at 11:53:48PM +0300, Mika Penttil? wrote:
> Jon Mason wrote:
> >In br_dev_queue_push_xmit, why is the check to drop mtu oversized
> >packets not checking for enough room for the impending ETH_HLEN size
> >skb_push?  In some code currently under development, we are seeing
> >skb_under_panic being called from the "skb_push(skb, ETH_HLEN)" in that
> >code.  It seems to me it would be better to drop those skbs than panic.
> >Attached is a patch to do this.
> >
> >Thanks,
> >Jon
> >
> >Signed-off-by: Jon Mason <jdmason@kudzu.us>
> >
> >diff -r b1d36669f98d net/bridge/br_forward.c
> >--- a/net/bridge/br_forward.c	Mon Sep  4 03:00:04 2006 +0000
> >+++ b/net/bridge/br_forward.c	Thu Sep 14 13:18:04 2006 -0500
> >@@ -29,7 +29,8 @@ static inline int should_deliver(const s
> > 
> > static inline unsigned packet_length(const struct sk_buff *skb)
> > {
> >-	return skb->len - (skb->protocol == htons(ETH_P_8021Q) ? VLAN_HLEN : 
> >0);
> >+	return skb->len - ETH_HLEN - 
> >+		(skb->protocol == htons(ETH_P_8021Q) ? VLAN_HLEN : 0);
> > }
> >
> >  
> packet_length() is a wrong place to do that, mtu has nothing to do with 
> skb headroom.

Oops, you are 100% correct.  So what would be the best way to handle
this, as a panic is pretty nasty?  Wouldn't it be better to check the
packet to see if there is sufficient headroom, BUG, and then drop it
(or allocate a new packet with sufficient headroom and proceed with
the skb_push)?  

Thanks,
Jon

> 
> --Mika
> 
> 
