From: Dan Murphy <dmurphy@ti.com>
Subject: Re: drivers/net/phy/dp83867.c:167: possible bad if ?
Date: Mon, 20 Jul 2015 12:37:37 -0500
Message-ID: <55AD31E1.6010506@ti.com>
References: <DUB128-W6216BE4A8E21E94EEB06DE9C850@phx.gbl> <55AD2FC6.60508@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Florian Fainelli <f.fainelli@gmail.com>,
	David Binderman <dcb314@hotmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:34764 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751534AbbGTRhk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Jul 2015 13:37:40 -0400
In-Reply-To: <55AD2FC6.60508@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46lorian

On 07/20/2015 12:28 PM, Florian Fainelli wrote:
> Adding Dan,
>
> On 20/07/15 05:37, David Binderman wrote:
>> Hello there,
>>
>> drivers/net/phy/dp83867.c:167:57: warning: logical =E2=80=98or=E2=80=
=99 of collectively exhaustive tests is always true [-Wlogical-op]
>>
>> Source code is
>>
>>     if ((phydev->interface>=3D PHY_INTERFACE_MODE_RGMII_ID) ||
>>         (phydev->interface <=3D PHY_INTERFACE_MODE_RGMII_RXID)) {
>>
>> Maybe
>>
>>     if ((phydev->interface>=3D PHY_INTERFACE_MODE_RGMII_ID) &&
>>         (phydev->interface <=3D PHY_INTERFACE_MODE_RGMII_RXID)) {
> Sounds like the former is the intended comparison that will make sure
> that phydev->interface is between MODE_RGMII_ID and MODE_RGMII_RXID, =
and
> not below or after.
That is correct.  The internal delay only needs to be set if this is de=
clared
via the DT.  There can be one of 3 interface internal delay (RGMII_ID),=
 RX internal delay (RGMII_RX_ID) or TX
internal delay (RGMII_TX_ID).

This internal delay is only applicable for RGMII and can be made specif=
ic to the
board.

The driver only needs to set the delay per the declaration in the DT.

Dan

--=20
------------------
Dan Murphy
