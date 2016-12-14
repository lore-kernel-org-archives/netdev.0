From: <Woojung.Huh@microchip.com>
Subject: RE: [PATCH v2 net-next 1/2] phy: add phy fixup unregister functions
Date: Wed, 14 Dec 2016 15:34:04 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D40981BCB@CHN-SV-EXMX02.mchp-main.com>
References: <9235D6609DB808459E95D78E17F2E43D4097999C@CHN-SV-EXMX02.mchp-main.com>
 <58510539.1030803@hisilicon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <andrew@lunn.ch>, <netdev@vger.kernel.org>,
        <UNGLinuxDriver@microchip.com>
To: <lidongpo@hisilicon.com>, <davem@davemloft.net>,
        <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpout.microchip.com ([198.175.253.82]:37206 "EHLO
        email.microchip.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1756453AbcLNPeG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Dec 2016 10:34:06 -0500
In-Reply-To: <58510539.1030803@hisilicon.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I just want to commit the unregister patch and found this patch. Good job!
> But I consider this patch may miss something.
> If one SoC has 2 MAC ports and each port uses the different network driver,
> the 2 drivers may register fixup for the same PHY chip with different
> "run" function because the PHY chip works in different mode.
> In such a case, this patch doesn't consider "run" function and may cause
> problem.
> When removing the driver which register fixup at last, it will remove another
> driver's fixup.
> Should this condition be considered and fixed?
Good point.
Current phy fixup is independent LIST from phydev structure,
and, fixup runs in two places of phy_device_register() and phy_init_hw().
It's not clear that it needs two separate fixup, but it may be good idea to
pass phy fixup when calling phy_attach() or phy_attach_direct() and
put it under phydev structure.
So, fixup can be called at phy_init_hw() per phy device and remove
When phy detached.
Welcome any comments.

- Woojung
