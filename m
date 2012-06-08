From: Josh Boyer <jwboyer@redhat.com>
Subject: Re: [PATCH] netdev: mv643xx_eth: Prevent build on PPC32
Date: Thu, 7 Jun 2012 21:04:03 -0400
Message-ID: <20120608010403.GL7683@zod.bos.redhat.com>
References: <20120605192820.GC7683@zod.bos.redhat.com>
 <1338939005.21665.54.camel@deadeye.wl.decadent.org.uk>
 <20120606023842.GD7683@zod.bos.redhat.com>
 <20120607235115.GB21150@sirena.org.uk>
 <20120607235550.GK7683@zod.bos.redhat.com>
 <20120608003445.GC21150@sirena.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <ben@decadent.org.uk>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Andrew Lunn <andrew@lunn.ch>, Olof Johansson <olof@lixom.net>,
	netdev@vger.kernel.org
To: Mark Brown <broonie@opensource.wolfsonmicro.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:3519 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759403Ab2FHBEv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Jun 2012 21:04:51 -0400
Content-Disposition: inline
In-Reply-To: <20120608003445.GC21150@sirena.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 08, 2012 at 01:34:45AM +0100, Mark Brown wrote:
> On Thu, Jun 07, 2012 at 07:55:51PM -0400, Josh Boyer wrote:
> > On Fri, Jun 08, 2012 at 12:51:15AM +0100, Mark Brown wrote:
> 
> > > This sort of issue is just the tip of the iceberg in terms of what it's
> > > useful to do with the API.
> 
> > Yes, sounds like it.  All I ask is that people test their patches along
> > the way so things don't get broken.  I mean, it's great we have an
> > iceberg but I don't want tons of drivers on other architectures running
> > into the thing and sinking because people aren't being careful.  Except
> > maybe the one already appropriately (nick)named.
> 
> It's really hard to blame the submitters here - this really isn't the
> sort of API that you'd expect to only be available conditionally so this
> isn't something that one would expect to have to worry about.  It's a
> product of the age of the clock API and the glacial progress on the
> generic clock API.

I'm not placing blame.  I'm declaring people should be cautious going
forward.  5 arches have the clock API.  21 don't.  Whatever reasons
there are for that, I don't care.  It should be a big warning sign.

It might even be beneficial to put some Kconfig dependencies on both
CONFIG_COMMON_CLK (which is somewhat misleadingly named) and
CONFIG_CLKDEV_LOOKUP so those are only selectable on those 5 arches.
Something like:

diff --git a/drivers/clk/Kconfig b/drivers/clk/Kconfig
index 4864407..3f49c22 100644
--- a/drivers/clk/Kconfig
+++ b/drivers/clk/Kconfig
@@ -1,6 +1,7 @@
 
 config CLKDEV_LOOKUP
 	bool
+	depends on (ARM || SUPERH || MIPS || C6X || BLACKFIN)
 	select HAVE_CLK
 
 config HAVE_CLK_PREPARE
@@ -11,6 +12,7 @@ config HAVE_MACH_CLKDEV
 
 config COMMON_CLK
 	bool
+	depends on (ARM || SUPERH || MIPS || C6X || BLACKFIN)
 	select HAVE_CLK_PREPARE
 	select CLKDEV_LOOKUP
 	---help---

Regardless, hopefully things like this will get hit in linux-next in the
future.  I believe the only reason that it wasn't this time is that
none of the PPC defconfigs build in linux-next bother to build the
driver at all.

josh
