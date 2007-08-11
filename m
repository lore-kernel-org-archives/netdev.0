From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH 3/13] cxgb3 - SGE doorbell overflow warning
Date: Fri, 10 Aug 2007 23:29:44 -0700
Message-ID: <20070811062944.8058.38057.stgit@speedy5>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:3058 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754235AbXHKG3r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Aug 2007 02:29:47 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Divy Le Ray <divy@chelsio.com>

Log doorbell Fifo overflow

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/cxgb3/regs.h |    8 ++++++++
 drivers/net/cxgb3/sge.c  |    4 ++++
 2 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/drivers/net/cxgb3/regs.h b/drivers/net/cxgb3/regs.h
index aa80313..2824278 100644
--- a/drivers/net/cxgb3/regs.h
+++ b/drivers/net/cxgb3/regs.h
@@ -172,6 +172,14 @@
 
 #define A_SG_INT_CAUSE 0x5c
 
+#define S_HIPIODRBDROPERR    11
+#define V_HIPIODRBDROPERR(x) ((x) << S_HIPIODRBDROPERR)
+#define F_HIPIODRBDROPERR    V_HIPIODRBDROPERR(1U)
+
+#define S_LOPIODRBDROPERR    10
+#define V_LOPIODRBDROPERR(x) ((x) << S_LOPIODRBDROPERR)
+#define F_LOPIODRBDROPERR    V_LOPIODRBDROPERR(1U)
+
 #define S_RSPQDISABLED    3
 #define V_RSPQDISABLED(x) ((x) << S_RSPQDISABLED)
 #define F_RSPQDISABLED    V_RSPQDISABLED(1U)
diff --git a/drivers/net/cxgb3/sge.c b/drivers/net/cxgb3/sge.c
index a2cfd68..9213cda 100644
--- a/drivers/net/cxgb3/sge.c
+++ b/drivers/net/cxgb3/sge.c
@@ -2476,6 +2476,10 @@ void t3_sge_err_intr_handler(struct adapter *adapter)
 			 "(0x%x)\n", (v >> S_RSPQ0DISABLED) & 0xff);
 	}
 
+	if (status & (F_HIPIODRBDROPERR | F_LOPIODRBDROPERR))
+		CH_ALERT(adapter, "SGE dropped %s priority doorbell\n",
+			 status & F_HIPIODRBDROPERR ? "high" : "lo");
+
 	t3_write_reg(adapter, A_SG_INT_CAUSE, status);
 	if (status & (F_RSPQCREDITOVERFOW | F_RSPQDISABLED))
 		t3_fatal_err(adapter);
