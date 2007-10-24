From: Adrian Bunk <bunk@kernel.org>
Subject: [2.6 patch] make bonding/bond_main.c:bond_deinit() static
Date: Wed, 24 Oct 2007 18:23:17 +0200
Message-ID: <20071024162317.GK30533@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: bonding-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Moni Shoua <monis@voltaire.com>, Jay Vosburgh <fubar@us.ibm.com>,
	Jeff Garzik <jeff@garzik.org>, ctindel@users.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout.stusta.mhn.de ([141.84.69.5]:33298 "EHLO
	mailhub.stusta.mhn.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755383AbXJXQWs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Oct 2007 12:22:48 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

bond_deinit() can now become static.

Signed-off-by: Adrian Bunk <bunk@kernel.org>

---

 drivers/net/bonding/bond_main.c |    3 ++-
 drivers/net/bonding/bonding.h   |    1 -
 2 files changed, 2 insertions(+), 2 deletions(-)

5e5d2537b927f55a2199a0d9a073f41bb71290f6 
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 6f85cc3..8bb0092 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -188,6 +188,7 @@ struct bond_parm_tbl arp_validate_tbl[] = {
 /*-------------------------- Forward declarations ---------------------------*/
 
 static void bond_send_gratuitous_arp(struct bonding *bond);
+static void bond_deinit(struct net_device *bond_dev);
 
 /*---------------------------- General routines -----------------------------*/
 
@@ -4404,7 +4405,7 @@ static int bond_init(struct net_device *bond_dev, struct bond_params *params)
 /* De-initialize device specific data.
  * Caller must hold rtnl_lock.
  */
-void bond_deinit(struct net_device *bond_dev)
+static void bond_deinit(struct net_device *bond_dev)
 {
 	struct bonding *bond = bond_dev->priv;
 
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index b818060..aceaabb 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -298,7 +298,6 @@ int bond_dev_queue_xmit(struct bonding *bond, struct sk_buff *skb, struct net_de
 int bond_create(char *name, struct bond_params *params, struct bonding **newbond);
 void bond_destroy(struct bonding *bond);
 int  bond_release_and_destroy(struct net_device *bond_dev, struct net_device *slave_dev);
-void bond_deinit(struct net_device *bond_dev);
 int bond_create_sysfs(void);
 void bond_destroy_sysfs(void);
 void bond_destroy_sysfs_entry(struct bonding *bond);

