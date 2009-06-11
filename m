From: Subrata Modak <subrata@linux.vnet.ibm.com>
Subject: [PATCH][Resend 2][BUILD FAILURE 04/04] Next June 04:PPC64 randconfig [drivers/net/ucc_geth.o]
Date: Thu, 11 Jun 2009 09:07:05 +0530
Message-ID: <20090611033705.20842.75501.sendpatchset@subratamodak.linux.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Sachin P Sant <sachinp@linux.vnet.ibm.com>,
	Linux-Next <linux-next@vger.kernel.org>,
	Linux-Kernel <linux-kernel@vger.kernel.org>,
	Subrata Modak <subrata@linux.vnet.ibm.com>,
	Balbir Singh <balbir@linux.vnet.ibm.com>,
	Linuxppc-dev <Linuxppc-dev@ozlabs.org>
To: Tony Breeds <tony@bakeyournoodle.com>, netdev@vger.kernel.org,
	michael@ellerman.id.au, Li Yang <leoli@freescale.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	Nathan Lynch <ntl@pobox.com>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Nathan,

>On Wed, 2009-06-10 at 21:28 -0500, Nathan Lynch wrote:
>Subrata Modak <subrata@linux.vnet.ibm.com> writes:
>=20
> > On Thu, 2009-06-11 at 11:05 +1000, Stephen Rothwell wrote:
> >> Hi Subrata,
> >>=20
> >> On Wed, 10 Jun 2009 23:13:23 +0530 Subrata Modak <subrata@linux.vn=
et.ibm.com> wrote:
> >> >
> >> >  	/* Find the TBI PHY.  If it's not there, we don't support SGMI=
I */
> >> > -	ph =3D of_get_property(np, "tbi-handle", NULL);
> >> > +	ph =3D (phandle *)of_get_property(np, "tbi-handle", NULL);
> >>=20
> >> You don't need this cast because of_get_property() returns "void *=
".
> >
> > Stephen,
> >
> > True. But without this gcc complains:
> >
> > CC [M]  drivers/net/ucc_geth.o
> > drivers/net/ucc_geth.c: In function =E2=80=98ucc_geth_probe=E2=80=99=
:
> > drivers/net/ucc_geth.c:3824: warning: assignment discards qualifier=
s
> > from pointer target type
>=20
> ph should be declared const phandle *.  Look at other uses of
> of_get_property.
>

Ok fine. Here is a revised patch again.

Subject: [PATCH][Resend 2][BUILD FAILURE 04/04] Next June 04:PPC64 rand=
config [drivers/net/ucc_geth.o]
Reference(s):
http://lkml.org/lkml/2009/6/4/241,
http://lkml.org/lkml/2009/6/10/338,

=46ix the following build error:

drivers/net/ucc_geth.c: In function bucc_geth_probeb:
drivers/net/ucc_geth.c:3822: error: 'ph' undeclared (first use in this =
function)
drivers/net/ucc_geth.c:3822: error: (Each undeclared identifier is repo=
rted only once
drivers/net/ucc_geth.c:3822: error: for each function it appears in.)
drivers/net/ucc_geth.c:3832: error: 'mdio' undeclared (first use in thi=
s function)
make[2]: *** [drivers/net/ucc_geth.o] Error 1

Signed-off-by: Subrata Modak <subrata@linux.vnet.ibm.com>
---

--- linux-2.6.30-rc8/drivers/net/ucc_geth.c.orig	2009-06-10 11:58:39.00=
0000000 -0500
+++ linux-2.6.30-rc8/drivers/net/ucc_geth.c	2009-06-10 22:28:13.0000000=
00 -0500
@@ -3595,6 +3595,8 @@ static const struct net_device_ops ucc_g
=20
 static int ucc_geth_probe(struct of_device* ofdev, const struct of_dev=
ice_id *match)
 {
+	struct device_node *mdio;
+	const phandle *ph;
 	struct device *device =3D &ofdev->dev;
 	struct device_node *np =3D ofdev->node;
 	struct net_device *dev =3D NULL;

---
Regards--
Subrata
