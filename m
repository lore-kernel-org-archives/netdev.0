From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] r8169: remove unneeded dirty_rx index
Date: Wed, 16 Jan 2013 22:26:22 +0100
Message-ID: <20130116212622.GA32073@electric-eye.fr.zoreil.com>
References: <20130115225316.GA924@electric-eye.fr.zoreil.com> <1358319684-32364-1-git-send-email-timo.teras@iki.fi> <20130116.162500.1216966272191204366.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: timo.teras@iki.fi, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:45071 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757323Ab3APVzO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jan 2013 16:55:14 -0500
Content-Disposition: inline
In-Reply-To: <20130116.162500.1216966272191204366.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> :
[...]
> > @@ -6035,10 +6034,8 @@ static int rtl_rx(struct net_device *dev, struct rtl8169_private *tp, u32 budget
> >  	unsigned int count;
> >  
> >  	cur_rx = tp->cur_rx;
> > -	rx_left = NUM_RX_DESC + tp->dirty_rx - cur_rx;
> > -	rx_left = min(rx_left, budget);
> >  
> > -	for (; rx_left > 0; rx_left--, cur_rx++) {
> > +	for (rx_left = min(budget, NUM_RX_DESC); rx_left > 0; rx_left--, cur_rx++) {
> 
> Is this really equivalent?  I think cur_rx still needs to be
> incorporated into whatever you use as the initial rx_left.

The rx ring can't contain hole so the code above must be read with
"tp->cur_rx == tp->dirty_rx" in mind.

-- 
Ueimor
