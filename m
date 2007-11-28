From: =?us-ascii?Q?=3D=3Futf-8=3Fq=3FFerenc=5FW=3DC3=3DA1gner=3F=3D?=
	<wferi@niif.hu>
Subject: [PATCH 2/3] net/bonding: Return nothing for not applicable values
Date: Wed, 28 Nov 2007 01:52:46 +0100
Message-ID: <87wss3jin5.fsf@szonett.ki.iif.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, wferi@niif.hu
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from tac.ki.iif.hu ([193.6.222.43]:45416 "EHLO tac.ki.iif.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759011AbXK1Aws convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Nov 2007 19:52:48 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The previous code returned '\n' (that is, a single empty line)
from most files, with one exception (xmit_hash_policy), where
it returned 'NA\n'.  This patch consolidates each file to return
nothing at all if not applicable, not even a '\n'.

I find this behaviour more usual, more useful, more efficient
and shorter to code from both sides.

Signed-off-by: Ferenc W=C3=A1gner <wferi@niif.hu>
---
 drivers/net/bonding/bond_sysfs.c |   25 ++++---------------------
 1 files changed, 4 insertions(+), 21 deletions(-)

diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bon=
d_sysfs.c
index a3f1b4a..6bb91e2 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -455,14 +455,11 @@ static ssize_t bonding_show_xmit_hash(struct devi=
ce *d,
 				      struct device_attribute *attr,
 				      char *buf)
 {
-	int count;
+	int count =3D 0;
 	struct bonding *bond =3D to_bond(d);
=20
-	if ((bond->params.mode !=3D BOND_MODE_XOR) &&
-	    (bond->params.mode !=3D BOND_MODE_8023AD)) {
-		// Not Applicable
-		count =3D sprintf(buf, "NA\n");
-	} else {
+	if ((bond->params.mode =3D=3D BOND_MODE_XOR) ||
+	    (bond->params.mode =3D=3D BOND_MODE_8023AD)) {
 		count =3D sprintf(buf, "%s %d\n",
 			xmit_hashtype_tbl[bond->params.xmit_policy].modename,
 			bond->params.xmit_policy);
@@ -1079,8 +1076,6 @@ static ssize_t bonding_show_primary(struct device=
 *d,
=20
 	if (bond->primary_slave)
 		count =3D sprintf(buf, "%s\n", bond->primary_slave->dev->name);
-	else
-		count =3D sprintf(buf, "\n");
=20
 	return count;
 }
@@ -1186,7 +1181,7 @@ static ssize_t bonding_show_active_slave(struct d=
evice *d,
 {
 	struct slave *curr;
 	struct bonding *bond =3D to_bond(d);
-	int count;
+	int count =3D 0;
=20
 	read_lock(&bond->curr_slave_lock);
 	curr =3D bond->curr_active_slave;
@@ -1194,8 +1189,6 @@ static ssize_t bonding_show_active_slave(struct d=
evice *d,
=20
 	if (USES_PRIMARY(bond->params.mode) && curr)
 		count =3D sprintf(buf, "%s\n", curr->dev->name);
-	else
-		count =3D sprintf(buf, "\n");
 	return count;
 }
=20
@@ -1309,8 +1302,6 @@ static ssize_t bonding_show_ad_aggregator(struct =
device *d,
 		struct ad_info ad_info;
 		count =3D sprintf(buf, "%d\n", (bond_3ad_get_active_agg_info(bond, &=
ad_info)) ?  0 : ad_info.aggregator_id);
 	}
-	else
-		count =3D sprintf(buf, "\n");
=20
 	return count;
 }
@@ -1331,8 +1322,6 @@ static ssize_t bonding_show_ad_num_ports(struct d=
evice *d,
 		struct ad_info ad_info;
 		count =3D sprintf(buf, "%d\n", (bond_3ad_get_active_agg_info(bond, &=
ad_info)) ?  0: ad_info.ports);
 	}
-	else
-		count =3D sprintf(buf, "\n");
=20
 	return count;
 }
@@ -1353,8 +1342,6 @@ static ssize_t bonding_show_ad_actor_key(struct d=
evice *d,
 		struct ad_info ad_info;
 		count =3D sprintf(buf, "%d\n", (bond_3ad_get_active_agg_info(bond, &=
ad_info)) ?  0 : ad_info.actor_key);
 	}
-	else
-		count =3D sprintf(buf, "\n");
=20
 	return count;
 }
@@ -1375,8 +1362,6 @@ static ssize_t bonding_show_ad_partner_key(struct=
 device *d,
 		struct ad_info ad_info;
 		count =3D sprintf(buf, "%d\n", (bond_3ad_get_active_agg_info(bond, &=
ad_info)) ?  0 : ad_info.partner_key);
 	}
-	else
-		count =3D sprintf(buf, "\n");
=20
 	return count;
 }
@@ -1401,8 +1386,6 @@ static ssize_t bonding_show_ad_partner_mac(struct=
 device *d,
 					print_mac(mac, ad_info.partner_system));
 		}
 	}
-	else
-		count =3D sprintf(buf, "\n");
=20
 	return count;
 }
--=20
1.4.4.4

