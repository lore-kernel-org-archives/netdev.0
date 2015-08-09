From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCHv2 net-next] dsa: Support multiple MDIO busses
Date: Sun, 09 Aug 2015 11:33:55 -0700
Message-ID: <55C79D13.1050608@gmail.com>
References: <1439083745-14169-1-git-send-email-andrew@lunn.ch> <55C749FD.8050303@cogentembedded.com> <20150809142030.GB14271@lunn.ch> <55C78D52.5040401@cogentembedded.com> <20150809173517.GC11157@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f179.google.com ([209.85.214.179]:35372 "EHLO
	mail-ob0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933151AbbHISd6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Aug 2015 14:33:58 -0400
Received: by obbop1 with SMTP id op1so110297124obb.2
        for <netdev@vger.kernel.org>; Sun, 09 Aug 2015 11:33:57 -0700 (PDT)
In-Reply-To: <20150809173517.GC11157@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 08/09/15 10:35, Andrew Lunn a =C3=A9crit :
>>> The optional mii-bus properties i'm adding should be used in
>>> preference to this global one, for this switch. Keeping the names t=
he
>>> same makes sense. But i did drop the dsa prefix to indicate it is
>>> local, not global scope,
>>
>>    Dropping a vendor prefix usually means that it's (standardized)
>> common property name. I don't know where you took the "local" scope
>> thing...
>=20
> DSA has at least three levels of hierarchy. The following is the
> example from the binding documentation. There is a 'global' scope
> dsa,mii-bus =3D <&mii_bus0> in the top level, which is mandatory. Thi=
s
> patch allows optional 'local' scope mii bus to be specified at an
> individual switch level. The 'local' value, if present, will override
> the 'global' value.
>=20
> Maybe more properties should use the dsa prefix? But dsa is not a
> vendor prefix, it just refers to "Distributed Switch Architecture",
> the scheme for accessing a number of Ethernet switches connected
> together in a cluster. But as the binding has grown, this prefix has
> not been used with new properties.

Maybe it was not very smart to use the "dsa," prefixing initially, but =
I
agree with Andrew's naming of things here, we are already local to the
switch tree so dropping the prefix sounds reasonable.

>=20
>     Andrew
>=20
>         dsa@0 {
>                 compatible =3D "marvell,dsa";
>                 #address-cells =3D <2>;
>                 #size-cells =3D <0>;
>=20
>                 interrupts =3D <10>;
>                 dsa,ethernet =3D <&ethernet0>;
>                 dsa,mii-bus =3D <&mii_bus0>;
>=20
>                 switch@0 {
>                         #address-cells =3D <1>;
>                         #size-cells =3D <0>;
>                         reg =3D <16 0>;   /* MDIO address 16, switch =
0 in tree */
>=20
>                         port@0 {
>                                 reg =3D <0>;
>                                 label =3D "lan1";
>                                 phy-handle =3D <&phy0>;
>                         };
>=20
>                         port@1 {
>                                 reg =3D <1>;
>                                 label =3D "lan2";
>                         };
>=20
>                         port@5 {
>                                 reg =3D <5>;
>                                 label =3D "cpu";
>                         };
>=20
>                         switch0port6: port@6 {
>                                 reg =3D <6>;
>                                 label =3D "dsa";
>                                 link =3D <&switch1port0
>                                         &switch2port0>;
>                         };
>                 };
>=20
>                 switch@1 {
>                         #address-cells =3D <1>;
>                         #size-cells =3D <0>;
>                         reg =3D <17 1>;   /* MDIO address 17, switch =
1 in tree */
>                         mii-bus =3D <&mii_bus1>;
>=20
>                         switch1port0: port@0 {
>                                 reg =3D <0>;
>                                 label =3D "dsa";
>                                 link =3D <&switch0port6>;
>                         };
>                         switch1port1: port@1 {
>                                 reg =3D <1>;
>                                 label =3D "dsa";
>                                 link =3D <&switch2port1>;
>                         };
>                 };
>=20
>                 switch@2 {
>                         #address-cells =3D <1>;
>                         #size-cells =3D <0>;
>                         reg =3D <18 2>;   /* MDIO address 18, switch =
2 in tree */
>                         mii-bus =3D <&mii_bus1>;
>=20
>                         switch2port0: port@0 {
>                                 reg =3D <0>;
>                                 label =3D "dsa";
>                                 link =3D <&switch1port1
>                                         &switch0port6>;
>                         };
>                 };
>         };
>=20


--=20
=46lorian
