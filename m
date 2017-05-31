From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fix auto-loading of Marvell DSA driver
Date: Wed, 31 May 2017 14:19:03 -0400 (EDT)
Message-ID: <20170531.141903.2066260668134273908.davem@davemloft.net>
References: <E1dFnuE-0006U0-PM@rmk-PC.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, f.fainelli@gmail.com, netdev@vger.kernel.org
To: rmk+kernel@armlinux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42094 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751009AbdEaSTE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 May 2017 14:19:04 -0400
In-Reply-To: <E1dFnuE-0006U0-PM@rmk-PC.armlinux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Russell King <rmk+kernel@armlinux.org.uk>
Date: Tue, 30 May 2017 21:38:18 +0100

> Auto-loading of the Marvell DSA driver has stopped working with recent
> kernels.  This seems to be due to the change of binding for DSA devices,
> moving them from the platform bus to the MDIO bus.
> 
> In order for module auto-loading to work, we need to provide a MODALIAS
> string in the uevent file for the device.  However, the device core does
> not automatically provide this, and needs each bus_type to implement a
> uevent method to generate these strings.  The MDIO bus does not provide
> such a method, so no MODALIAS string is provided:
> 
> .# cat /sys/bus/mdio_bus/devices/f1072004.mdio-mii\:04/uevent
> DRIVER=mv88e6085
> OF_NAME=switch
> OF_FULLNAME=/soc/internal-regs/mdio@72004/switch@4
> OF_COMPATIBLE_0=marvell,mv88e6085
> OF_COMPATIBLE_N=1
> 
> In the case of OF-based devices, the solution is easy -
> of_device_uevent_modalias() does the work for us.  After this is done,
> the uevent file looks like this:
> 
> .# cat /sys/bus/mdio_bus/devices/f1072004.mdio-mii\:04/uevent
> DRIVER=mv88e6085
> OF_NAME=switch
> OF_FULLNAME=/soc/internal-regs/mdio@72004/switch@4
> OF_COMPATIBLE_0=marvell,mv88e6085
> OF_COMPATIBLE_N=1
> MODALIAS=of:NswitchT<NULL>Cmarvell,mv88e6085
> 
> which results in auto-loading of the Marvell DSA driver on Clearfog
> platforms.
> 
> Fixes: c0405563a613 ("ARM: dts: armada-388-clearfog: Utilize new DSA binding")
> Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>

Applied, thanks.
