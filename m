From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: phy address in the device tree, vs auto probing
Date: Wed, 10 Feb 2010 12:20:14 -0700
Message-ID: <fa686aa41002101120v56ef5e7cm64e5505cc7bedc1d@mail.gmail.com>
References: <4dfe033d-c308-45e0-9c7e-9fc60c6cad8f@SG2EHSMHS013.ehs.local>
	<fa686aa41002100843o7a1d4160q8fb01768ad48dcf4@mail.gmail.com>
	<7d35ae9a-9ac0-46e6-8817-15315e0dcc07@SG2EHSMHS004.ehs.local>
	<fa686aa41002101014s43682e3cra55854b82a40bb5f@mail.gmail.com>
	<AE7D03BA-0763-42F3-A27B-A6214CE7249E@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: John Linn <John.Linn@xilinx.com>,
	devicetree-discuss <devicetree-discuss@lists.ozlabs.org>,
	netdev <netdev@vger.kernel.org>,
	Scott Wood <scottwood@freescale.com>
To: Fleming Andy-AFLEMING <afleming@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f204.google.com ([209.85.210.204]:59925 "EHLO
	mail-yx0-f204.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751965Ab0BJTUg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Feb 2010 14:20:36 -0500
Received: by yxe42 with SMTP id 42so364833yxe.22
        for <netdev@vger.kernel.org>; Wed, 10 Feb 2010 11:20:35 -0800 (PST)
In-Reply-To: <AE7D03BA-0763-42F3-A27B-A6214CE7249E@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 10, 2010 at 11:40 AM, Fleming Andy-AFLEMING
<afleming@freescale.com> wrote:
>
>
> On Feb 10, 2010, at 12:15, "Grant Likely" <grant.likely@secretlab.ca>=
 wrote:
>
>> On Wed, Feb 10, 2010 at 9:52 AM, John Linn <John.Linn@xilinx.com> wr=
ote:
>>>>
>>>> -----Original Message-----
>>>> From: glikely@secretlab.ca [mailto:glikely@secretlab.ca] On Behalf=
 Of
>>>> Grant Likely
>>>> Sent: Wednesday, February 10, 2010 9:44 AM
>>>> To: John Linn; devicetree-discuss; netdev
>>>> Subject: Re: phy address in the device tree, vs auto probing
>>>>
>>>> (cc'ing devicetree-discuss and netdev mailing lists)
>>>>
>>>> On Tue, Feb 9, 2010 at 4:23 PM, John Linn <John.Linn@xilinx.com> w=
rote:
>>>>>
>>>>> Hi Grant,
>>>>>
>>>>> I notice that the OF driver for the mdio bus is not doing auto pr=
obing.
>>>>>
>>>>> As we start putting in the phy layer in the emac drivers, the dev=
ice
>>>>> trees tend to have the phy address in them, but we're not sure we
>>>>> really
>>>>> like that.
>>>>>
>>>>> We really think that being able to let the kernel find the phy ad=
dress
>>>>> is a big benefit, otherwise this is one other piece of info the u=
ser
>>>>> has
>>>>> to know and get right.
>>>>>
>>>>> Am I missing something here?
>>>>
>>>> No, you're not really missing something, but there is an inherent
>>>> complexity in what you're wanting to do. =A0Like i2c, MDIO is one =
of
>>>> those busses that is hard to probe reliable. =A0Some PHYs respond =
on
>>>> more than one address, and there is no way to determine which MAC =
a
>>>> PHY is wired up to. =A0Many PHYs can live on a single MDIO bus. =A0=
MACs
>>>> with their own MDIO busses may still get wired to a PHY on a diffe=
rent
>>>> bus.
>>>>
>>>> In the simple case where there is a one:one:one relationship betwe=
en
>>>> MAC, MDIO bus and PHY, then it should be okay to probe the PHY,
>>>> correct? =A0The question then must be asked; how does the kernel
>>>> determine that it can use the simple case? =A0Nobody has yet defin=
ed a
>>>> way to describe that in the device tree; mostly because nobody has
>>>> needed to yet.
>>>>
>>>> So, it is possible to do what you want, but you need a way to
>>>> *explicitly* ask for that behaviour. =A0ie, some way to indicate i=
n a
>>>> MAC node which MDIO bus the phy is on, and that the phy needs to b=
e
>>>> probed for. =A0I think this should only be an option when the MDIO=
 bus
>>>> has only one PHY. =A0Come up with a proposal and post it to the
>>>> devicetree-discuss mailing list.
>>>
>>> Here's a couple ideas. See what everyone thinks as I'm not stuck on
>>> either.
>>>
>>> Thanks,
>>> John
>>>
>>> 1. What if we just don't specific a phy address with a reg property=
 which
>>> would specify to auto probe it and find the phy as illustrated belo=
w?
>>>
>>>
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 Ethernet_MAC: ethernet@81000000 {
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 #address-cells =3D <1>;
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 #size-cells =3D <1>;
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 phy-handle =3D <&phy0>;
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mdio {
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 #addres=
s-cells =3D <1>;
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 #size-c=
ells =3D <0>;
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 phy0: p=
hy@7 {
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 } ;
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 } ;
>>>
>>> 2. Or a special value (-1 or something not 0 - 31) in the phy addre=
ss
>>> that specifies to auto probe as illustrated below.
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 phy0: p=
hy@7 {
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 reg =3D <-1>;
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 } ;
>>
>> I don't like abusing the reg property in this way. =A0I wonder if a =
new
>> empty property would be a better way to indicate this. =A0Maybe
>> "phy-probe-address;"? =A0It would also be important to specify in th=
e
>> binding that only one phy node is allowed when phy-probe-address is
>> used.
>
> I don't think it's necessary that only one phy node is there. =A0I do=
n't think
> the of mdio layer should set policy, here. =A0Some drivers hard code =
their
> addresses. =A0Some drivers assume (foolishly, I think) that the PHYs =
are in
> order. =A0Many assume there's only one PHY. =A0I think the mdio drive=
r should
> set policy, so of_mdio should just allow for PHYs to be probed. =A0I'=
m
> actually not sure that requires any changes. =A0Quite possibly this j=
ust means
> that of_mdio is not appropriate for such a driver. =A0 The standard P=
HY code
> supports this sort of thing.

That still doesn't solve the problem of matching PHYs to MACs.

Consider this example:  2 MACs, 2 PHYs.  mac_a--> phy_a and mac_b -->
phy_b.  Both phys on the same mdio bus, described thus:

               eth_a: ethernet@81000000 {
                       #address-cells =3D <1>;
                       #size-cells =3D <1>;
                       phy-handle =3D <&phy_a>;
                       mdio {
                               #address-cells =3D <1>;
                               #size-cells =3D <0>;
                               phy_a: phy_a {
                               } ;
                               phy_b: phy_b {
                               } ;
                       } ;
               } ;
               eth_b: ethernet@82000000 {
                       #address-cells =3D <1>;
                       #size-cells =3D <1>;
                       phy-handle =3D <&phy_b>;
               } ;

In this example, the kernel knows it has two phys, and probing
confirms this (say at phy addresses 3 and 7).  How does the kernel
know which address phy_a responds to?

g.

--=20
Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
