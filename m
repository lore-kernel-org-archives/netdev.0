From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: [PATCH 0/5 v2] mv643xx_eth: device tree bindings
Date: Sat, 13 Apr 2013 17:21:26 +0200
Message-ID: <20130413172126.6cca0809@skate>
References: <1365071235-11611-1-git-send-email-florian@openwrt.org>
	<20130411165303.GI28693@titan.lakedaemon.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <florian@openwrt.org>, davem@davemloft.net,
	moinejf@free.fr, andrew@lunn.ch, netdev@vger.kernel.org,
	devicetree-discuss@lists.ozlabs.org, rob.herring@calxeda.com,
	grant.likely@secretlab.ca, jogo@openwrt.org,
	buytenh@wantstofly.org, jm@lentin.co.uk,
	linux-arm-kernel@lists.infradead.org,
	sebastian.hesselbarth@gmail.com
To: Jason Cooper <jason@lakedaemon.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([94.23.35.102]:43828 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753976Ab3DMPVj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Apr 2013 11:21:39 -0400
In-Reply-To: <20130411165303.GI28693@titan.lakedaemon.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Jason Cooper,

On Thu, 11 Apr 2013 12:53:03 -0400, Jason Cooper wrote:

> With this and Thomas' pci series, we will have Kirkwood fully
> converted to devicetree, can begin removing board files, and finally
> begin migrating everything over to mach-mvebu/.  This will lead to
> the removal of five directories under arch/arm/ (plat-orion,
> mach-kirkwood, mach-orion5x, mach-dove, and mach-mv78xx0).

No, we can't remove mach-orion5x and mach-mv78xx0 for now, they have
not been converted at all in terms of gpio/pinmux support. I've started
writing some pinmux code for orion5x but it's not ready.

I don't think we should rush in doing this merge into mach-mvebu. I'd
prefer to have the following conditions be met before a platform gets
merged into mach-mvebu:

 * The mach-<foo> directory no longer depends on anything in
   plat-orion. For mach-kirkwood, things are OK (for the DT platforms)
   for GPIO, MPP and PCIe, but some work remains for the IRQ controller
   driver and the timer driver.

 * All boards have been converted to the Device Tree. For
   mach-kirkwood, we're getting closer.

Once a given mach-<foo> platform meets these conditions, it will be a
clean platform, and we can merge it into mach-mvebu without any
problem.

So let's continue the cleanup work, conversion to DT, usage of drivers
in drivers/, improvement of pinmux to support orion5x/mv78xx0, and do
the move per-platform, once they are ready.

What do you think?

Thomas
-- 
Thomas Petazzoni, Free Electrons
Kernel, drivers, real-time and embedded Linux
development, consulting, training and support.
http://free-electrons.com
