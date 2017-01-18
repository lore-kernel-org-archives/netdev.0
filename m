From: Mao Wenan <maowenan@huawei.com>
Subject: [PATCH v3 net-next] net:add one common config ARCH_WANT_RELAX_ORDER to support relax ordering
Date: Wed, 18 Jan 2017 08:50:05 +0800
Message-ID: <1484700605-2412-1-git-send-email-maowenan@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>, <alexander.duyck@gmail.com>,
        <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([58.251.152.64]:32143 "EHLO
        szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751721AbdARAue (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2017 19:50:34 -0500
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
Reviewed-by: Alexander Duyck <alexander.duyck@gmail.com>
---
v2 -> v3: add reviewed information.
---
 arch/Kconfig                                    | 3 +++
 arch/sparc/Kconfig                              | 1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c | 2 +-
 3 files changed, 5 insertions(+), 1 deletion(-)

diff --git a/arch/Kconfig b/arch/Kconfig
index 99839c2..bd04eac 100644
--- a/arch/Kconfig
+++ b/arch/Kconfig
@@ -781,4 +781,7 @@ config VMAP_STACK
 	  the stack to map directly to the KASAN shadow map using a formula
 	  that is incorrect if the stack is in vmalloc space.
 
+config ARCH_WANT_RELAX_ORDER
+	bool
+
 source "kernel/gcov/Kconfig"
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
