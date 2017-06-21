From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next] qede: Fix compilation without QED_RDMA
Date: Wed, 21 Jun 2017 08:26:34 +0300
Message-ID: <20170621052634.20984-1-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: <Michal.Kalderon@cavium.com>, Chad Dupuis <chad.dupuis@cavium.com>,
        Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam02on0075.outbound.protection.outlook.com ([104.47.36.75]:11520
        "EHLO NAM02-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751069AbdFUF0s (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 21 Jun 2017 01:26:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chad Dupuis <chad.dupuis@cavium.com>

When CONFIG_QED_RDMA isn't defined, we'd hit the following:

 /include/linux/qed/qede_rdma.h:84:19:
 warning: ‘qede_rdma_dev_add’ used but never defined [enabled by default]
 static inline int qede_rdma_dev_add(struct qede_dev *dev);

Fixes: bbfcd1e8e167 ("qed*: Set rdma generic functions prefix")
Signed-off-by: Chad Dupuis <chad.dupuis@cavium.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 include/linux/qed/qede_rdma.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/qed/qede_rdma.h b/include/linux/qed/qede_rdma.h
index 1348a16..9904617 100644
--- a/include/linux/qed/qede_rdma.h
+++ b/include/linux/qed/qede_rdma.h
@@ -81,7 +81,7 @@ void qede_rdma_dev_remove(struct qede_dev *dev);
 void qede_rdma_event_changeaddr(struct qede_dev *edr);
 
 #else
-static inline int qede_rdma_dev_add(struct qede_dev *dev);
+static inline int qede_rdma_dev_add(struct qede_dev *dev)
 {
 	return 0;
 }
-- 
2.9.4
