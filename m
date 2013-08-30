From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH v2 net-next 3/9] net: dsa: inherit addr_assign_type along with dev_addr
Date: Fri, 30 Aug 2013 18:08:46 +0200
Message-ID: <1377878932-26881-4-git-send-email-bjorn@mork.no>
References: <1377878932-26881-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:55482 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756873Ab3H3QKO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Aug 2013 12:10:14 -0400
In-Reply-To: <1377878932-26881-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A device inheriting a random or set address should reflect this in
its addr_assign_type.

Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 net/dsa/slave.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 6ebd8fb..29d684e 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -347,7 +347,7 @@ dsa_slave_create(struct dsa_switch *ds, struct devi=
ce *parent,
=20
 	slave_dev->features =3D master->vlan_features;
 	SET_ETHTOOL_OPS(slave_dev, &dsa_slave_ethtool_ops);
-	memcpy(slave_dev->dev_addr, master->dev_addr, ETH_ALEN);
+	eth_hw_addr_inherit(slave_dev, master);
 	slave_dev->tx_queue_len =3D 0;
=20
 	switch (ds->dst->tag_protocol) {
--=20
1.7.10.4
