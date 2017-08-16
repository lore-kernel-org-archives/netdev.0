From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net 1/2] Revert commit 1a8b6d76dc5b ("net:add one common config...")
Date: Wed, 16 Aug 2017 17:41:46 +0800
Message-ID: <1502876507-9360-2-git-send-email-dingtianhong@huawei.com>
References: <1502876507-9360-1-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ding Tianhong <dingtianhong@huawei.com>
To: <davem@davemloft.net>, <jeffrey.t.kirsher@intel.com>,
        <keescook@chromium.org>, <linux-kernel@vger.kernel.org>,
        <sparclinux@vger.kernel.org>, <intel-wired-lan@lists.osuosl.org>,
        <alexander.duyck@gmail.com>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1502876507-9360-1-git-send-email-dingtianhong@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
---
 arch/Kconfig                                    | 3 ---
 arch/sparc/Kconfig                              | 1 -
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c | 2 +-
 3 files changed, 1 insertion(+), 5 deletions(-)

diff --git a/arch/Kconfig b/arch/Kconfig
index 21d0089..00cfc63 100644
--- a/arch/Kconfig
+++ b/arch/Kconfig
@@ -928,9 +928,6 @@ config STRICT_MODULE_RWX
 	  and non-text memory will be made non-executable. This provides
 	  protection against certain security exploits (e.g. writing to text)
 
-config ARCH_WANT_RELAX_ORDER
-	bool
-
 config REFCOUNT_FULL
 	bool "Perform full reference count validation at the expense of speed"
 	help
diff --git a/arch/sparc/Kconfig b/arch/sparc/Kconfig
index a4a6261..987a575 100644
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
index 4e35e70..d4933d2 100644
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
1.8.3.1
