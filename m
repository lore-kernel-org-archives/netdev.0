From: Josh Boyer <jwboyer@redhat.com>
Subject: Re: [PATCH] netdev: mv643xx_eth: Prevent build on PPC32
Date: Tue, 5 Jun 2012 22:40:14 -0400
Message-ID: <20120606024013.GE7683@zod.bos.redhat.com>
References: <20120605192820.GC7683@zod.bos.redhat.com>
 <20120606004907.GG725@wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Lunn <andrew@lunn.ch>, Olof Johansson <olof@lixom.net>,
	netdev@vger.kernel.org
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59108 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752683Ab2FFCkw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Jun 2012 22:40:52 -0400
Content-Disposition: inline
In-Reply-To: <20120606004907.GG725@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 06, 2012 at 02:49:07AM +0200, Lennert Buytenhek wrote:
> On Tue, Jun 05, 2012 at 03:28:21PM -0400, Josh Boyer wrote:
> 
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
> 
> If the PPC32 dependency is no longer relevant (e.g. if Pegasos platform
> support was removed from the kernel), then the commit message should
> mention that -- the above reasoning is a poor sole justification for
> this change.

You are correct.  As it stands, it's no better than just breaking it
outright with commit 452503ebc.  I've described the 3 possible solutions
in my other reply.

josh
