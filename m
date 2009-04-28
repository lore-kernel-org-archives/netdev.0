From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Fix ucc_geth.c handling of phy 'interface'
 property.
Date: Tue, 28 Apr 2009 02:12:03 -0700 (PDT)
Message-ID: <20090428.021203.74435054.davem@davemloft.net>
References: <20090427153612.5108.10877.stgit@localhost.localdomain>
	<20090427173606.GA10292@ld0162-tx32.am.freescale.net>
	<fa686aa40904271050kb3159cbw52c0c1dba3076f3e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: scottwood@freescale.com, Joakim.Tjernlund@transmode.se,
	afleming@freescale.com, benh@kernel.crashing.org,
	linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
To: grant.likely@secretlab.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45242
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754164AbZD1JMK convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Apr 2009 05:12:10 -0400
In-Reply-To: <fa686aa40904271050kb3159cbw52c0c1dba3076f3e@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Grant Likely <grant.likely@secretlab.ca>
Date: Mon, 27 Apr 2009 11:50:20 -0600

> On Mon, Apr 27, 2009 at 11:36 AM, Scott Wood <scottwood@freescale.com=
> wrote:
>> On Mon, Apr 27, 2009 at 09:36:13AM -0600, Grant Likely wrote:
>>> From: Grant Likely <grant.likely@secretlab.ca>
>>>
>>> Previous rework to ucc_geth.c to add of_mdio support (net: Rework
>>> ucc_geth driver to use of_mdio infrastructure) added a block of
>>> code which broke older openfirmware device trees which use an
>>> 'interface' property in the phy node to describe the connection
>>> between the MAC and the PHY. =A0This patch removes the offending bl=
urb.
>> [snip]
>>> =A0 =A0 =A0 prop =3D of_get_property(np, "phy-connection-type", NUL=
L);
>>> =A0 =A0 =A0 if (!prop) {
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* handle interface property present in=
 old trees */
>>> - =A0 =A0 =A0 =A0 =A0 =A0 if (!phy)
>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENODEV;
>>> -
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 prop =3D of_get_property(phy, "interfac=
e", NULL);
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (prop !=3D NULL) {
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 phy_interface =3D enet_=
to_phy_interface[*prop];
>>
>> The above test only makes a difference when there is no phy node -- =
so I
>> don't see how it was breaking device trees that had a phy node (with=
 or
>> without an "interface" property). =A0I can see it breaking fixed lin=
k
>> device trees, though.
>=20
> Sorry, you're right.  I got myself confused when I was writing the
> description.  This patch fixes breakage when using a fixed-link and
> there is no phy-connection-type property.

Patch applied with commit message fixed up.
