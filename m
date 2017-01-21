From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 1/8] net: dsa: mv88e6xxx: Implement external MDIO
 bus on mv88e6390
Date: Fri, 20 Jan 2017 16:01:46 -0800
Message-ID: <28da5ac2-acb8-f869-db7d-0772868dac69@gmail.com>
References: <1484955062-26718-1-git-send-email-andrew@lunn.ch>
 <1484955062-26718-2-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev <netdev@vger.kernel.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:35768 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752000AbdAUACE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2017 19:02:04 -0500
Received: by mail-pg0-f67.google.com with SMTP id 204so7975802pge.2
        for <netdev@vger.kernel.org>; Fri, 20 Jan 2017 16:01:48 -0800 (PST)
In-Reply-To: <1484955062-26718-2-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/20/2017 03:30 PM, Andrew Lunn wrote:
> The mv88e6390 has two MDIO busses. The internal MDIO bus is used for
> the internal PHYs. The external MDIO can be used for external PHYs.
> The external MDIO bus will be instantiated if there is an
> "mdio-external" node in the device tree.

This looks fine, although I am not clear why we cannot utilize a
standard representation of a MDIO bus (with PHY devices as child nodes)
which has a specific compatible string, e.g:
marvell,mv88e6390-external-mdio, and that is a child node of the 6390
Ethernet switch itself, something like:

/* assuming this is, e.g: an independent or CPU EThernet MAC MDIO bus */
&mdio {
	switch@0 {
		compatible = "marvell,mv88e6390";
		reg = <0>;

		ports {
			#address-cells = <1>;
			#size-cells = <0>;
	
			port@0 {
				phy-handle = <phy0>;
				reg = <0>;
			};
		};

		mdio {
			compatible = "marvell,mv88e6390-external-mdio";
			#address-cells = <1>;
			#size-cells = <0>;

			phy0: phy@0 {
				reg = <0>;
			};
		};
	};
};

In both cases (your proposal) and this one, we still have a dependency
on the Ethernet switch driver being probed to create the internal and
external MDIO buses.

Thanks!
-- 
Florian
