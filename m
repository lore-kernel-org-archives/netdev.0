From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 3/5] Revert commit 1a8b6d76dc5b ("net:add one common config...")
Date: Mon,  9 Oct 2017 08:12:49 -0700
Message-ID: <20171009151251.53939-4-jeffrey.t.kirsher@intel.com>
References: <20171009151251.53939-1-jeffrey.t.kirsher@intel.com>
Cc: Ding Tianhong <dingtianhong@huawei.com>,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:48022 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754245AbdJIPNP (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 9 Oct 2017 11:13:15 -0400
In-Reply-To: <20171009151251.53939-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ding Tianhong <dingtianhong@huawei.com>

The new flag PCI_DEV_FLAGS_NO_RELAXED_ORDERING has been added
to indicate that Relaxed Ordering Attributes (RO) should not
be used for Transaction Layer Packets (TLP) targeted toward
these affected Root Port, it will clear the bit4 in the PCIe
Device Control register, so the PCIe device drivers could
query PCIe configuration space to determine if it can send
TLPs to Root Port with the Relaxed Ordering Attributes set.

With this new flag  we don't need the config ARCH_WANT_RELAX_ORDER
to control the Relaxed Ordering Attributes for the ixgbe drivers
just like the commit 1a8b6d76dc5b ("net:add one common config...") did,
so revert this commit.

Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 arch/Kconfig                                    | 3 ---
 arch/sparc/Kconfig                              | 1 -
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c | 2 +-
 3 files changed, 1 insertion(+), 5 deletions(-)

diff --git a/arch/Kconfig b/arch/Kconfig
index 1aafb4efbb51..d789a89cb32c 100644
--- a/arch/Kconfig
+++ b/arch/Kconfig
@@ -937,9 +937,6 @@ config STRICT_MODULE_RWX
 	  and non-text memory will be made non-executable. This provides
 	  protection against certain security exploits (e.g. writing to text)
 
-config ARCH_WANT_RELAX_ORDER
-	bool
-
 config ARCH_HAS_REFCOUNT
 	bool
 	help
diff --git a/arch/sparc/Kconfig b/arch/sparc/Kconfig
index 0be3828752e5..4e83f950713e 100644
--- a/arch/sparc/Kconfig
+++ b/arch/sparc/Kconfig
@@ -44,7 +44,6 @@ config SPARC
 	select ARCH_HAS_SG_CHAIN
 	select CPU_NO_EFFICIENT_FFS
 	select LOCKDEP_SMALL if LOCKDEP
-	select ARCH_WANT_RELAX_ORDER
 
 config SPARC32
 	def_bool !64BIT
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
index 2c19070d2a0b..e8c1788aed1f 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
@@ -366,7 +366,7 @@ s32 ixgbe_start_hw_gen2(struct ixgbe_hw *hw)
 	}
 	IXGBE_WRITE_FLUSH(hw);
 
-#ifndef CONFIG_ARCH_WANT_RELAX_ORDER
+#ifndef CONFIG_SPARC
 	/* Disable relaxed ordering */
 	for (i = 0; i < hw->mac.max_tx_queues; i++) {
 		u32 regval;
-- 
2.14.2
