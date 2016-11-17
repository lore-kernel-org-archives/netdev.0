From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v4 3/5] bus: mvebu-bus: Provide inline stub for mvebu_mbus_get_dram_win_info
Date: Thu, 17 Nov 2016 11:19:12 -0800
Message-ID: <20161117191914.11077-4-f.fainelli@gmail.com>
References: <20161117191914.11077-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, mw@semihalf.com, arnd@arndb.de,
        gregory.clement@free-electrons.com, Shaohui.Xie@freescale.com,
        andrew@lunn.ch, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:34165 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754296AbcKQTUs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2016 14:20:48 -0500
Received: by mail-pf0-f195.google.com with SMTP id y68so12065203pfb.1
        for <netdev@vger.kernel.org>; Thu, 17 Nov 2016 11:20:47 -0800 (PST)
In-Reply-To: <20161117191914.11077-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In preparation for allowing CONFIG_MVNETA_BM to build with COMPILE_TEST,
provide an inline stub for mvebu_mbus_get_dram_win_info().

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 include/linux/mbus.h | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/include/linux/mbus.h b/include/linux/mbus.h
index 2931aa43dab1..0d3f14fd2621 100644
--- a/include/linux/mbus.h
+++ b/include/linux/mbus.h
@@ -82,6 +82,7 @@ static inline int mvebu_mbus_get_io_win_info(phys_addr_t phyaddr, u32 *size,
 }
 #endif
 
+#ifdef CONFIG_MVEBU_MBUS
 int mvebu_mbus_save_cpu_target(u32 __iomem *store_addr);
 void mvebu_mbus_get_pcie_mem_aperture(struct resource *res);
 void mvebu_mbus_get_pcie_io_aperture(struct resource *res);
@@ -97,5 +98,12 @@ int mvebu_mbus_init(const char *soc, phys_addr_t mbus_phys_base,
 		    size_t mbus_size, phys_addr_t sdram_phys_base,
 		    size_t sdram_size);
 int mvebu_mbus_dt_init(bool is_coherent);
+#else
+static inline int mvebu_mbus_get_dram_win_info(phys_addr_t phyaddr, u8 *target,
+					       u8 *attr)
+{
+	return -EINVAL;
+}
+#endif /* CONFIG_MVEBU_MBUS */
 
 #endif /* __LINUX_MBUS_H */
-- 
2.9.3
