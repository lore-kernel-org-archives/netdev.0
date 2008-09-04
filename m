From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH, RFC] mv643xx_eth: move sram window setting code into the driver
Date: Thu, 4 Sep 2008 17:20:33 +0200
Message-ID: <20080904152032.GB27272@xi.wantstofly.org>
References: <20080903140048.GC19602@xi.wantstofly.org> <48BFE63F.70700@genesi-usa.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: Matt Sealey <matt@genesi-usa.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:59905 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755253AbYIDPUf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Sep 2008 11:20:35 -0400
Content-Disposition: inline
In-Reply-To: <48BFE63F.70700@genesi-usa.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 04, 2008 at 08:44:31AM -0500, Matt Sealey wrote:

> I was thinking about this actually, similar to the Efika Device Tree 
> Supplement for MPC5200B board (which adds a lot of device tree nodes
> not present on the production model and fixes some things), we have
> a Pegasos one too which changes some very minor stuff.
> 
> This could be in the kernel (chrp fixups) or in a pre-boot Forth
> script, but in either case, wouldn't a real sram node in the device
> tree be the proper solution here? Hardcoding addresses for devices
> is rather arch/ppc behaviour and the driver is one of the few cases
> that never got reworked to fit.

Probably.

I guess you don't want to pass that info _directly_ to the mv643xx_eth
driver, though -- since the on-chip SRAM can be used for many things,
and you're not necessarily sure that the user wants to use it for
descriptors.  (Or how much of it they want to use for descriptors.)
(Or for the descriptors of which of the 8 possible transmit and receive
queues, considering the 2.6.27 driver supports multiple queues.)

Well, I'm not sure what the best solution is. :-)


> I don't have a Pegasos running right now to test but I will, as soon
> as possible, make sure this works first.

Cool, thanks.  It would be nice if you could give the driver in
2.6.27-rc5 a spin, it has seen a _lot_ of changes since 2.6.25 and
I'd really like to make sure it still works on Pegasos.
