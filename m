From: Monam Agarwal <monamagarwal123@gmail.com>
Subject: [PATCH] drivers/net: Use RCU_INIT_POINTER(x, NULL) in bonding/bond_options.c
Date: Mon, 24 Mar 2014 00:00:17 +0530
Message-ID: <1395599417-7041-1-git-send-email-monamagarwal123@gmail.com>
To: fubar@us.ibm.com, vfalico@redhat.com, andy@greyhouse.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch replaces rcu_assign_pointer(x, NULL) with RCU_INIT_POINTER(x, NULL)

The rcu_assign_pointer() ensures that the initialization of a structure       
is carried out before storing a pointer to that structure. 
And in the case of the NULL pointer, there is no structure to initialize. 
So, rcu_assign_pointer(p, NULL) can be safely converted to RCU_INIT_POINTER(p, NULL)

Signed-off-by: Monam Agarwal <monamagarwal123@gmail.com>
---
 drivers/net/bonding/bond_options.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
index 6e6b093..724e30f 100644
--- a/drivers/net/bonding/bond_options.c
+++ b/drivers/net/bonding/bond_options.c
@@ -712,7 +712,7 @@ static int bond_option_active_slave_set(struct bonding *bond,
 	/* check to see if we are clearing active */
 	if (!slave_dev) {
 		pr_info("%s: Clearing current active slave\n", bond->dev->name);
-		rcu_assign_pointer(bond->curr_active_slave, NULL);
+		RCU_INIT_POINTER(bond->curr_active_slave, NULL);
 		bond_select_active_slave(bond);
 	} else {
 		struct slave *old_active = bond->curr_active_slave;
-- 
1.7.9.5
