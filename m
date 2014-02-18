From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: [PATCH] net: ethernet: remove unneeded dependency of mvneta and
 update help text
Date: Tue, 18 Feb 2014 15:10:27 +0100
Message-ID: <20140218151027.710ab2f3@skate>
References: <1392719391-8851-1-git-send-email-thomas.petazzoni@free-electrons.com>
	<20140218122952.GM7862@titan.lakedaemon.net>
	<20140218134532.7607a616@skate>
	<20140218125206.GN7862@titan.lakedaemon.net>
	<20140218141303.77c77272@skate>
	<20140218135809.GD17984@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jason Cooper <jason@lakedaemon.net>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	linux-arm-kernel@lists.infradead.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:45237 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755298AbaBROKa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Feb 2014 09:10:30 -0500
In-Reply-To: <20140218135809.GD17984@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Andrew Lunn,

On Tue, 18 Feb 2014 14:58:09 +0100, Andrew Lunn wrote:

> PLAT_ORION is a bit of an odd thing now.
> 
> For me, PLAT_ORION means arch/arm/plat-orion. 

No, it is PLAT_ORION_LEGACY which means arch/arm/plat-orion.

> But as far as i know, 370/XP does not actually use anything from
> arch/arm/plat-orion. When kirkwood moves into mach-mvebu, it also will
> not use any code from it, and i suspect dove is the same.

Interestingly, we have -I$(srctree)/arch/arm/plat-orion/include in
mach-mvebu/Makefile. Might be something to revisit later on.

> So maybe in a few cycles, when only mach-orion5x is left, we can merge
> arch/arm/plat-orion into arch/arm/mach-orion5x and PLAT_ORION goes
> away?

We also have mach-mv78xx0 to worry about, unless we decide to remove
support for it entirely. And even if plat-orion is merged into
mach-orion5x, we will keep PLAT_ORION as a way to indicate that the
platform needs to use a certain number of drivers (see below).

> Or do we want to define that PLAT_ORION means any system which can
> make use of mvebu drivers?

This is what it means today. The MV_XOR driver is under PLAT_ORION, the
gpio driver is under PLAT_ORION, the Device Bus driver is under
PLAT_ORION, the I2C driver is under PLAT_ORION, the pinctrl driver as
well, and so on and so on.

At the very end of the clean up, when even Orion5x support will be
merged in mach-mvebu/, then we can certainly replace these dependencies
by a "depends on ARCH_MVEBU". But for the time being, PLAT_ORION seems
like the right common denominator for all these platforms.

Best regards,

Thomas
-- 
Thomas Petazzoni, CTO, Free Electrons
Embedded Linux, Kernel and Android engineering
http://free-electrons.com
