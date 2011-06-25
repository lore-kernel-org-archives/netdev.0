From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [RFC 26/72] arm: Move the ARM/ACORN drivers
Date: Sat, 25 Jun 2011 16:48:03 +0200
Message-ID: <201106251648.03574.arnd@arndb.de>
References: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com> <1309010363-22750-27-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, Sriram <srk@ti.com>,
	Vinay Hegde <vinay.hegde@ti.com>,
	Cyril Chemparathy <cyril@ti.com>,
	Russell King <linux@arm.linux.org.uk>,
	Wan ZongShun <mcuos.com@gmail.com>,
	Lennert Buytenhek <kernel@wantstofly.org>,
	Krzysztof Halasa <khc@pm.waw.pl>,
	Anant Gole <anantgole@ti.com>,
	Chaithrika U S <chaithrika@ti.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.171]:59306 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751778Ab1FYOsL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Jun 2011 10:48:11 -0400
In-Reply-To: <1309010363-22750-27-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 25 June 2011, Jeff Kirsher wrote:
> Move the ARM/ACORN drivers into drivers/net/ethernet/arm/ and make the
> necessary Kconfig and Makefile changes.
> There were 4 drivers (TI Davinci & ftmac100) not in the
> drivers/net/arm/ which should have been since they are only supported
> under ARM, so they were added to the new directory structure.
> 
> NOTE: There are no "maintainers" for the TI Davinci drivers, so I am
> CC'ing the last 3 major contributors from TI.

It doesn't seem logical to group drivers that are used on ARM under
the architecture when the hardware is not actually made by ARM Ltd.

The MODULE_AUTHOR fields for the davinci driver list

DaVinci EMAC Maintainer: Anant Gole <anantgole@ti.com>
DaVinci EMAC Maintainer: Chaithrika U S <chaithrika@ti.com>


>  MAINTAINERS                                    |   10 +-
>  drivers/net/Kconfig                            |   33 -------
>  drivers/net/Makefile                           |    5 -
>  drivers/net/arm/Kconfig                        |   74 ---------------
>  drivers/net/ethernet/Kconfig                   |    1 +
>  drivers/net/ethernet/Makefile                  |    1 +
>  drivers/net/ethernet/arm/Kconfig               |  120 ++++++++++++++++++++++++
>  drivers/net/{ => ethernet}/arm/Makefile        |    4 +-
>  drivers/net/{ => ethernet}/arm/am79c961a.c     |    0
>  drivers/net/{ => ethernet}/arm/am79c961a.h     |    0

I guess this should be under ethernet/amd/ since they made the chip.

>  drivers/net/{ => ethernet}/arm/at91_ether.c    |    0
>  drivers/net/{ => ethernet}/arm/at91_ether.h    |    0

I wouldn't be surprised to see this show up in an AVR32 SoC, since
Atmel produces chips with both architectures.

>  drivers/net/{ => ethernet/arm}/davinci_cpdma.c |    0
>  drivers/net/{ => ethernet/arm}/davinci_cpdma.h |    0
>  drivers/net/{ => ethernet/arm}/davinci_emac.c  |    0
>  drivers/net/{ => ethernet/arm}/davinci_mdio.c  |    0

TI also produces chips with the C6x architecture, which will be supported
in Linux in the future. It could well be that there is a version that
uses the davinci ethernet mac. You also have a TI directory.

>  drivers/net/{ => ethernet}/arm/ep93xx_eth.c    |    0

maybe group that together with cs89x0 under driver/net/ethernet/cirrus/ ?

>  drivers/net/{ => ethernet}/arm/ether1.c        |    0
>  drivers/net/{ => ethernet}/arm/ether1.h        |    0
>  drivers/net/{ => ethernet}/arm/ether3.c        |    0
>  drivers/net/{ => ethernet}/arm/ether3.h        |    0
>  drivers/net/{ => ethernet}/arm/etherh.c        |    0

probably makes sense to keep those as ARM specific.

>  drivers/net/{ => ethernet}/arm/ixp4xx_eth.c    |    0

drivers/net/ethernet/intel/ ?
maybe driver/net/ethernet/marvell

>  drivers/net/{ => ethernet}/arm/ks8695net.c     |    0
>  drivers/net/{ => ethernet}/arm/ks8695net.h     |    0
>  drivers/net/{ => ethernet}/arm/w90p910_ether.c |    0

not sure about these.

	Arnd
