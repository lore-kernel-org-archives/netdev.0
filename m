From: sunil.kovvuri@gmail.com
Subject: [PATCH v2 1/2] net: thunderx: Fix issue with IRQ namimg
Date: Fri, 23 Sep 2016 14:42:27 +0530
Message-ID: <1474621948-9172-2-git-send-email-sunil.kovvuri@gmail.com>
References: <1474621948-9172-1-git-send-email-sunil.kovvuri@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        Sunil Goutham <sgoutham@cavium.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1474621948-9172-1-git-send-email-sunil.kovvuri@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sunil Goutham <sgoutham@cavium.com>

This patch fixes a regression caused by previous commit
when irq name exceeds 20 byte array if interface's name
size is large.

Fixes: e412621394fa ("net: thunderx: Use netdev's name for naming VF's interrupts")
Signed-off-by: Sunil Goutham <sgoutham@cavium.com>
---
 drivers/net/ethernet/cavium/thunder/nic.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/cavium/thunder/nic.h b/drivers/net/ethernet/cavium/thunder/nic.h
index 18d12d3..3042610 100644
--- a/drivers/net/ethernet/cavium/thunder/nic.h
+++ b/drivers/net/ethernet/cavium/thunder/nic.h
@@ -305,7 +305,7 @@ struct nicvf {
 	bool			msix_enabled;
 	u8			num_vec;
 	struct msix_entry	msix_entries[NIC_VF_MSIX_VECTORS];
-	char			irq_name[NIC_VF_MSIX_VECTORS][20];
+	char			irq_name[NIC_VF_MSIX_VECTORS][IFNAMSIZ + 15];
 	bool			irq_allocated[NIC_VF_MSIX_VECTORS];
 	cpumask_var_t		affinity_mask[NIC_VF_MSIX_VECTORS];
 
-- 
2.7.4
