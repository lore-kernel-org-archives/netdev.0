From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: drivers/net/phy/dp83867.c:167: possible bad if ?
Date: Mon, 20 Jul 2015 10:40:26 -0700
Message-ID: <55AD328A.9040106@gmail.com>
References: <DUB128-W6216BE4A8E21E94EEB06DE9C850@phx.gbl> <55AD2FC6.60508@gmail.com> <55AD31E1.6010506@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Dan Murphy <dmurphy@ti.com>, David Binderman <dcb314@hotmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:34761 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754379AbbGTRmW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jul 2015 13:42:22 -0400
Received: by pdbbh15 with SMTP id bh15so59342097pdb.1
        for <netdev@vger.kernel.org>; Mon, 20 Jul 2015 10:42:22 -0700 (PDT)
In-Reply-To: <55AD31E1.6010506@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 20/07/15 10:37, Dan Murphy wrote:
> Florian
>=20
> On 07/20/2015 12:28 PM, Florian Fainelli wrote:
>> Adding Dan,
>>
>> On 20/07/15 05:37, David Binderman wrote:
>>> Hello there,
>>>
>>> drivers/net/phy/dp83867.c:167:57: warning: logical =E2=80=98or=E2=80=
=99 of collectively exhaustive tests is always true [-Wlogical-op]
>>>
>>> Source code is
>>>
>>>     if ((phydev->interface>=3D PHY_INTERFACE_MODE_RGMII_ID) ||
>>>         (phydev->interface <=3D PHY_INTERFACE_MODE_RGMII_RXID)) {
>>>
>>> Maybe
>>>
>>>     if ((phydev->interface>=3D PHY_INTERFACE_MODE_RGMII_ID) &&
>>>         (phydev->interface <=3D PHY_INTERFACE_MODE_RGMII_RXID)) {
>> Sounds like the former is the intended comparison that will make sur=
e
>> that phydev->interface is between MODE_RGMII_ID and MODE_RGMII_RXID,=
 and
>> not below or after.
> That is correct.  The internal delay only needs to be set if this is =
declared
> via the DT.  There can be one of 3 interface internal delay (RGMII_ID=
), RX internal delay (RGMII_RX_ID) or TX
> internal delay (RGMII_TX_ID).

Sorry, I meant to write the latter instead of the former here, the
current code seems to be potentially too permissive, is not it? In that
case, it seems to me like David's proposed fix is relevant.

>=20
> This internal delay is only applicable for RGMII and can be made spec=
ific to the
> board.
>=20
> The driver only needs to set the delay per the declaration in the DT.
>=20
> Dan
>=20


--=20
=46lorian
