From: Monam Agarwal <monamagarwal123@gmail.com>
Subject: [PATCH] rcu: Convert rcu_dereference to rcu_access_pointer in drivers/net/ethernet/broadcom/cnic.c
Date: Wed, 19 Mar 2014 03:21:04 +0530
Message-ID: <1395179464-17960-1-git-send-email-monamagarwal123@gmail.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	eddie.wai@broadcom.com, paulmck@linux.vnet.ibm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch converts rcu_dereference to rcu_access_pointer if its returned value is not used

Signed-off-by: Monam Agarwal <monamagarwal123@gmail.com>

Reviewed-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>

---
 drivers/net/ethernet/broadcom/cnic.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/cnic.c b/drivers/net/ethernet/broadcom/cnic.c
index 6f10c69..42fb026 100644
--- a/drivers/net/ethernet/broadcom/cnic.c
+++ b/drivers/net/ethernet/broadcom/cnic.c
@@ -355,7 +355,7 @@ static int cnic_iscsi_nl_msg_recv(struct cnic_dev *dev, u32 msg_type,
 			break;
 
 		rcu_read_lock();
-		if (!rcu_dereference(cp->ulp_ops[CNIC_ULP_L4])) {
+		if (!rcu_access_pointer(cp->ulp_ops[CNIC_ULP_L4])) {
 			rc = -ENODEV;
 			rcu_read_unlock();
 			break;
-- 
1.7.9.5
