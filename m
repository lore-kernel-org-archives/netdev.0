From: Madalin-Cristian Bucur <madalin.bucur@nxp.com>
Subject: RE: [PATCH v3 1/2] net: phy: Fix PHY AN done state machine for
 interrupt driven PHYs
Date: Thu, 30 Mar 2017 12:59:14 +0000
Message-ID: <HE1PR04MB11297FBF0E8E2739253E0A44EC340@HE1PR04MB1129.eurprd04.prod.outlook.com>
References: <1490180524-28675-1-git-send-email-rogerq@ti.com>
 <1490180524-28675-2-git-send-email-rogerq@ti.com>
 <078917ad-77a1-a722-1688-6203ae183a46@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "andrew@lunn.ch" <andrew@lunn.ch>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "kyle.roeschley@ni.com" <kyle.roeschley@ni.com>,
        "nsekhar@ti.com" <nsekhar@ti.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "stable # v4 . 9+" <stable@vger.kernel.org>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
To: Roger Quadros <rogerq@ti.com>,
        "f.fainelli@gmail.com" <f.fainelli@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0084.outbound.protection.outlook.com ([104.47.2.84]:19647
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S933173AbdC3M7T (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 30 Mar 2017 08:59:19 -0400
In-Reply-To: <078917ad-77a1-a722-1688-6203ae183a46@ti.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On March 27, 2017 2:59 PM, Roger Quadros wrote:
> The Ethernet link on an interrupt driven PHY was not coming up if the
> Ethernet cable was plugged before the Ethernet interface was brought up.
>=20
> The PHY state machine seems to be stuck from RUNNING to AN state
> with no new interrupts from the PHY. So it doesn't know when the
> PHY Auto-negotiation has been completed and doesn't transition to RUNNING
> state with ANEG done thus netif_carrier_on() is never called.
>=20
> NOTE: genphy_config_aneg() will not restart PHY Auto-negotiation of
> advertisement parameters didn't change.
>=20
> Fix this by scheduling the PHY state machine in phy_start_aneg().
> There is no way of knowing in phy.c whether auto-negotiation was
> restarted or not by the PHY driver so we just wait for the next
> poll/interrupt to update the PHY state machine.
>=20
> Fixes: 3c293f4e08b5 ("net: phy: Trigger state machine on state change and
> not polling.")
> Cc: stable <stable@vger.kernel.org> # v4.9+
> Signed-off-by: Roger Quadros <rogerq@ti.com>
> ---
> v3: Fix typo in commit message
>=20
>  drivers/net/phy/phy.c | 4 ++++
>  1 file changed, 4 insertions(+)

Tested-by: Madalin Bucur <madalin.bucur@nxp.com>
