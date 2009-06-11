From: Subrata Modak <subrata@linux.vnet.ibm.com>
Subject: [PATCH][Resend][BUILD FAILURE 04/04] Next June 04:PPC64 randconfig [drivers/net/ucc_geth.o]
Date: Thu, 11 Jun 2009 07:43:19 +0530
Message-ID: <20090611021319.12649.84902.sendpatchset@subratamodak.linux.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Sachin P Sant <sachinp@linux.vnet.ibm.com>,
	Linux-Next <linux-next@vger.kernel.org>,
	Linux-Kernel <linux-kernel@vger.kernel.org>,
	Subrata Modak <subrata@linux.vnet.ibm.com>,
	Balbir Singh <balbir@linux.vnet.ibm.com>,
	Linuxppc-dev <Linuxppc-dev@ozlabs.org>
To: michael@ellerman.id.au, netdev@vger.kernel.org,
	Li Yang <leoli@freescale.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:58544 "EHLO e3.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754873AbZFKCNY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Jun 2009 22:13:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Michael,

>On Thu, 2009-06-11 at 12:03 +1000, Michael Ellerman wrote:
>On Thu, 2009-06-11 at 07:26 +0530, Subrata Modak wrote:
> > On Thu, 2009-06-11 at 11:05 +1000, Stephen Rothwell wrote:
> > > Hi Subrata,
> > >=20
> > > On Wed, 10 Jun 2009 23:13:23 +0530 Subrata Modak <subrata@linux.v=
net.ibm.com> wrote:
> > > >
> > > >  	/* Find the TBI PHY.  If it's not there, we don't support SGM=
II */
> > > > -	ph =3D of_get_property(np, "tbi-handle", NULL);
> > > > +	ph =3D (phandle *)of_get_property(np, "tbi-handle", NULL);
> > >=20
> > > You don't need this cast because of_get_property() returns "void =
*".
> >=20
> > Stephen,
> >=20
> > True. But without this gcc complains:
> >=20
> > CC [M]  drivers/net/ucc_geth.o
> > drivers/net/ucc_geth.c: In function =E2=80=98ucc_geth_probe=E2=80=99=
:
> > drivers/net/ucc_geth.c:3824: warning: assignment discards qualifier=
s from pointer target type
>                                                            ^^^^^^^^^^=
^
>=20
> And what does that warning actually mean?
>=20
> Your cast actually introduces a bug.
>

Ok fine. Here is a revised patch.

Subject: [PATCH][Resend][BUILD FAILURE 04/04] Next June 04:PPC64 randco=
nfig [drivers/net/ucc_geth.o]
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
+++ linux-2.6.30-rc8/drivers/net/ucc_geth.c	2009-06-10 20:53:25.0000000=
00 -0500
@@ -3595,6 +3595,8 @@ static const struct net_device_ops ucc_g
=20
 static int ucc_geth_probe(struct of_device* ofdev, const struct of_dev=
ice_id *match)
 {
+	struct device_node *mdio;
+	phandle *ph;
 	struct device *device =3D &ofdev->dev;
 	struct device_node *np =3D ofdev->node;
 	struct net_device *dev =3D NULL;

---
Regards--
Subrata

> cheers
