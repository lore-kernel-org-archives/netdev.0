From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: phy address in the device tree, vs auto probing
Date: Wed, 10 Feb 2010 11:14:47 -0700
Message-ID: <fa686aa41002101014s43682e3cra55854b82a40bb5f@mail.gmail.com>
References: <4dfe033d-c308-45e0-9c7e-9fc60c6cad8f@SG2EHSMHS013.ehs.local>
	<fa686aa41002100843o7a1d4160q8fb01768ad48dcf4@mail.gmail.com>
	<7d35ae9a-9ac0-46e6-8817-15315e0dcc07@SG2EHSMHS004.ehs.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: devicetree-discuss <devicetree-discuss@lists.ozlabs.org>,
	netdev <netdev@vger.kernel.org>,
	Andy Fleming <afleming@freescale.com>,
	Scott Wood <scottwood@freescale.com>
To: John Linn <John.Linn@xilinx.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f224.google.com ([209.85.217.224]:42167 "EHLO
	mail-gx0-f224.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753069Ab0BJSPJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Feb 2010 13:15:09 -0500
Received: by gxk24 with SMTP id 24so292726gxk.1
        for <netdev@vger.kernel.org>; Wed, 10 Feb 2010 10:15:07 -0800 (PST)
In-Reply-To: <7d35ae9a-9ac0-46e6-8817-15315e0dcc07@SG2EHSMHS004.ehs.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 10, 2010 at 9:52 AM, John Linn <John.Linn@xilinx.com> wrote=
:
>> -----Original Message-----
>> From: glikely@secretlab.ca [mailto:glikely@secretlab.ca] On Behalf O=
f Grant Likely
>> Sent: Wednesday, February 10, 2010 9:44 AM
>> To: John Linn; devicetree-discuss; netdev
>> Subject: Re: phy address in the device tree, vs auto probing
>>
>> (cc'ing devicetree-discuss and netdev mailing lists)
>>
>> On Tue, Feb 9, 2010 at 4:23 PM, John Linn <John.Linn@xilinx.com> wro=
te:
>> > Hi Grant,
>> >
>> > I notice that the OF driver for the mdio bus is not doing auto pro=
bing.
>> >
>> > As we start putting in the phy layer in the emac drivers, the devi=
ce
>> > trees tend to have the phy address in them, but we're not sure we =
really
>> > like that.
>> >
>> > We really think that being able to let the kernel find the phy add=
ress
>> > is a big benefit, otherwise this is one other piece of info the us=
er has
>> > to know and get right.
>> >
>> > Am I missing something here?
>>
>> No, you're not really missing something, but there is an inherent
>> complexity in what you're wanting to do. =A0Like i2c, MDIO is one of
>> those busses that is hard to probe reliable. =A0Some PHYs respond on
>> more than one address, and there is no way to determine which MAC a
>> PHY is wired up to. =A0Many PHYs can live on a single MDIO bus. =A0M=
ACs
>> with their own MDIO busses may still get wired to a PHY on a differe=
nt
>> bus.
>>
>> In the simple case where there is a one:one:one relationship between
>> MAC, MDIO bus and PHY, then it should be okay to probe the PHY,
>> correct? =A0The question then must be asked; how does the kernel
>> determine that it can use the simple case? =A0Nobody has yet defined=
 a
>> way to describe that in the device tree; mostly because nobody has
>> needed to yet.
>>
>> So, it is possible to do what you want, but you need a way to
>> *explicitly* ask for that behaviour. =A0ie, some way to indicate in =
a
>> MAC node which MDIO bus the phy is on, and that the phy needs to be
>> probed for. =A0I think this should only be an option when the MDIO b=
us
>> has only one PHY. =A0Come up with a proposal and post it to the
>> devicetree-discuss mailing list.
>
> Here's a couple ideas. See what everyone thinks as I'm not stuck on e=
ither.
>
> Thanks,
> John
>
> 1. What if we just don't specific a phy address with a reg property w=
hich would specify to auto probe it and find the phy as illustrated bel=
ow?
>
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Ethernet_MAC: ethernet@81000000 {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0#address-cells =3D <1>=
;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0#size-cells =3D <1>;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0phy-handle =3D <&phy0>=
;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mdio {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0#addre=
ss-cells =3D <1>;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0#size-=
cells =3D <0>;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0phy0: =
phy@7 {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0} ;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0} ;
>
> 2. Or a special value (-1 or something not 0 - 31) in the phy address=
 that specifies to auto probe as illustrated below.
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0phy0: =
phy@7 {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0reg =3D <-1>;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0} ;

I don't like abusing the reg property in this way.  I wonder if a new
empty property would be a better way to indicate this.  Maybe
"phy-probe-address;"?  It would also be important to specify in the
binding that only one phy node is allowed when phy-probe-address is
used.

Also, without a known reg the 'phy@7' name is inaccurate.  Drop the @7.

Scott, Andy: any thoughts?

g.

--=20
Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
