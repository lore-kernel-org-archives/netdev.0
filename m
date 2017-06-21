From: Michael J Dilmore <michael.j.dilmore@gmail.com>
Subject: [PATCH] Convert BUG_ON to WARN_ON in bond_options.c
Date: Wed, 21 Jun 2017 19:02:17 +0100
Message-ID: <1498068137-3550-1-git-send-email-michael.j.dilmore@gmail.com>
Cc: vfalico@gmail.com, =andy@greyhouse.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, joe@perches.com,
        Michael J Dilmore <michael.j.dilmore@gmail.com>
To: j.vosburgh@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The function below contains a BUG_ON where no active slave is detected. The patch
converts this to a WARN_ON to avoid crashing the kernel.

Signed-off-by: Michael J Dilmore <michael.j.dilmore@gmail.com>
---
 drivers/net/bonding/bond_options.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
index 1bcbb89..c4b4791 100644
--- a/drivers/net/bonding/bond_options.c
+++ b/drivers/net/bonding/bond_options.c
@@ -778,7 +778,7 @@ static int bond_option_active_slave_set(struct bonding *bond,
 		struct slave *old_active = rtnl_dereference(bond->curr_active_slave);
 		struct slave *new_active = bond_slave_get_rtnl(slave_dev);
 
-		BUG_ON(!new_active);
+		WARN_ON(!new_active);
 
 		if (new_active == old_active) {
 			/* do nothing */
-- 
2.7.4
