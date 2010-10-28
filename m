From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: [PATCH 1/2] vmxnet3: remove unnecessary byteswapping in BAR writing macros
Date: Wed, 27 Oct 2010 20:12:34 -0700
Message-ID: <1288235555-24675-1-git-send-email-harvey.harrison@gmail.com>
Cc: netdev@vger.kernel.org
To: sbhatewara@vmware.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:48147 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932852Ab0J1DMm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Oct 2010 23:12:42 -0400
Received: by yxk8 with SMTP id 8so574874yxk.19
        for <netdev@vger.kernel.org>; Wed, 27 Oct 2010 20:12:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

readl/writel swap to little-endian internally.

Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
---
 drivers/net/vmxnet3/vmxnet3_int.h |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/vmxnet3/vmxnet3_int.h b/drivers/net/vmxnet3/vmxnet3_int.h
index 8a2f471..edf2288 100644
--- a/drivers/net/vmxnet3/vmxnet3_int.h
+++ b/drivers/net/vmxnet3/vmxnet3_int.h
@@ -330,14 +330,14 @@ struct vmxnet3_adapter {
 };
 
 #define VMXNET3_WRITE_BAR0_REG(adapter, reg, val)  \
-	writel(cpu_to_le32(val), (adapter)->hw_addr0 + (reg))
+	writel((val), (adapter)->hw_addr0 + (reg))
 #define VMXNET3_READ_BAR0_REG(adapter, reg)        \
-	le32_to_cpu(readl((adapter)->hw_addr0 + (reg)))
+	readl((adapter)->hw_addr0 + (reg))
 
 #define VMXNET3_WRITE_BAR1_REG(adapter, reg, val)  \
-	writel(cpu_to_le32(val), (adapter)->hw_addr1 + (reg))
+	writel((val), (adapter)->hw_addr1 + (reg))
 #define VMXNET3_READ_BAR1_REG(adapter, reg)        \
-	le32_to_cpu(readl((adapter)->hw_addr1 + (reg)))
+	readl((adapter)->hw_addr1 + (reg))
 
 #define VMXNET3_WAKE_QUEUE_THRESHOLD(tq)  (5)
 #define VMXNET3_RX_ALLOC_THRESHOLD(rq, ring_idx, adapter) \
-- 
1.7.1

