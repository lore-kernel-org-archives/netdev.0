From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next 1/2] Documentation: networking: add a DSA document
Date: Tue, 25 Aug 2015 07:40:26 -0700
Message-ID: <CAE4R7bBSfeaQ3eo0UyRRF_aFQkeCrSk0BHmH4-K2GW6XZBe6Ng@mail.gmail.com>
References: <1440510642-15588-1-git-send-email-f.fainelli@gmail.com> <1440510642-15588-2-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>, "andrew@lunn.ch" <andrew@lunn.ch>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	Guenter Roeck <linux@roeck-us.net>,
	"David S. Miller" <davem@davemloft.net>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f181.google.com ([209.85.214.181]:34954 "EHLO
	mail-ob0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751286AbbHYOkq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2015 10:40:46 -0400
Received: by obbwr7 with SMTP id wr7so143765092obb.2
        for <netdev@vger.kernel.org>; Tue, 25 Aug 2015 07:40:45 -0700 (PDT)
In-Reply-To: <1440510642-15588-2-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 25, 2015 at 6:50 AM, Florian Fainelli <f.fainelli@gmail.com> wrote:
> Describe how the DSA subsystem works, its design principles,
> limitations, and describe in details how to implement a DSA switch
> driver.
>
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

[cut]

> +Interactions with other subsystems
> +==================================
> +
> +DSA currently leverages the following subsystems:
> +
> +- MDIO/PHY library: drivers/net/phy/phy.c, mdio_bus.c
> +- Switchdev: net/switchdev/*
> +- Device Tree for various of_* functions
> +- HWMON: drivers/hwmon/*
> +
> +MDIO/PHY library
> +----------------
> +
> +Slave network devices exposed by DSA may or may not be interfacing with PHY
> +devices (struct phy_device as defined in include/linux/phy.h), but the DSA
> +subsystem deals with all possible combinations:
> +
> +- internal PHY devices, built into the Ethernet switch hardware
> +- external PHY devices, connected via an internal or external MDIO bus
> +- internal PHY devices, connected vian an internal MDIO bus
> +- special, non-autonegotiated or non MDIO-managed PHY devices: SFPs, MoCA; aka
> +  fixed PHYs
> +
> +The PHY configuration is done by the dsa_slave_phy_setup() function and the
> +logic basically looks like this:
> +
> +- if Device Tree is used, the PHY device is looked up using the standard
> +  "phy-handle" property, if found, this PHY device is created and registered
> +  using of_phy_connect()
> +
> +- if Device Tree is used, and the PHY device is "fixed", that is, conforms to
> +  the definition of a non-MDIO managed PHY as defined in
> +  Documentation/devicetree/binding/net/fixed-link.txt, the PHY is the registered
> +  and connected to using the special fixed MDIO bus driver transparently
> +
> +- finally, if the PHY is built into the switch, as is very common with
> +  standalone switch packages, the PHY is probed using the slave MII bus created
> +  by DSA
> +
> +
> +SWITCHDEV
> +---------
> +
> +DSA directly utilizes SWITCHDEV when interfacing with the bridge layer, and more
> +specifically with its VLAN filtering portion when configuring VLANs on top of
> +per-port slave network devices. Since DSA primarily deals with MDIO-connected
> +switch, although not exclusively, SWITCHDEV's commit/prepare/ phase
> +

Missing rest of sentence.
