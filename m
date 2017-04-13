From: Juergen Borleis <jbe@pengutronix.de>
Subject: [PATCHv5] net: dsa: add SMSC/Microchip LAN9303 three port ethernet switch driver
Date: Thu, 13 Apr 2017 09:33:39 +0200
Message-ID: <20170413073343.8067-1-jbe@pengutronix.de>
Cc: linux-kernel@vger.kernel.org, f.fainelli@gmail.com,
        kernel@pengutronix.de, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:52861 "EHLO
        metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1756397AbdDMHdr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Apr 2017 03:33:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The LAN9303 is a three port 10/100 ethernet switch with integrated phys
for the two external ethernet ports. The third port is an RMII/MII
interface to a host master network interface (e.g. fixed link).

While the LAN9303 device itself supports offload packet processing, this
driver does not make use of it yet. This driver just configures the device
to provide two separate network interfaces (which is the default state of
a DSA device).

Please note: the "MDIO managed mode" driver part isn't tested yet. I have
used and tested the "I2C managed mode" only.

Changes in v5:

- missing include file to 'net/dsa/tag_lan9303.c' added

Changes in v4:

- rebased on net-next, 'net/dsa/tag_lan9303.c' adapted to changed API

Changes in v3:

- 'ds_to_lan9303()' removed
- special PHY reg MII_LAN911X_SPECIAL_CONTROL_STATUS mapping removed
- compatible strings for I2C and MDIO are now different
- MDIO-managed-mode devicetree binding added (still compile time tested only)

Changes in v2:

- code moved to 'drivers/net/dsa'
- timeouts in completion wait loops
- macros instead of various magic numbers
- development code removed
- devicetree property names changed
- devicetree example adapted
- tried to avoid to mix 'switching' and 'forwarding'...

Comments are welcome.

jb
