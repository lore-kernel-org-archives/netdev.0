From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: axienet: add of_phy_connect call for XAE_PHY_TYPE_MII case
Date: Tue, 04 Jul 2017 09:24:03 -0700
Message-ID: <6A2BD6D6-9CBB-4BDD-BF28-F0BF10DB454C@gmail.com>
References: <20170630092541.27234-1-alvaro.gamez@hazent.com> <425aed84-a1b6-b8da-5989-3bef5a03ead4@gmail.com> <20170702101914.5nk27r2h754qzthe@collins.gmr.ssr.upm.es>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: Anirudha Sarangi <anirudh@xilinx.com>,
        John Linn <John.Linn@xilinx.com>,
        Michal Simek <michal.simek@xilinx.com>,
        =?ISO-8859-1?Q?S=F6ren_Brinkmann?= <soren.brinkmann@xilinx.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Alvaro Gamez Machado <alvaro.gamez@hazent.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f67.google.com ([209.85.218.67]:36472 "EHLO
        mail-oi0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752437AbdGDQYJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Jul 2017 12:24:09 -0400
In-Reply-To: <20170702101914.5nk27r2h754qzthe@collins.gmr.ssr.upm.es>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On July 2, 2017 3:19:14 AM PDT, Alvaro Gamez Machado <alvaro=2Egamez@hazent=
=2Ecom> wrote:
>On Fri, Jun 30, 2017 at 10:30:38AM -0700, Florian Fainelli wrote:
>> On 06/30/2017 02:25 AM, Alvaro Gamez Machado wrote:
>> >  	if (lp->phy_node) {
>> > -		if (lp->phy_type =3D=3D XAE_PHY_TYPE_GMII) {
>> > +		if (lp->phy_type =3D=3D XAE_PHY_TYPE_MII) {
>> > +			phydev =3D of_phy_connect(lp->ndev, lp->phy_node,
>> > +						axienet_adjust_link, 0,
>> > +						PHY_INTERFACE_MODE_MII);
>> > +		} else if (lp->phy_type =3D=3D XAE_PHY_TYPE_GMII) {
>> >  			phydev =3D of_phy_connect(lp->ndev, lp->phy_node,
>> >  						axienet_adjust_link, 0,
>> >  						PHY_INTERFACE_MODE_GMII);
>>=20
>> Seems like this could be simplified even further if the values of
>> lp->phy_type directly mapped to those of phy_interface_t=2E
>
>Sadly, that's not the case=2E PHY_INTERFACE_MODE_* belong to a enum of
>twenty
>different values, of which only _MII and _GMII overlap with XAW_PHY_*
>values, but XAE_PHY_TYPE_RGMII_2_0 doesn't match
>PHY_INTERFACE_MODE_RGMII_ID=2E

There are four different rgmii types to account for rx or tx delay, is not=
 there one that really matches? If the driver is using of_get_phy_mode() to=
 retrieve the standard 'phy-mode' / 'phy-connection-type' values then this =
internal representation is not needed anymore=2E

--=20
Florian
