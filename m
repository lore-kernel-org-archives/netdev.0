From: Madalin-Cristian Bucur <madalin.bucur@nxp.com>
Subject: Fixed link for 10G
Date: Fri, 6 Jan 2017 12:01:06 +0000
Message-ID: <AM2PR04MB11228A96940B1E409CEC6E04EC630@AM2PR04MB1122.eurprd04.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve1eur01on0078.outbound.protection.outlook.com ([104.47.1.78]:35264
        "EHLO EUR01-VE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1162912AbdAFMBJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 6 Jan 2017 07:01:09 -0500
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Florian,

I'm trying to add a fixed-link property that declares 10G speed
for a XGMII PHY and I'm encountering some issues as the fixed
link infrastructure does not seem to support this speed.

I'm using this device tree snippet (using the legacy format, but it
should not matter):

        ethernet@f2000 { /* 10GEC2 */
                fixed-link =3D <0 1 10000 0 0>;
                phy-connection-type =3D "xgmii";
        };

and I get this error:

	[    0.464238] swphy: unknown speed
	[    0.467464] fsl_mac: probe of 1af2000.ethernet failed with error -22

Looking at the code, fixed_phy_register() seems to check for speeds up
to 1G and swphy only caters 1G and lower speeds, the swphy_decode_speed()
returning -EINVAL for 10G, triggering the error printed above in
swphy_validate_state().

What would be the proper way to add support for the 10G fixed link speed?

Thank you,
Madalin
