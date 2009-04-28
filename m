From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH] net: Fix ucc_geth.c handling of phy 'interface' property.
Date: Tue, 28 Apr 2009 07:37:16 -0600
Message-ID: <fa686aa40904280637l22da819fw386034bdd93055cf@mail.gmail.com>
References: <20090427153612.5108.10877.stgit@localhost.localdomain>
	<20090427173606.GA10292@ld0162-tx32.am.freescale.net> <fa686aa40904271050kb3159cbw52c0c1dba3076f3e@mail.gmail.com>
	<20090428.021203.74435054.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: scottwood@freescale.com, Joakim.Tjernlund@transmode.se,
	afleming@freescale.com, benh@kernel.crashing.org,
	linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.30]:30877 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759059AbZD1Nhg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Apr 2009 09:37:36 -0400
Received: by yx-out-2324.google.com with SMTP id 3so311109yxj.1
        for <netdev@vger.kernel.org>; Tue, 28 Apr 2009 06:37:36 -0700 (PDT)
In-Reply-To: <20090428.021203.74435054.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 28, 2009 at 3:12 AM, David Miller <davem@davemloft.net> wro=
te:
> From: Grant Likely <grant.likely@secretlab.ca>
> Date: Mon, 27 Apr 2009 11:50:20 -0600
>
>> On Mon, Apr 27, 2009 at 11:36 AM, Scott Wood <scottwood@freescale.co=
m> wrote:
>>> On Mon, Apr 27, 2009 at 09:36:13AM -0600, Grant Likely wrote:
>>>> From: Grant Likely <grant.likely@secretlab.ca>
>>>>
>>>> Previous rework to ucc_geth.c to add of_mdio support (net: Rework
>>>> ucc_geth driver to use of_mdio infrastructure) added a block of
>>>> code which broke older openfirmware device trees which use an
>>>> 'interface' property in the phy node to describe the connection
>>>> between the MAC and the PHY. =A0This patch removes the offending b=
lurb.
>>> [snip]
>>>> =A0 =A0 =A0 prop =3D of_get_property(np, "phy-connection-type", NU=
LL);
>>>> =A0 =A0 =A0 if (!prop) {
>>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* handle interface property present i=
n old trees */
>>>> - =A0 =A0 =A0 =A0 =A0 =A0 if (!phy)
>>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENODEV;
>>>> -
>>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 prop =3D of_get_property(phy, "interfa=
ce", NULL);
>>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (prop !=3D NULL) {
>>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 phy_interface =3D enet=
_to_phy_interface[*prop];
>>>
>>> The above test only makes a difference when there is no phy node --=
 so I
>>> don't see how it was breaking device trees that had a phy node (wit=
h or
>>> without an "interface" property). =A0I can see it breaking fixed li=
nk
>>> device trees, though.
>>
>> Sorry, you're right. =A0I got myself confused when I was writing the
>> description. =A0This patch fixes breakage when using a fixed-link an=
d
>> there is no phy-connection-type property.
>
> Patch applied with commit message fixed up.

Thanks David

g.


--=20
Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
