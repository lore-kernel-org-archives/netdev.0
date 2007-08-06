From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH 2/4][SSB] EXTIF serial port initialization
Date: Mon, 6 Aug 2007 10:51:05 +0200
Message-ID: <200708061051.05769.mb@bu3sch.de>
References: <20070805231959.GC13927@hall.aurel32.net> <20070806002117.GJ2469@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Aurelien Jarno <aurelien@aurel32.net>, netdev@vger.kernel.org,
	Felix Fietkau <nbd@openwrt.org>
To: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:53567
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754682AbXHFIvO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Aug 2007 04:51:14 -0400
In-Reply-To: <20070806002117.GJ2469@ghostprotocols.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 06 August 2007, Arnaldo Carvalho de Melo wrote:
> Em Mon, Aug 06, 2007 at 01:19:59AM +0200, Aurelien Jarno escreveu:
> > The patch below against 2.6.23-rc1-mm2 implements EXTIF serial
> > initialization, currently marked as TODO.
> > 
> > It originally comes from the OpenWrt patches.
> 
> Comments below
>  
> > Cc: Felix Fietkau <nbd@openwrt.org>
> > Signed-off-by: Aurelien Jarno <aurelien@aurel32.net>
> > 
> > --- a/drivers/ssb/driver_mipscore.c
> > +++ b/drivers/ssb/driver_mipscore.c
> > @@ -128,51 +128,52 @@
> >  	ssb_write32(mdev, SSB_IPSFLAG, irqflag);
> >  }
> >  
> > -/* XXX: leave here or move into separate extif driver? */
> > -static int ssb_extif_serial_init(struct ssb_device *dev, struct ssb_serial_ports *ports)
> > +static inline bool serial_exists(u8 *regs)
> >  {
> > +	u8 save_mcr, msr = 0;
> 
> Why declare save_mcr here...
> 
> >  
> > +	if (regs) {
> 
> if it is just used here?

There is almost never an advantage when declaring variables at the beginning
of a statement block instead of the function start.
The only thing you "gain" is that you don't easily see anymore how much
stackspace is used by the funtions.
So I really suggest to declare variables at the beginning of functions,
except for some rare circumstances maybe. Which is not the case here.

But anyway. Just saw this: Drop the inline statement. There is no
need to inline this function.
