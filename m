From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH v5 2/2] Ethernet driver for the WIZnet W5100 chip
Date: Sat, 31 Mar 2012 11:40:14 +0200
Message-ID: <20120331094014.GA7746@electric-eye.fr.zoreil.com>
References: <1332752876-1650-1-git-send-email-msink@permonline.ru> <1333090806-27988-2-git-send-email-msink@permonline.ru> <1333099431.19659.15.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mike Sinkovsky <msink@permonline.ru>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:59607 "EHLO violet"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755921Ab2CaJnV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 31 Mar 2012 05:43:21 -0400
Content-Disposition: inline
In-Reply-To: <1333099431.19659.15.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> :
> Le vendredi 30 mars 2012 ?? 13:00 +0600, Mike Sinkovsky a ??crit :
> > Tested and used in production with Blackfin BF531 embedded processor.
[...]
> > +static int w5100_start_tx(struct sk_buff *skb, struct net_device *ndev)
> > +{
> > +	struct w5100_priv *priv = netdev_priv(ndev);
> > +	u16 offset;
> > +
> > +	if (w5100_read16(priv, W5100_S0_TX_FSR) < skb->len) {
> 
> There is a race here.
> 
> Interrupt came come right here before you set the stop_queue()
> 
> 
> > +		netif_stop_queue(ndev);
> 
> So Here I suggest adding a test again
> 	
> 	if (w5100_read16(priv, W5100_S0_TX_FSR) >= skb->len)
> 		netif_wake_queue(ndev);
> 	else
> 		return NETDEV_TX_BUSY;

The start_tx logic seems broken anyway: it claims it always can take
packets until it is given one it can't process. The driver should rather
do the opposite and stop queueing as soon as there is no guarantee for
the next packet.

-- 
Ueimor
