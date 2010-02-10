From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: phy address in the device tree, vs auto probing
Date: Wed, 10 Feb 2010 12:57:07 -0700
Message-ID: <fa686aa41002101157g7c0c4134m5218d5aeacce08b1@mail.gmail.com>
References: <4dfe033d-c308-45e0-9c7e-9fc60c6cad8f@SG2EHSMHS013.ehs.local>
	<fa686aa41002100843o7a1d4160q8fb01768ad48dcf4@mail.gmail.com>
	<7d35ae9a-9ac0-46e6-8817-15315e0dcc07@SG2EHSMHS004.ehs.local>
	<fa686aa41002101014s43682e3cra55854b82a40bb5f@mail.gmail.com>
	<AE7D03BA-0763-42F3-A27B-A6214CE7249E@freescale.com> <fa686aa41002101120v56ef5e7cm64e5505cc7bedc1d@mail.gmail.com>
	<99A0D59F-3DAA-4ACD-899B-7D139E286D6D@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: John Linn <John.Linn@xilinx.com>,
	devicetree-discuss <devicetree-discuss@lists.ozlabs.org>,
	netdev <netdev@vger.kernel.org>,
	Scott Wood <scottwood@freescale.com>
To: Andy Fleming <afleming@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f173.google.com ([209.85.211.173]:53793 "EHLO
	mail-yw0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751322Ab0BJT53 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Feb 2010 14:57:29 -0500
Received: by ywh3 with SMTP id 3so442371ywh.22
        for <netdev@vger.kernel.org>; Wed, 10 Feb 2010 11:57:28 -0800 (PST)
In-Reply-To: <99A0D59F-3DAA-4ACD-899B-7D139E286D6D@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 10, 2010 at 12:46 PM, Andy Fleming <afleming@freescale.com>=
 wrote:
>
> On Feb 10, 2010, at 1:20 PM, Grant Likely wrote:
>
>> On Wed, Feb 10, 2010 at 11:40 AM, Fleming Andy-AFLEMING
>> <afleming@freescale.com> wrote:
>>> I don't think it's necessary that only one phy node is there. =A0I =
don't think
>>> the of mdio layer should set policy, here. =A0Some drivers hard cod=
e their
>>> addresses. =A0Some drivers assume (foolishly, I think) that the PHY=
s are in
>>> order. =A0Many assume there's only one PHY. =A0I think the mdio dri=
ver should
>>> set policy, so of_mdio should just allow for PHYs to be probed. =A0=
I'm
>>> actually not sure that requires any changes. =A0Quite possibly this=
 just means
>>> that of_mdio is not appropriate for such a driver. =A0 The standard=
 PHY code
>>> supports this sort of thing.
>>
>> That still doesn't solve the problem of matching PHYs to MACs.
>>
>> Consider this example: =A02 MACs, 2 PHYs. =A0mac_a--> phy_a and mac_=
b -->
>> phy_b. =A0Both phys on the same mdio bus, described thus:
>>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 eth_a: ethernet@81000000 {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 #address-cells =3D <1>;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 #size-cells =3D <1>;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 phy-handle =3D <&phy_a>;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mdio {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 #address=
-cells =3D <1>;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 #size-ce=
lls =3D <0>;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 phy_a: p=
hy_a {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 } ;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 phy_b: p=
hy_b {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 } ;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 } ;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 } ;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 eth_b: ethernet@82000000 {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 #address-cells =3D <1>;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 #size-cells =3D <1>;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 phy-handle =3D <&phy_b>;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 } ;
>>
>> In this example, the kernel knows it has two phys, and probing
>> confirms this (say at phy addresses 3 and 7). =A0How does the kernel
>> know which address phy_a responds to?
>
>
> There's no way to know.

Which is why I'm saying that when the phy address is unknown, the
binding should only allow for a single phy node.  We're talking about
how to accurately describe the platform, not how the implementation
should work.  The mdio/of_mdio changes are Linux kernel implementation
details.

> =A0That's what I'm saying. =A0We shouldn't modify the of_mdio code to=
 say which PHY is which. =A0Instead, we have the MDIO/ethernet code do =
that. =A0And maybe this means that they can't use of_mdio. =A0Or maybe =
we need to devise a scheme so you can specify those PHYs, but delay ass=
ociating them with an address until later.

Same problem.  even if phys are probed, the kernel doesn't know which
MAC to attach each to.  If the solution is to hard coded it into the
driver, then that is a different problem scenario than John is trying
to solve.

g.

--=20
Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
