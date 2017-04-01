From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next 3/4] ixgbe: move IXGBE_ALLOW_RELAXED_ORDER from architecture to driver
Date: Sat, 1 Apr 2017 15:25:53 +0800
Message-ID: <1491031554-19516-4-git-send-email-dingtianhong@huawei.com>
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
Received: from szxga01-in.huawei.com ([45.249.212.187]:5296 "EHLO
        dggrg01-dlp.huawei.com" rhost-flags-OK-FAIL-OK-FAIL)
        by vger.kernel.org with ESMTP id S1750808AbdDAH0q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 1 Apr 2017 03:26:46 -0400
In-Reply-To: <1491031554-19516-1-git-send-email-dingtianhong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Relaxed Ordering is an specific PCI option and impact some
architecture performance just like SPARC and ARM64, so compare to
drop this to the several architecture folder, put it in driver looks
more appropriate, it will not impact or be seen for other architectures.

Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 arch/Kconfig                       | 3 ---
 arch/sparc/Kconfig                 | 1 -
 drivers/net/ethernet/intel/Kconfig | 4 ++++
 3 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/arch/Kconfig b/arch/Kconfig
index bc0ab44..e03d354 100644
--- a/arch/Kconfig
+++ b/arch/Kconfig
@@ -844,7 +844,4 @@ config STRICT_MODULE_RWX
 	  and non-text memory will be made non-executable. This provides
 	  protection against certain security exploits (e.g. writing to text)
 
-config IXGBE_ALLOW_RELAXED_ORDER
-	bool
-
 source "kernel/gcov/Kconfig"
diff --git a/arch/sparc/Kconfig b/arch/sparc/Kconfig
index f56bcf4..cf4034c 100644
--- a/arch/sparc/Kconfig
+++ b/arch/sparc/Kconfig
@@ -44,7 +44,6 @@ config SPARC
 	select CPU_NO_EFFICIENT_FFS
 	select HAVE_ARCH_HARDENED_USERCOPY
 	select PROVE_LOCKING_SMALL if PROVE_LOCKING
-	select IXGBE_ALLOW_RELAXED_ORDER
 
 config SPARC32
 	def_bool !64BIT
diff --git a/drivers/net/ethernet/intel/Kconfig b/drivers/net/ethernet/intel/Kconfig
index 1349b45..33ef2b6 100644
--- a/drivers/net/ethernet/intel/Kconfig
+++ b/drivers/net/ethernet/intel/Kconfig
@@ -275,4 +275,8 @@ config FM10K
 	  To compile this driver as a module, choose M here. The module
 	  will be called fm10k.  MSI-X interrupt support is required
 
+config IXGBE_ALLOW_RELAXED_ORDER
+	bool "Intel(R) 10GbE PCI Express adapters Enable Relaxed Ordering" if SPARC
+	default y if SPARC
+
 endif # NET_VENDOR_INTEL
-- 
1.9.0
