From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pktgen - define and use pktgen_dbg,err,warn,info
Date: Mon, 30 Jul 2007 16:05:40 -0700 (PDT)
Message-ID: <20070730.160540.48528135.davem@davemloft.net>
References: <1184796853.5863.40.camel@localhost>
	<20070718.154950.91758269.davem@davemloft.net>
	<1184800861.5863.54.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert.Olsson@data.slu.se, netdev@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53971
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753446AbXG3XFo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jul 2007 19:05:44 -0400
In-Reply-To: <1184800861.5863.54.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Wed, 18 Jul 2007 16:21:00 -0700

> On Wed, 2007-07-18 at 15:49 -0700, David Miller wrote:
> > From: Joe Perches <joe@perches.com>
> > Date: Wed, 18 Jul 2007 15:14:13 -0700
> > 
> > > -#define VERSION  "pktgen v2.68: Packet Generator for packet performance testing.\n"
> > > +#define PKTGEN_NAME    "pktgen"
> > > +#define PKTGEN_VERSION "v2.68"
> > > +#define PKTGEN_DESC    "Packet Generator for packet performance testing"
> > > +#define PKTGEN_FULLINFO PKTGEN_NAME " " PKTGEN_VERSION ": " PKTGEN_DESC ".\n"
> >  ...
> > 
> > > -static char version[] __initdata = VERSION;
> > > -
> > 
> > Using PKTGEN_FULLINFO explicitly won't get that string into the
> > __initdata section as the version[] will, that's why people do it that
> > way with the explicit version[] array.
> > 
> > Please put it back, assign PKTGEN_FULLINFO to it, and use it.
> 
> Done. Here you are.
> 
> fyi:
> pktgen_info(version) fails compile,
> pktgen_info("%s", version) works.

I still don't know about this patch.  Instead of the simple
transformation:

-	printk(foo);
+	printk(KERN_INFO foo);

we get this new macro, and the lines changes to use that macro.

It seems very over-engineered and adds ifdefs to a foo.c file
which is severly frowned upon.

I'm going to add the needed KERN_* to pktgen.c, that's just so
much nicer a way to handle this.
