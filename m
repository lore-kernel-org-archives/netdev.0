From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next 4/4] ixgbe: enable IXGBE_ALLOW_RELAXED_ORDER for ARM64
Date: Sat, 1 Apr 2017 15:25:54 +0800
Message-ID: <1491031554-19516-5-git-send-email-dingtianhong@huawei.com>
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
Received: from szxga01-in.huawei.com ([45.249.212.187]:5293 "EHLO
        dggrg01-dlp.huawei.com" rhost-flags-OK-FAIL-OK-FAIL)
        by vger.kernel.org with ESMTP id S1750787AbdDAH0q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 1 Apr 2017 03:26:46 -0400
In-Reply-To: <1491031554-19516-1-git-send-email-dingtianhong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The IXGBE_ALLOW_RELAXED_ORDER will enable Relaxed Ordering (RO) which allows
transactions that do not have any order of completion requirements to
complete more efficiently compare to the Stricted Ordering (SO) for ixgbe
net card. Some architecture will see high write-to-memory performance when RO is
enabled on the data transactions just like the SPARC did.

The aarch64 could both support Relaxed Ordering (RO) and Stricted Ordering (SO),
so enable this config could get much more better performance, didn't see any
adverse effects.

Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/ethernet/intel/Kconfig | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/Kconfig b/drivers/net/ethernet/intel/Kconfig
index 33ef2b6..6743b7e 100644
--- a/drivers/net/ethernet/intel/Kconfig
+++ b/drivers/net/ethernet/intel/Kconfig
@@ -276,7 +276,7 @@ config FM10K
 	  will be called fm10k.  MSI-X interrupt support is required
 
 config IXGBE_ALLOW_RELAXED_ORDER
-	bool "Intel(R) 10GbE PCI Express adapters Enable Relaxed Ordering" if SPARC
-	default y if SPARC
+	bool "Intel(R) 10GbE PCI Express adapters Enable Relaxed Ordering" if (SPARC || ARM64)
+	default y if (SPARC || ARM64)
 
 endif # NET_VENDOR_INTEL
-- 
1.9.0
