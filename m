From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [net-next 03/10] seeq: Move the SEEQ drivers
Date: Fri, 4 Nov 2011 21:25:55 +0000
Message-ID: <20111104212555.GD12913@n2100.arm.linux.org.uk>
References: <1313134384-7287-1-git-send-email-jeffrey.t.kirsher@intel.com> <1313134384-7287-4-git-send-email-jeffrey.t.kirsher@intel.com> <20111104172446.GB12913@n2100.arm.linux.org.uk> <1320441367.2113.4.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	torvalds@linux-foundation.org, davem@davemloft.net,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Hamish Coleman <hamish@zot.apana.org.au>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caramon.arm.linux.org.uk ([78.32.30.218]:50350 "EHLO
	caramon.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753202Ab1KDV0Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Nov 2011 17:26:25 -0400
Content-Disposition: inline
In-Reply-To: <1320441367.2113.4.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 04, 2011 at 11:16:07PM +0200, Joe Perches wrote:
> On Fri, 2011-11-04 at 17:24 +0000, Russell King - ARM Linux wrote:
> > Okay, this is the only patch I saw (for the SEEQ drivers), but I notice
> > that more of the ARM drivers have moved.  The result is not nice.  Or
> > even workable.
> > 
> > While looking for my ether1, ether3 and etherh drivers in Kconfig, I
> > enable every option which is presented to me under the new 'ethernet
> > drivers' stuff.  I'm offered my ether3 driver under the SEEQ stuff -
> > that's fine.  But what about the rest?
> []
> > While I realise this is a big change, and bugs like this are likely, it
> > would've been nice to be copied on more of the patches which affect
> > drivers I maintain.
> 
> Hi Russell.
> 
> What drivers in drivers/net do you maintain?
> 
> I believe this is the list in MAINTAINERS for you:
> 
> ARM/EBSA110 MACHINE SUPPORT
> F:      drivers/net/ethernet/amd/am79c961a.*
> ARM/RISCPC ARCHITECTURE
> F:      drivers/net/ethernet/i825xx/ether1*
> F:      drivers/net/ethernet/seeq/ether3*
> 
> Are there others? If yes, what are they?

If that's what's in mainline, then etherh has been dropped from that
list through this move.  It's drivers/net/ethernet/8390/etherh*, so
that needs adding back for "ARM/RISCPC ARCHITECTURE".

It was correct - below seems to be what happened...

commit 115978859272b958366d4a08c99a24f9625fa663
Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date:   Wed Jul 13 15:38:08 2011 -0700

    i825xx: Move the Intel 82586/82593/82596 based drivers

@@ -1014,7 +1014,7 @@ F:        arch/arm/include/asm/hardware/ioc.h
 F:     arch/arm/include/asm/hardware/iomd.h
 F:     arch/arm/include/asm/hardware/memc.h
 F:     arch/arm/mach-rpc/
-F:     drivers/net/arm/ether*
+F:     drivers/net/arm/ether3*

That change was probably correct at the time, because this one which
came before it:

commit 644570b830266ff33ff5f3542b9c838f93a55ea6
Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date:   Sat Apr 2 06:20:12 2011 -0700

    8390: Move the 8390 related drivers

which moved the etherh driver without updating MAINTAINERS for that
change.
