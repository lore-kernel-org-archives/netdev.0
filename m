From: Duan Fugang-B38611 <B38611@freescale.com>
Subject: RE: [PATCH] net: fec: fix the error to get the previous BD entry
Date: Tue, 3 Sep 2013 01:39:25 +0000
Message-ID: <9848F2DB572E5649BA045B288BE08FBE01682504@039-SN2MPN1-021.039d.mgd.msft.net>
References: <1378121735-5681-1-git-send-email-B38611@freescale.com>
 <1F990F8245A4214A8CC4BFFBD9F790F908B45674@039-SN1MPN1-001.039d.mgd.msft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>
To: Li Frank-B20596 <B20596@freescale.com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from am1ehsobe005.messaging.microsoft.com ([213.199.154.208]:17607
	"EHLO am1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756821Ab3ICBjn convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Sep 2013 21:39:43 -0400
In-Reply-To: <1F990F8245A4214A8CC4BFFBD9F790F908B45674@039-SN1MPN1-001.039d.mgd.msft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li Frank-B20596
Data: Monday, September 02, 2013 10:30 PM

> To: Duan Fugang-B38611; davem@davemloft.net
> Cc: netdev@vger.kernel.org; bhutchings@solarflare.com;
> stephen@networkplumber.org
> Subject: RE: [PATCH] net: fec: fix the error to get the previous BD entry
> 
> 
> 
> > -----Original Message-----
> > From: Duan Fugang-B38611
> > Sent: Monday, September 02, 2013 6:36 AM
> > To: Li Frank-B20596; davem@davemloft.net
> > Cc: netdev@vger.kernel.org; bhutchings@solarflare.com;
> > stephen@networkplumber.org
> > Subject: [PATCH] net: fec: fix the error to get the previous BD entry
> >
> > Bug: error to get the previous BD entry. When the current BD is the
> > first BD, the previous BD entry must be the last BD, not "bdp - 1" in
> current logic.
> >
> > V2:
> >   Add tx_ring_size and rx_ring_size to struct fec_enet_private.
> >   Replace api fec_enet_get_nextdesc() with next_bd().
> >   Replace api fec_enet_get_prevdesc() with pre_bd().
> >
> >   Move all ring size check logic to next_bd() and pre_bd, which
> >   simplifies the code redundancy.
> >
> > V1:
> >   Add BD ring size check to get the previous BD entry in correctly.
> >
> > Signed-off-by: Fugang Duan  <B38611@freescale.com>
> > ---
> >  drivers/net/ethernet/freescale/fec.h      |    3 +
> >  drivers/net/ethernet/freescale/fec_main.c |   94 +++++++++++++++-------
> -----
> > -
> >  2 files changed, 53 insertions(+), 44 deletions(-)
> >
> > diff --git a/drivers/net/ethernet/freescale/fec.h
> > b/drivers/net/ethernet/freescale/fec.h
> > index ae23600..0120217 100644
> > --- a/drivers/net/ethernet/freescale/fec.h
> > +++ b/drivers/net/ethernet/freescale/fec.h
> > @@ -296,6 +296,9 @@ struct fec_enet_private {
> >  	/* The ring entries to be free()ed */
> >  	struct bufdesc	*dirty_tx;
> >
> > +	unsigned short tx_ring_size;
> > +	unsigned short rx_ring_size;
> > +
> >  	struct	platform_device *pdev;
> >
> >  	int	opened;
> > diff --git a/drivers/net/ethernet/freescale/fec_main.c
> > b/drivers/net/ethernet/freescale/fec_main.c
> > index 4ea1555..9894dd3 100644
> > --- a/drivers/net/ethernet/freescale/fec_main.c
> > +++ b/drivers/net/ethernet/freescale/fec_main.c
> > @@ -239,22 +239,35 @@ MODULE_PARM_DESC(macaddr, "FEC Ethernet MAC
> > address");
> >
> >  static int mii_cnt;
> >
> > -static struct bufdesc *fec_enet_get_nextdesc(struct bufdesc *bdp, int
> > is_ex)
> > +static inline
> > +struct bufdesc *next_bd(struct bufdesc *bdp, struct bufdesc *base,
> > +			int ring_size, int is_ex)
> 
> David suggest use fec_enet_ prefix for all function in fec driver when I
> upstream it.
> 
> 
> How about use
> 	Fec_enet_next_bd(struct bufdesc *bdp, *fep)
> 	The parameter will become little and easy to call.
> 
> >  {
> > -	struct bufdesc_ex *ex = (struct bufdesc_ex *)bdp;
> > +	struct bufdesc *new_bd = bdp + 1;
> > +	struct bufdesc_ex *ex_new_bd = (struct bufdesc_ex *)bdp + 1;
> > +	struct bufdesc_ex *ex_base = (struct bufdesc_ex *)base;
> > +
> 
> If pass down fep,
> 	If( bdp > fep->rx_base) {
> 		Ex_base = fep->rx_base;
> 		Ring_size = fep->rx_ring_size;
> 	}
> 	Else {
> 		Ex_base = fep->tx_base.
> 		Ring_size = fep->tx_ring_size;
> 	}
> 
> Because RX always behind of TX.
> 

Good idea, I will send patch V3.  Thanks.
