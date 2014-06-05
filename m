From: "fugang.duan@freescale.com" <fugang.duan@freescale.com>
Subject: RE: [PATCH v2 4/6] net: fec: Increase buffer descriptor entry number
Date: Thu, 5 Jun 2014 08:06:36 +0000
Message-ID: <43cdb6d0d624464daeaadcf26105c767@BLUPR03MB373.namprd03.prod.outlook.com>
References: <1401867571-11684-1-git-send-email-b38611@freescale.com>
 <1401867571-11684-5-git-send-email-b38611@freescale.com>
 <063D6719AE5E284EB5DD2968C1650D6D17256FBF@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"shawn.guo@linaro.org" <shawn.guo@linaro.org>,
	"Fabio.Estevam@freescale.com" <Fabio.Estevam@freescale.com>,
	"ezequiel.garcia@free-electrons.com"
	<ezequiel.garcia@free-electrons.com>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	"Frank.Li@freescale.com" <Frank.Li@freescale.com>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>
To: David Laight <David.Laight@ACULAB.COM>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1blp0187.outbound.protection.outlook.com ([207.46.163.187]:27106
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750866AbaFEIGm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2014 04:06:42 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D17256FBF@AcuExch.aculab.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, David,

From: David Laight <David.Laight@ACULAB.COM> Data: Wednesday, June 04, 2014 5:27 PM
> To: Duan Fugang-B38611; davem@davemloft.net
> Cc: netdev@vger.kernel.org; shawn.guo@linaro.org; Estevam Fabio-R49496;
> ezequiel.garcia@free-electrons.com; bhutchings@solarflare.com;
> stephen@networkplumber.org; Li Frank-B20596; eric.dumazet@gmail.com
> Subject: RE: [PATCH v2 4/6] net: fec: Increase buffer descriptor entry
> number
> 
> From: Fugang Duan
> > In order to support SG, software TSO, let's increase BD entry number.
> >
> > CC: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
> > CC: Eric Dumazet <eric.dumazet@gmail.com>
> > CC: David Laight <David.Laight@ACULAB.COM>
> > Signed-off-by: Fugang Duan <B38611@freescale.com>
> > ---
> >  drivers/net/ethernet/freescale/fec.h      |    6 +++---
> >  drivers/net/ethernet/freescale/fec_main.c |   21 ++++++++++++---------
> >  2 files changed, 15 insertions(+), 12 deletions(-)
> >
> > diff --git a/drivers/net/ethernet/freescale/fec.h
> b/drivers/net/ethernet/freescale/fec.h
> > index 3b8d6d1..798ad88 100644
> > --- a/drivers/net/ethernet/freescale/fec.h
> > +++ b/drivers/net/ethernet/freescale/fec.h
> > @@ -240,14 +240,14 @@ struct bufdesc_ex {
> >   * the skbuffer directly.
> >   */
> >
> > -#define FEC_ENET_RX_PAGES	8
> > +#define FEC_ENET_RX_PAGES	128
> >  #define FEC_ENET_RX_FRSIZE	2048
> >  #define FEC_ENET_RX_FRPPG	(PAGE_SIZE / FEC_ENET_RX_FRSIZE)
> >  #define RX_RING_SIZE		(FEC_ENET_RX_FRPPG * FEC_ENET_RX_PAGES)
> > ...
> 
> You are changing the number of rx descriptors as well.
> This isn't mentioned in the description.
> 
> And, as I said before, basing this on PAGE_SIZE cannot be right.
> 
> 	David

Ok, I agree your advice.
I will remove the change for RX BD entry. After test, the performance has no impact.

My initial purpose of increasing it is for interrupt coalescing patch. 

Thanks,
Andy
