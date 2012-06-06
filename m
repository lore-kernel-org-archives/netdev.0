From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH] netdev: mv643xx_eth: Prevent build on PPC32
Date: Wed, 6 Jun 2012 02:49:07 +0200
Message-ID: <20120606004907.GG725@wantstofly.org>
References: <20120605192820.GC7683@zod.bos.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Lunn <andrew@lunn.ch>, Olof Johansson <olof@lixom.net>,
	netdev@vger.kernel.org
To: Josh Boyer <jwboyer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fw.wantstofly.org ([80.101.37.227]:61996 "EHLO
	mail.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752491Ab2FFAtL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2012 20:49:11 -0400
Content-Disposition: inline
In-Reply-To: <20120605192820.GC7683@zod.bos.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 05, 2012 at 03:28:21PM -0400, Josh Boyer wrote:

> Commit 452503ebc (ARM: Orion: Eth: Add clk/clkdev support.) added use of
> the clk driver API which results in compile errors on architectures that
> don't implement the clk API.
> 
> ERROR: "clk_enable" [drivers/net/ethernet/marvell/mv643xx_eth.ko] undefined!
> ERROR: "clk_disable" [drivers/net/ethernet/marvell/mv643xx_eth.ko] undefined!
> ERROR: "clk_put" [drivers/net/ethernet/marvell/mv643xx_eth.ko] undefined!
> ERROR: "clk_get_rate" [drivers/net/ethernet/marvell/mv643xx_eth.ko] undefined!
> ERROR: "clk_get" [drivers/net/ethernet/marvell/mv643xx_eth.ko] undefined!
> 
> Selecting CLKDEV_LOOKUP doesn't fix this either, as the build then fails with:
> 
> In file included from drivers/clk/clkdev.c:21:0:
> include/linux/clkdev.h:15:24: fatal error: asm/clkdev.h: No such file or directory
> 
> So we just prevent this from building at all on PPC32.

If the PPC32 dependency is no longer relevant (e.g. if Pegasos platform
support was removed from the kernel), then the commit message should
mention that -- the above reasoning is a poor sole justification for
this change.
