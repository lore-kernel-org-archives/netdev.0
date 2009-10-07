From: =?utf-8?q?Nicolas=20de=20Peslo=C3=BCan?=
	<nicolas.2p.debian@free.fr>
Subject: [PATCH netnext-2.6] bonding: remove useless assignment
Date: Wed,  7 Oct 2009 22:59:28 +0200
Message-ID: <1254949168-12404-2-git-send-email-nicolas.2p.debian@free.fr>
References: <1254949168-12404-1-git-send-email-nicolas.2p.debian@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net
To: fubar@us.ibm.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp6-g21.free.fr ([212.27.42.6]:34669 "EHLO smtp6-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934366AbZJGVAU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Oct 2009 17:00:20 -0400
In-Reply-To: <1254949168-12404-1-git-send-email-nicolas.2p.debian@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The variable old_active is first set to bond->curr_active_slave.
Then, it is unconditionally set to new_active, without being used in be=
tween.

The first assignment, having no side effect, is useless.

Signed-off-by: Nicolas de Peslo=C3=BCan <nicolas.2p.debian@free.fr>
Reviewed-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/bonding/bond_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond=
_main.c
index 20dc5a2..34bdea5 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1084,7 +1084,7 @@ static struct slave *bond_find_best_slave(struct =
bonding *bond)
 	int mintime =3D bond->params.updelay;
 	int i;
=20
-	new_active =3D old_active =3D bond->curr_active_slave;
+	new_active =3D bond->curr_active_slave;
=20
 	if (!new_active) { /* there were no active slaves left */
 		if (bond->slave_cnt > 0)   /* found one slave */
--=20
1.6.3.3

