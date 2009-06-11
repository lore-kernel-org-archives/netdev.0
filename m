From: Tony Breeds <tony@bakeyournoodle.com>
Subject: Re: [PATCH] Re:[BUILD FAILURE 04/04] Next June 04:PPC64 randconfig
	[drivers/net/ucc_geth.o]
Date: Thu, 11 Jun 2009 12:22:01 +1000
Message-ID: <20090611022201.GI16602@bilbo.ozlabs.org>
References: <20090610174323.28045.70169.sendpatchset@subratamodak.linux.ibm.com> <20090611110523.1fd56a41.sfr@canb.auug.org.au> <1244685364.6494.14.camel@subratamodak.linux.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Rothwell <sfr@canb.auug.org.au>, netdev@vger.kernel.org,
	Li Yang <leoli@freescale.com>,
	Sachin P Sant <sachinp@linux.vnet.ibm.com>,
	Linuxppc-dev <Linuxppc-dev@ozlabs.org>,
	Linux-Next <linux-next@vger.kernel.org>,
	Linux-Kernel <linux-kernel@vger.kernel.org>,
	Balbir Singh <balbir@linux.vnet.ibm.com>
To: Subrata Modak <subrata@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bilbo.ozlabs.org ([203.10.76.25]:50398 "EHLO bilbo.ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753383AbZFKCV7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Jun 2009 22:21:59 -0400
Content-Disposition: inline
In-Reply-To: <1244685364.6494.14.camel@subratamodak.linux.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 11, 2009 at 07:26:04AM +0530, Subrata Modak wrote:
> On Thu, 2009-06-11 at 11:05 +1000, Stephen Rothwell wrote:
> > Hi Subrata,
> >=20
> > On Wed, 10 Jun 2009 23:13:23 +0530 Subrata Modak <subrata@linux.vne=
t.ibm.com> wrote:
> > >
> > >  	/* Find the TBI PHY.  If it's not there, we don't support SGMII=
 */
> > > -	ph =3D of_get_property(np, "tbi-handle", NULL);
> > > +	ph =3D (phandle *)of_get_property(np, "tbi-handle", NULL);
> >=20
> > You don't need this cast because of_get_property() returns "void *"=
=2E
>=20
> Stephen,
>=20
> True. But without this gcc complains:
>=20
> CC [M]  drivers/net/ucc_geth.o
> drivers/net/ucc_geth.c: In function =E2=80=98ucc_geth_probe=E2=80=99:
> drivers/net/ucc_geth.c:3824: warning: assignment discards qualifiers
> from pointer target type
>=20
> Else gcc just builds fine:
>=20
> CC [M]  drivers/net/ucc_geth.o
>=20
> This is an just an extra caution to fix both the build and warning
> regression(s).

ph needs to be const.

I think the following untested (and hence un-signed-off-by) patch is cl=
oser,
however I also think that the whole SGMII setup code could use the vari=
ous OF
helper functions better :)

diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index e2f2e91..796253d 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -3603,6 +3603,7 @@ static int ucc_geth_probe(struct of_device* ofdev=
, const struct of_device_id *ma
 	struct resource res;
 	struct device_node *phy;
 	int err, ucc_num, max_speed =3D 0;
+	const phandle *ph;
 	const u32 *fixed_link;
 	const unsigned int *prop;
 	const char *sprop;
@@ -3821,7 +3822,7 @@ static int ucc_geth_probe(struct of_device* ofdev=
, const struct of_device_id *ma
 	/* Find the TBI PHY.  If it's not there, we don't support SGMII */
 	ph =3D of_get_property(np, "tbi-handle", NULL);
 	if (ph) {
-		struct device_node *tbi =3D of_find_node_by_phandle(*ph);
+		struct device_node *tbi =3D of_find_node_by_phandle(*ph), *mdio;
 		struct of_device *ofdev;
 		struct mii_bus *bus;
 		const unsigned int *id;

Yours Tony
