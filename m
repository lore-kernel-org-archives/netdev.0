From: Dan Murphy <dmurphy@ti.com>
Subject: Re: drivers/net/phy/dp83867.c:167: possible bad if ?
Date: Mon, 20 Jul 2015 12:52:02 -0500
Message-ID: <55AD3542.7080906@ti.com>
References: <DUB128-W6216BE4A8E21E94EEB06DE9C850@phx.gbl> <55AD2FC6.60508@gmail.com> <55AD31E1.6010506@ti.com> <55AD328A.9040106@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Florian Fainelli <f.fainelli@gmail.com>,
	David Binderman <dcb314@hotmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:34813 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756778AbbGTRwF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Jul 2015 13:52:05 -0400
In-Reply-To: <55AD328A.9040106@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/20/2015 12:40 PM, Florian Fainelli wrote:
> On 20/07/15 10:37, Dan Murphy wrote:
>> Florian
>>
>> On 07/20/2015 12:28 PM, Florian Fainelli wrote:
>>> Adding Dan,
>>>
>>> On 20/07/15 05:37, David Binderman wrote:
>>>> Hello there,
>>>>
>>>> drivers/net/phy/dp83867.c:167:57: warning: logical =E2=80=98or=E2=80=
=99 of collectively exhaustive tests is always true [-Wlogical-op]
>>>>
>>>> Source code is
>>>>
>>>>     if ((phydev->interface>=3D PHY_INTERFACE_MODE_RGMII_ID) ||
>>>>         (phydev->interface <=3D PHY_INTERFACE_MODE_RGMII_RXID)) {
>>>>
>>>> Maybe
>>>>
>>>>     if ((phydev->interface>=3D PHY_INTERFACE_MODE_RGMII_ID) &&
>>>>         (phydev->interface <=3D PHY_INTERFACE_MODE_RGMII_RXID)) {
>>> Sounds like the former is the intended comparison that will make su=
re
>>> that phydev->interface is between MODE_RGMII_ID and MODE_RGMII_RXID=
, and
>>> not below or after.
>> That is correct.  The internal delay only needs to be set if this is=
 declared
>> via the DT.  There can be one of 3 interface internal delay (RGMII_I=
D), RX internal delay (RGMII_RX_ID) or TX
>> internal delay (RGMII_TX_ID).
> Sorry, I meant to write the latter instead of the former here, the
> current code seems to be potentially too permissive, is not it? In th=
at
> case, it seems to me like David's proposed fix is relevant.

The proposed fix is logically correct.  And it matches the code for
phy_interface_is_rgmii with the '&&'.

Did you want me to patch and test?

Dan

>
>> This internal delay is only applicable for RGMII and can be made spe=
cific to the
>> board.
>>
>> The driver only needs to set the delay per the declaration in the DT=
=2E
>>
>> Dan
>>
>


--=20
------------------
Dan Murphy
