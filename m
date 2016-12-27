From: David VomLehn <vomlehn@texas.net>
Subject: [PATCH 12/12] Receive side scaling
Date: Tue, 27 Dec 2016 05:17:48 -0800
Message-ID: <b3c3d621bf201aa0179b88ab9f848d2d41aaf7d3.1482844668.git.vomlehn@texas.net>
References: <9cc1565a3a398b4f70248ca98d12991071142682.1482844668.git.vomlehn@texas.net>
Cc: Simon Edelhaus <Simon.Edelhaus@aquantia.com>,
        David VomLehn <vomlehn@texas.net>,
        Dmitrii Tarakanov <Dmitrii.Tarakanov@aquantia.com>,
        Alexander Loktionov <Alexander.Loktionov@aquantia.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda5.aus1.datafoundry.com ([209.99.124.136]:38450 "EHLO
        barracuda.datafoundry.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752855AbcL0Nbw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Dec 2016 08:31:52 -0500
In-Reply-To: <9cc1565a3a398b4f70248ca98d12991071142682.1482844668.git.vomlehn@texas.net>
In-Reply-To: <37565094793e5df8b63a1c025d0057382ae70221.1482844668.git.vomlehn@texas.net>
References: <9cc1565a3a398b4f70248ca98d12991071142682.1482844668.git.vomlehn@texas.net> <67f8be9c3f6a4fede2eefaa4a3c45f9dbaf9b411.1482844668.git.vomlehn@texas.net> <8aac6eaf6d90651f279392f301de85e6ab72a3cb.1482844668.git.vomlehn@texas.net> <206766987286d2c30b7f674dec4aafe1ed70a21b.1482844668.git.vomlehn@texas.net> <122d7e0633e8a8ddfbb0c233d6896254b2fa3eef.1482844668.git.vomlehn@texas.net> <726fb213b0f282fc4a6b997721c3022551783fe6.1482844668.git.vomlehn@texas.net> <61665299e584052d30bd1d623ebd4b138dd90694.1482844668.git.vomlehn@texas.net> <36c7868a58795880d5f6111e523c0136ace2ca91.1482844668.git.vomlehn@texas.net> <9936fa643d5f6a8f29b069847d052fcf5dc23513.1482844668.git.vomlehn@texas.net> <7ef8eca5f4c5cc3d28992d820a7a1d9e92590bb2.1482844668.git.vomlehn@texas.net> <37565094793e5df8b63a1c025d0
 057382ae70221.1482844668.git.vomlehn@texas.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add definitions that support receive side scaling.

Signed-off-by: Dmitrii Tarakanov <Dmitrii.Tarakanov@aquantia.com>
Signed-off-by: Alexander Loktionov <Alexander.Loktionov@aquantia.com>
Signed-off-by: David M. VomLehn <vomlehn@texas.net>
---
 drivers/net/ethernet/aquantia/atlantic/aq_rss.h | 35 +++++++++++++++++++++++++
 1 file changed, 35 insertions(+)
 create mode 100644 drivers/net/ethernet/aquantia/atlantic/aq_rss.h

diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_rss.h b/drivers/net/ethernet/aquantia/atlantic/aq_rss.h
new file mode 100644
index 0000000..181d373
--- /dev/null
+++ b/drivers/net/ethernet/aquantia/atlantic/aq_rss.h
@@ -0,0 +1,35 @@
+/*
+ * Aquantia Corporation Network Driver
+ * Copyright (C) 2014-2016 Aquantia Corporation. All rights reserved
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ */
+
+/*
+ * File aq_rss.h: Receive Side Scaling definitions.
+ */
+
+#ifndef AQ_RSS_H
+#define AQ_RSS_H
+
+#include "aq_common.h"
+#include "aq_cfg.h"
+
+#define HASH_TYPE_IPV4                  0x00000100U
+#define HASH_TYPE_TCP_IPV4              0x00000200U
+#define HASH_TYPE_IPV6                  0x00000400U
+#define HASH_TYPE_IPV6_EX               0x00000800U
+#define HASH_TYPE_TCP_IPV6              0x00001000U
+#define HASH_TYPE_TCP_IPV6_EX           0x00002000U
+
+struct aq_receive_scale_parameters {
+	u16 base_cpu_number;
+	u16 indirection_table_size;
+	u16 hash_secret_key_size;
+	u32 hash_secret_key[AQ_CFG_RSS_HASHKEY_SIZE / sizeof(u32)];
+	u8 indirection_table[AQ_CFG_RSS_INDIRECTION_TABLE_MAX];
+};
+
+#endif /* AQ_RSS_H */
-- 
2.7.4
