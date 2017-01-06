From: Mao Wenan <maowenan@huawei.com>
Subject: [PATCH net-next] net:add one common config ARCH_WANT_RELAX_ORDER to support relax ordering.
Date: Fri, 6 Jan 2017 17:52:44 +0800
Message-ID: <1483696364-8680-1-git-send-email-maowenan@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>, <jeffrey.t.kirsher@intel.com>,
        <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([58.251.152.64]:57282 "EHLO
        szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S969982AbdAFJzs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2017 04:55:48 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Relax ordering(RO) is one feature of 82599 NIC, to enable this feature can
enhance the performance for some cpu architecure, such as SPARC and so on.
Currently it only supports one special cpu architecture(SPARC) in 82599
driver to enable RO feature, this is not very common for other cpu architecture
which really needs RO feature.
This patch add one common config CONFIG_ARCH_WANT_RELAX_ORDER to set RO feature,
and should define CONFIG_ARCH_WANT_RELAX_ORDER in sparc Kconfig firstly.

Signed-off-by: Mao Wenan <maowenan@huawei.com>
---
 arch/sparc/Kconfig                              | 1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c | 2 +-
 2 files changed, 2 insertions(+), 1 deletion(-)

diff --git a/arch/sparc/Kconfig b/arch/sparc/Kconfig
index cf4034c..68ac5c7 100644
--- a/arch/sparc/Kconfig
+++ b/arch/sparc/Kconfig
@@ -44,6 +44,7 @@ config SPARC
 	select CPU_NO_EFFICIENT_FFS
 	select HAVE_ARCH_HARDENED_USERCOPY
 	select PROVE_LOCKING_SMALL if PROVE_LOCKING
+	select ARCH_WANT_RELAX_ORDER
 
 config SPARC32
 	def_bool !64BIT
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
index 094e1d6..c38d50c 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
@@ -350,7 +350,7 @@ s32 ixgbe_start_hw_gen2(struct ixgbe_hw *hw)
 	}
 	IXGBE_WRITE_FLUSH(hw);
 
-#ifndef CONFIG_SPARC
+#ifndef CONFIG_ARCH_WANT_RELAX_ORDER
 	/* Disable relaxed ordering */
 	for (i = 0; i < hw->mac.max_tx_queues; i++) {
 		u32 regval;
-- 
2.7.0
