From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next 1/4] ixgbe: sparc: rename the ARCH_WANT_RELAX_ORDER to IXGBE_ALLOW_RELAXED_ORDER
Date: Sat, 1 Apr 2017 15:25:51 +0800
Message-ID: <1491031554-19516-2-git-send-email-dingtianhong@huawei.com>
References: <1491031554-19516-1-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ding Tianhong <dingtianhong@huawei.com>
To: <catalin.marinas@arm.com>, <will.deacon@arm.com>,
        <mark.rutland@arm.com>, <robin.murphy@arm.com>,
        <jeffrey.t.kirsher@intel.com>, <davem@davemloft.net>,
        <alexander.duyck@gmail.com>,
        <linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([45.249.212.187]:5294 "EHLO
        dggrg01-dlp.huawei.com" rhost-flags-OK-FAIL-OK-FAIL)
        by vger.kernel.org with ESMTP id S1750793AbdDAH0q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 1 Apr 2017 03:26:46 -0400
In-Reply-To: <1491031554-19516-1-git-send-email-dingtianhong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Till now only the Intel ixgbe could support enable
Relaxed ordering in the drivers for special architecture,
but the ARCH_WANT_RELAX_ORDER is looks like a general name
for all arch, so rename to a specific name for intel
card looks more appropriate.

Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 arch/Kconfig                                    | 2 +-
 arch/sparc/Kconfig                              | 2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c | 2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/arch/Kconfig b/arch/Kconfig
index cd211a1..bc0ab44 100644
--- a/arch/Kconfig
+++ b/arch/Kconfig
@@ -844,7 +844,7 @@ config STRICT_MODULE_RWX
 	  and non-text memory will be made non-executable. This provides
 	  protection against certain security exploits (e.g. writing to text)
 
-config ARCH_WANT_RELAX_ORDER
+config IXGBE_ALLOW_RELAXED_ORDER
 	bool
 
 source "kernel/gcov/Kconfig"
diff --git a/arch/sparc/Kconfig b/arch/sparc/Kconfig
index 68ac5c7..f56bcf4 100644
--- a/arch/sparc/Kconfig
+++ b/arch/sparc/Kconfig
@@ -44,7 +44,7 @@ config SPARC
 	select CPU_NO_EFFICIENT_FFS
 	select HAVE_ARCH_HARDENED_USERCOPY
 	select PROVE_LOCKING_SMALL if PROVE_LOCKING
-	select ARCH_WANT_RELAX_ORDER
+	select IXGBE_ALLOW_RELAXED_ORDER
 
 config SPARC32
 	def_bool !64BIT
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
index c38d50c..563ea15 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
@@ -350,7 +350,7 @@ s32 ixgbe_start_hw_gen2(struct ixgbe_hw *hw)
 	}
 	IXGBE_WRITE_FLUSH(hw);
 
-#ifndef CONFIG_ARCH_WANT_RELAX_ORDER
+#ifndef CONFIG_IXGBE_ALLOW_RELAX_ORDER
 	/* Disable relaxed ordering */
 	for (i = 0; i < hw->mac.max_tx_queues; i++) {
 		u32 regval;
-- 
1.9.0
