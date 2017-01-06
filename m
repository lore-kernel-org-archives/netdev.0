From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: Fixed link for 10G
Date: Fri, 6 Jan 2017 17:24:20 +0100
Message-ID: <20170106162420.GA341@lunn.ch>
References: <AM2PR04MB11228A96940B1E409CEC6E04EC630@AM2PR04MB1122.eurprd04.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Madalin-Cristian Bucur <madalin.bucur@nxp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:47488 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1758967AbdAFQYY (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 6 Jan 2017 11:24:24 -0500
Content-Disposition: inline
In-Reply-To: <AM2PR04MB11228A96940B1E409CEC6E04EC630@AM2PR04MB1122.eurprd04.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 06, 2017 at 12:01:06PM +0000, Madalin-Cristian Bucur wrote:
> Hi Florian,
> 
> I'm trying to add a fixed-link property that declares 10G speed
> for a XGMII PHY and I'm encountering some issues as the fixed
> link infrastructure does not seem to support this speed.
> 
> I'm using this device tree snippet (using the legacy format, but it
> should not matter):
> 
>         ethernet@f2000 { /* 10GEC2 */
>                 fixed-link = <0 1 10000 0 0>;
>                 phy-connection-type = "xgmii";
>         };
> 
> and I get this error:
> 
> 	[    0.464238] swphy: unknown speed
> 	[    0.467464] fsl_mac: probe of 1af2000.ethernet failed with error -22
> 
> Looking at the code, fixed_phy_register() seems to check for speeds up
> to 1G and swphy only caters 1G and lower speeds, the swphy_decode_speed()
> returning -EINVAL for 10G, triggering the error printed above in
> swphy_validate_state().
> 
> What would be the proper way to add support for the 10G fixed link speed?

Hi Madalin

I came across the same issue a couple of months ago. But i found a
different way to solve my problem.

Anyway, fixed-link emulates a PHY. It has the common PHY registers,
and sets the register values to indicate the device tree
configuration.

As you have found out, it only emulates 10/100/1000. For 10G, you need
to extend the emulation to include the 10G registers. Assuming the 10G
registers are standardised.

	  Andrew
