From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Subject: Re: [PATCH 2/4][SSB] EXTIF serial port initialization
Date: Mon, 6 Aug 2007 10:14:52 -0300
Message-ID: <20070806131452.GM2469@ghostprotocols.net>
References: <20070805231959.GC13927@hall.aurel32.net> <20070806002117.GJ2469@ghostprotocols.net> <200708061051.05769.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Aurelien Jarno <aurelien@aurel32.net>, netdev@vger.kernel.org,
	Felix Fietkau <nbd@openwrt.org>
To: Michael Buesch <mb@bu3sch.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ag-out-0708.google.com ([72.14.246.248]:37768 "EHLO
	ag-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754274AbXHFNPA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Aug 2007 09:15:00 -0400
Received: by ag-out-0708.google.com with SMTP id 35so1665672aga
        for <netdev@vger.kernel.org>; Mon, 06 Aug 2007 06:14:59 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <200708061051.05769.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Em Mon, Aug 06, 2007 at 10:51:05AM +0200, Michael Buesch escreveu:
> On Monday 06 August 2007, Arnaldo Carvalho de Melo wrote:
> > Em Mon, Aug 06, 2007 at 01:19:59AM +0200, Aurelien Jarno escreveu:
> > > The patch below against 2.6.23-rc1-mm2 implements EXTIF serial
> > > initialization, currently marked as TODO.
> > > 
> > > It originally comes from the OpenWrt patches.
> > 
> > Comments below
> >  
> > > Cc: Felix Fietkau <nbd@openwrt.org>
> > > Signed-off-by: Aurelien Jarno <aurelien@aurel32.net>
> > > 
> > > --- a/drivers/ssb/driver_mipscore.c
> > > +++ b/drivers/ssb/driver_mipscore.c
> > > @@ -128,51 +128,52 @@
> > >  	ssb_write32(mdev, SSB_IPSFLAG, irqflag);
> > >  }
> > >  
> > > -/* XXX: leave here or move into separate extif driver? */
> > > -static int ssb_extif_serial_init(struct ssb_device *dev, struct ssb_serial_ports *ports)
> > > +static inline bool serial_exists(u8 *regs)
> > >  {
> > > +	u8 save_mcr, msr = 0;
> > 
> > Why declare save_mcr here...
> > 
> > >  
> > > +	if (regs) {
> > 
> > if it is just used here?
> 
> There is almost never an advantage when declaring variables at the beginning
> of a statement block instead of the function start.
> The only thing you "gain" is that you don't easily see anymore how much
> stackspace is used by the funtions.

Well, I disagree, your argument is flawed because if the function is too
big to have so many variables it should be split in smaller functions
anyway, and when it is not that big, like in the above case one can see
the stack usage just fine on the same screen.

> So I really suggest to declare variables at the beginning of functions,
> except for some rare circumstances maybe. Which is not the case here.

I'd recommend the reverse, but anyway, it is just a suggestion.
 
- Arnaldo
