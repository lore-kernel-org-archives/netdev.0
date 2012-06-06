From: Josh Boyer <jwboyer@redhat.com>
Subject: Re: [PATCH] netdev: mv643xx_eth: Prevent build on PPC32
Date: Tue, 5 Jun 2012 22:38:42 -0400
Message-ID: <20120606023842.GD7683@zod.bos.redhat.com>
References: <20120605192820.GC7683@zod.bos.redhat.com>
 <1338939005.21665.54.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Lennert Buytenhek <buytenh@wantstofly.org>,
	Andrew Lunn <andrew@lunn.ch>, Olof Johansson <olof@lixom.net>,
	netdev@vger.kernel.org
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36094 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751312Ab2FFCje (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Jun 2012 22:39:34 -0400
Content-Disposition: inline
In-Reply-To: <1338939005.21665.54.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 06, 2012 at 12:30:05AM +0100, Ben Hutchings wrote:
> On Tue, 2012-06-05 at 15:28 -0400, Josh Boyer wrote:
> > Commit 452503ebc (ARM: Orion: Eth: Add clk/clkdev support.) added use of
> > the clk driver API which results in compile errors on architectures that
> > don't implement the clk API.
> > 
> > ERROR: "clk_enable" [drivers/net/ethernet/marvell/mv643xx_eth.ko] undefined!
> > ERROR: "clk_disable" [drivers/net/ethernet/marvell/mv643xx_eth.ko] undefined!
> > ERROR: "clk_put" [drivers/net/ethernet/marvell/mv643xx_eth.ko] undefined!
> > ERROR: "clk_get_rate" [drivers/net/ethernet/marvell/mv643xx_eth.ko] undefined!
> > ERROR: "clk_get" [drivers/net/ethernet/marvell/mv643xx_eth.ko] undefined!
> > 
> > Selecting CLKDEV_LOOKUP doesn't fix this either, as the build then fails with:
> > 
> > In file included from drivers/clk/clkdev.c:21:0:
> > include/linux/clkdev.h:15:24: fatal error: asm/clkdev.h: No such file or directory
> > 
> > So we just prevent this from building at all on PPC32.
> [...]
> 
> This dependency was introduced by:
> 
> commit 16b817579fb61050f1abcc0e81089974328a9c27
> Author: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> Date:   Sat Apr 16 15:24:30 2005 -0700
> 
>     [PATCH] ppc32: MV643XX ethernet is an option for Pegasos
> 
> commit 06ede91017d015a03cf8c1c87b3ff668f9a846e0
> Author: Dale Farnsworth <dale@farnsworth.org>
> Date:   Wed Sep 20 12:24:34 2006 -0700
> 
>     [PATCH] mv643xx_eth: restrict to 32-bit PPC_MULTIPLATFORM
> 
> If Pegasos is still supposed to be supported then this needs to be fixed
> properly.

The proper fix, from my minimal looking, was one of:

1) revert the change for ARM that introduced th clk stuff
2) do a similar change as the original commit but with a bunch of
#ifdef-ery
3) implement the clkdev API stuff for 32-bit ppc

Honestly, I'd go for either 1 or 2.  The commit that introduced it was
broken to begin with, but that isn't my call.

josh
