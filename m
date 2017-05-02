From: Gabriele Paoloni <gabriele.paoloni@huawei.com>
Subject: [RFC PATCH 1/2] net: revert commit 1a8b6d76dc5b
Date: Tue, 2 May 2017 10:59:25 +0100
Message-ID: <1493719166-9036-2-git-send-email-gabriele.paoloni@huawei.com>
References: <1493719166-9036-1-git-send-email-gabriele.paoloni@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <gabriele.paoloni@huawei.com>, <helgaas@kernel.org>,
        <leedom@gmail.com>, <leedom@chelsio.com>, <linuxarm@huawei.com>,
        <werner@chelsio.com>, <ganeshgr@chelsio.com>, <arjun@chelsio.com>,
        <asit.k.mallick@intel.com>, <patrick.j.cramer@intel.com>,
        <ashok.raj@intel.com>, <dingtianhong@huawei.com>,
        <mark.rutland@arm.com>, <amira@mellanox.com>,
        <catalin.marinas@arm.com>, <will.deacon@arm.com>,
        <David.Laight@aculab.com>, <jeffrey.t.kirsher@intel.com>,
        <netdev@vger.kernel.org>, <robin.murphy@arm.com>,
        <davem@davemloft.net>, <linux-arm-kernel@lists.infradead.org>
To: <davem@davemloft.com>, <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([45.249.212.188]:5845 "EHLO
        szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750955AbdEBKCe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 2 May 2017 06:02:34 -0400
In-Reply-To: <1493719166-9036-1-git-send-email-gabriele.paoloni@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: gabriele paoloni <gabriele.paoloni@huawei.com>

commit 1a8b6d76dc5b was introducing relaxed ordering as global
symbol. This does not make sense as relaxed ordering support
depends on the PCIe EP and on the Root Complex (therefore it is
not related to the CPU architecture)

Signed-off-by: Gabriele Paoloni <gabriele.paoloni@huawei.com>
---
 arch/Kconfig                                    | 3 ---
 arch/sparc/Kconfig                              | 1 -
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c | 2 +-
 3 files changed, 1 insertion(+), 5 deletions(-)

diff --git a/arch/Kconfig b/arch/Kconfig
index c4d6833..c0b118d 100644
--- a/arch/Kconfig
+++ b/arch/Kconfig
@@ -851,7 +851,4 @@ config STRICT_MODULE_RWX
 	  and non-text memory will be made non-executable. This provides
 	  protection against certain security exploits (e.g. writing to text)
 
-config ARCH_WANT_RELAX_ORDER
-	bool
-
 source "kernel/gcov/Kconfig"
diff --git a/arch/sparc/Kconfig b/arch/sparc/Kconfig
index ed96869..3f47142 100644
--- a/arch/sparc/Kconfig
+++ b/arch/sparc/Kconfig
@@ -43,7 +43,6 @@ config SPARC
 	select ARCH_HAS_SG_CHAIN
 	select CPU_NO_EFFICIENT_FFS
 	select LOCKDEP_SMALL if LOCKDEP
-	select ARCH_WANT_RELAX_ORDER
 
 config SPARC32
 	def_bool !64BIT
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
index c38d50c..094e1d6 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
@@ -350,7 +350,7 @@ s32 ixgbe_start_hw_gen2(struct ixgbe_hw *hw)
 	}
 	IXGBE_WRITE_FLUSH(hw);
 
-#ifndef CONFIG_ARCH_WANT_RELAX_ORDER
+#ifndef CONFIG_SPARC
 	/* Disable relaxed ordering */
 	for (i = 0; i < hw->mac.max_tx_queues; i++) {
 		u32 regval;
-- 
2.7.4
