From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: macb: replace literal constant with
 NET_IP_ALIGN
Date: Thu, 02 Jul 2015 00:13:57 +0200
Message-ID: <1435788837.8526.3.camel@edumazet-glaptop2.roam.corp.google.com>
References: <5592D105.7080006@certsign.ro>
	 <1435748191.4110.127.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1435770389.12101.110.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Nicolae Rosia <nicolae.rosia@certsign.ro>, netdev@vger.kernel.org,
	'Nicolas Ferre <nicolas.ferre@atmel.com>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:35626 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752797AbbGAWOE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jul 2015 18:14:04 -0400
Received: by wiga1 with SMTP id a1so137381061wig.0
        for <netdev@vger.kernel.org>; Wed, 01 Jul 2015 15:14:03 -0700 (PDT)
In-Reply-To: <1435770389.12101.110.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-07-01 at 10:06 -0700, Joe Perches wrote:
> On Wed, 2015-07-01 at 12:56 +0200, Eric Dumazet wrote:
> > On Tue, 2015-06-30 at 20:25 +0300, Nicolae Rosia wrote:
> > > diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
> []
> > > @@ -2554,9 +2554,9 @@ static void at91ether_rx(struct net_device *dev)
> > >  	while (lp->rx_ring[lp->rx_tail].addr & MACB_BIT(RX_USED)) {
> > >  		p_recv = lp->rx_buffers + lp->rx_tail * AT91ETHER_MAX_RBUFF_SZ;
> > >  		pktlen = MACB_BF(RX_FRMLEN, lp->rx_ring[lp->rx_tail].ctrl);
> > > -		skb = netdev_alloc_skb(dev, pktlen + 2);
> > > +		skb = netdev_alloc_skb(dev, pktlen + NET_IP_ALIGN);
> > >  		if (skb) {
> > > -			skb_reserve(skb, 2);
> > > +			skb_reserve(skb, NET_IP_ALIGN);
> > >  			memcpy(skb_put(skb, pktlen), p_recv, pktlen);
> > >  
> > >  			skb->protocol = eth_type_trans(skb, dev);
> > 
> > Then please use netdev_alloc_skb_ip_align(), so that you get rid of
> > skb_reserve()
> 
> It seems there are ~50 of these in the kernel tree
> that could be converted.
> 

Make sure the 2 is really NET_IP_ALIGN

Some hardwares need 2, even if NET_IP_ALIGN is 0 (on x86 arches for
example)

I would rather not touch this without testing the change on real
hardware.
