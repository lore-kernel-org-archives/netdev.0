From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 4/6] sky2: reduce default Tx ring size
Date: Thu, 17 Nov 2011 14:41:42 -0800
Message-ID: <20111117144142.3447f15c@nehalam.linuxnetplumber.net>
References: <20111116234254.319625694@vyatta.com>
	<20111116234344.813201788@vyatta.com>
	<874ny2bgqa.fsf@turtle.gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Sven Joachim <svenjoac@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:36946 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751322Ab1KQWlp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Nov 2011 17:41:45 -0500
In-Reply-To: <874ny2bgqa.fsf@turtle.gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 17 Nov 2011 22:07:25 +0100
Sven Joachim <svenjoac@gmx.de> wrote:

> On 2011-11-17 00:42 +0100, Stephen Hemminger wrote:
> 
> > The default Tx ring size for the sky2 driver is quite large and could
> > cause excess buffer bloat for many users. The minimum ring size 
> > possible and still allow handling  the worst case packet on 64bit platforms
> > is 38 which gets rounded up to a power of 2. But most packets only require
> > a couple of ring elements.
> >
> > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> >
> > --- a/drivers/net/ethernet/marvell/sky2.c	2011-11-16 15:19:39.518659262 -0800
> > +++ b/drivers/net/ethernet/marvell/sky2.c	2011-11-16 15:19:40.990692544 -0800
> > @@ -68,7 +68,7 @@
> >  #define MAX_SKB_TX_LE	(2 + (sizeof(dma_addr_t)/sizeof(u32))*(MAX_SKB_FRAGS+1))
> >  #define TX_MIN_PENDING		(MAX_SKB_TX_LE+1)
> >  #define TX_MAX_PENDING		1024
> > -#define TX_DEF_PENDING		127
> > +#define TX_DEF_PENDING		63
> >  
> >  #define TX_WATCHDOG		(5 * HZ)
> >  #define NAPI_WEIGHT		64
> 
> It's hard to believe, but this innocuous-looking patch caused my system
> to crash and burn as soon as I actually used the network.
> Unfortunately, I have neither a digital camera nor a serial console at
> hand, but from my recollections and having read sky2.c I conclude that
> 
> 	BUG_ON(done >= sky2->tx_ring_size);
> 
> in sky2_tx_complete() seems to have been triggered.  Does this make any
> sense?
> 

If that is triggering then something is really odd because that means
the ring index went past the end of the ring and wasn't wrapped correctly.
