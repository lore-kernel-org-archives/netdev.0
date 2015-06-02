From: Aleksey Makarov <aleksey.makarov@caviumnetworks.com>
Subject: [PATCH 08/10] net: thunderx: remove unneeded type conversions
Date: Tue, 2 Jun 2015 11:00:25 -0700
Message-ID: <1433268028-23992-9-git-send-email-aleksey.makarov@caviumnetworks.com>
References: <1433268028-23992-1-git-send-email-aleksey.makarov@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>,
	David Daney <david.daney@cavium.com>,
	Robert Richter <robert.richter@caviumnetworks.com>,
	Aleksey Makarov <aleksey.makarov@caviumnetworks.com>,
	Sunil Goutham <sgoutham@cavium.com>,
	Robert Richter <rric@kernel.org>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1433268028-23992-1-git-send-email-aleksey.makarov@caviumnetworks.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

No need to cast void* to u8*: pointer arithmetics
works same way for both.

Signed-off-by: Aleksey Makarov <aleksey.makarov@caviumnetworks.com>
---
 drivers/net/ethernet/cavium/thunder/nicvf_queues.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_queues.c b/drivers/net/ethernet/cavium/thunder/nicvf_queues.c
index 7f0e108..8929029 100644
--- a/drivers/net/ethernet/cavium/thunder/nicvf_queues.c
+++ b/drivers/net/ethernet/cavium/thunder/nicvf_queues.c
@@ -62,8 +62,7 @@ static int nicvf_alloc_q_desc_mem(struct nicvf *nic, struct q_desc_mem *dmem,
 
 	/* Align memory address for 'align_bytes' */
 	dmem->phys_base = NICVF_ALIGNED_ADDR((u64)dmem->dma, align_bytes);
-	dmem->base = (void *)((u8 *)dmem->unalign_base +
-			      (dmem->phys_base - dmem->dma));
+	dmem->base = dmem->unalign_base + (dmem->phys_base - dmem->dma);
 	return 0;
 }
 
-- 
2.4.1
