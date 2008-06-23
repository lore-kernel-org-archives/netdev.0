From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH 2.6.27] cxgb3 - add missing adapter type for RDMA
Date: Mon, 23 Jun 2008 11:02:59 -0700
Message-ID: <20080623180259.12447.52386.stgit@speedy5>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: jeff@garzik.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757180AbYFWSDW@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Divy Le Ray <divy@chelsio.com>

T3C added support is now reflected to the RDMA driver.

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/cxgb3/cxgb3_offload.c |   21 ++++++++++++++++++++-
 drivers/net/cxgb3/t3cdev.h        |    3 ++-
 2 files changed, 22 insertions(+), 2 deletions(-)

diff --git a/drivers/net/cxgb3/cxgb3_offload.c b/drivers/net/cxgb3/cxgb3_offload.c
index ff9c013..ae6ff5d 100644
--- a/drivers/net/cxgb3/cxgb3_offload.c
+++ b/drivers/net/cxgb3/cxgb3_offload.c
@@ -1248,6 +1248,25 @@ static inline void unregister_tdev(struct t3cdev *tdev)
 	mutex_unlock(&cxgb3_db_lock);
 }
 
+static inline int adap2type(struct adapter *adapter)
+{
+	int type = 0;
+
+	switch (adapter->params.rev) {
+	case T3_REV_A:
+		type = T3A;
+		break;
+	case T3_REV_B:
+	case T3_REV_B2:
+		type = T3B;
+		break;
+	case T3_REV_C:
+		type = T3C;
+		break;
+	}
+	return type;
+}
+
 void __devinit cxgb3_adapter_ofld(struct adapter *adapter)
 {
 	struct t3cdev *tdev = &adapter->tdev;
@@ -1257,7 +1276,7 @@ void __devinit cxgb3_adapter_ofld(struct adapter *adapter)
 	cxgb3_set_dummy_ops(tdev);
 	tdev->send = t3_offload_tx;
 	tdev->ctl = cxgb_offload_ctl;
-	tdev->type = adapter->params.rev == 0 ? T3A : T3B;
+	tdev->type = adap2type(adapter);
 
 	register_tdev(tdev);
 }
diff --git a/drivers/net/cxgb3/t3cdev.h b/drivers/net/cxgb3/t3cdev.h
index a18c8a1..8556628 100644
--- a/drivers/net/cxgb3/t3cdev.h
+++ b/drivers/net/cxgb3/t3cdev.h
@@ -45,7 +45,8 @@ struct cxgb3_client;
 
 enum t3ctype {
 	T3A = 0,
-	T3B
+	T3B,
+	T3C,
 };
 
 struct t3cdev {
