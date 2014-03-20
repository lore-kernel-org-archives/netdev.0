From: Monam Agarwal <monamagarwal123@gmail.com>
Subject: [PATCH 6/9] scsi: Replace rcu_assign_pointer(x, NULL) with RCU_INIT_POINTER(x, NULL) in drivers/scsi/libfc/fc_libfc.c
Date: Thu, 20 Mar 2014 20:14:13 +0530
Message-ID: <53f52b8b185a76418272b3ad78dc566a3163a7e0.1395324808.git.monamagarwal123@gmail.com>
References: <09e2af73056d815f34152f1ebfd45b52d7aa2ff9.1395324808.git.monamagarwal123@gmail.com>
Cc: linux-kernel@vger.kernel.org, eddie.wai@broadcom.com,
	paulmck@linux.vnet.ibm.com
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <09e2af73056d815f34152f1ebfd45b52d7aa2ff9.1395324808.git.monamagarwal123@gmail.com>
In-Reply-To: <cover.1395324808.git.monamagarwal123@gmail.com>
References: <cover.1395324808.git.monamagarwal123@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Monam Agarwal <monamagarwal123@gmail.com>
---
 drivers/scsi/libfc/fc_libfc.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/scsi/libfc/fc_libfc.c b/drivers/scsi/libfc/fc_libfc.c
index b773512..ee74eec 100644
--- a/drivers/scsi/libfc/fc_libfc.c
+++ b/drivers/scsi/libfc/fc_libfc.c
@@ -297,9 +297,9 @@ void fc_fc4_deregister_provider(enum fc_fh_type type, struct fc4_prov *prov)
 	BUG_ON(type >= FC_FC4_PROV_SIZE);
 	mutex_lock(&fc_prov_mutex);
 	if (prov->recv)
-		rcu_assign_pointer(fc_passive_prov[type], NULL);
+		RCU_INIT_POINTER(fc_passive_prov[type], NULL);
 	else
-		rcu_assign_pointer(fc_active_prov[type], NULL);
+		RCU_INIT_POINTER(fc_active_prov[type], NULL);
 	mutex_unlock(&fc_prov_mutex);
 	synchronize_rcu();
 }
-- 
1.7.9.5
