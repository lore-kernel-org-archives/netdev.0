From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH] net: Fix ucc_geth.c handling of phy 'interface' property.
Date: Mon, 27 Apr 2009 11:50:20 -0600
Message-ID: <fa686aa40904271050kb3159cbw52c0c1dba3076f3e@mail.gmail.com>
References: <20090427153612.5108.10877.stgit@localhost.localdomain>
	<20090427173606.GA10292@ld0162-tx32.am.freescale.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>, linuxppc-dev@ozlabs.org,
	Andy Fleming <afleming@freescale.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Scott Wood <scottwood@freescale.com>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org>
In-Reply-To: <20090427173606.GA10292@ld0162-tx32.am.freescale.net>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 27, 2009 at 11:36 AM, Scott Wood <scottwood@freescale.com> wrot=
e:
> On Mon, Apr 27, 2009 at 09:36:13AM -0600, Grant Likely wrote:
>> From: Grant Likely <grant.likely@secretlab.ca>
>>
>> Previous rework to ucc_geth.c to add of_mdio support (net: Rework
>> ucc_geth driver to use of_mdio infrastructure) added a block of
>> code which broke older openfirmware device trees which use an
>> 'interface' property in the phy node to describe the connection
>> between the MAC and the PHY. =A0This patch removes the offending blurb.
> [snip]
>> =A0 =A0 =A0 prop =3D of_get_property(np, "phy-connection-type", NULL);
>> =A0 =A0 =A0 if (!prop) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* handle interface property present in old =
trees */
>> - =A0 =A0 =A0 =A0 =A0 =A0 if (!phy)
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENODEV;
>> -
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 prop =3D of_get_property(phy, "interface", N=
ULL);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (prop !=3D NULL) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 phy_interface =3D enet_to_ph=
y_interface[*prop];
>
> The above test only makes a difference when there is no phy node -- so I
> don't see how it was breaking device trees that had a phy node (with or
> without an "interface" property). =A0I can see it breaking fixed link
> device trees, though.

Sorry, you're right.  I got myself confused when I was writing the
description.  This patch fixes breakage when using a fixed-link and
there is no phy-connection-type property.

g.

-- =

Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
