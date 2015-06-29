From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH] net-Liquidio: Delete unnecessary checks before the function
 call "vfree"
Date: Mon, 29 Jun 2015 12:48:16 +0200
Message-ID: <55912270.4030201@users.sourceforge.net>
References: <5307CAA2.8060406@users.sourceforge.net> <alpine.DEB.2.02.1402212321410.2043@localhost6.localdomain6> <530A086E.8010901@users.sourceforge.net> <alpine.DEB.2.02.1402231635510.1985@localhost6.localdomain6> <530A72AA.3000601@users.sourceforge.net> <alpine.DEB.2.02.1402240658210.2090@localhost6.localdomain6> <530B5FB6.6010207@users.sourceforge.net> <alpine.DEB.2.10.1402241710370.2074@hadrien> <530C5E18.1020800@users.sourceforge.net> <alpine.DEB.2.10.1402251014170.2080@hadrien> <530CD2C4.4050903@users.sourceforge.net> <alpine.DEB.2.10.1402251840450.7035@hadrien> <530CF8FF.8080600@users.sourceforge.net> <alpine.DEB.2.02.1402252117150.2047@localhost6.localdomain6> <530DD06F.4090703@users.sourceforge.net> <alpine.DEB.2.02.1402262129250.2221@localhost6.localdomain6> <5317A59D.4@users.so
 urceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	kernel-janitors@vger.kernel.org,
	Julia Lawall <julia.lawall@lip6.fr>
To: Derek Chickles <derek.chickles@caviumnetworks.com>,
	Felix Manlunas <felix.manlunas@caviumnetworks.com>,
	Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>,
	Robert Richter <rric@kernel.org>,
	Satanand Burla <satananda.burla@caviumnetworks.com>,
	Sunil Goutham <sgoutham@cavium.com>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5317A59D.4@users.sourceforge.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Mon, 29 Jun 2015 12:22:24 +0200

The vfree() function performs also input parameter validation.
Thus the test around the call is not needed.

This issue was detected by using the Coccinelle software.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/net/ethernet/cavium/liquidio/octeon_device.c   | 11 +++--------
 drivers/net/ethernet/cavium/liquidio/octeon_droq.c     |  4 +---
 drivers/net/ethernet/cavium/liquidio/request_manager.c |  3 +--
 3 files changed, 5 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_device.c b/drivers/net/ethernet/cavium/liquidio/octeon_device.c
index 0d3106b..f67641a 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_device.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_device.c
@@ -650,14 +650,12 @@ void octeon_free_device_mem(struct octeon_device *oct)
 
 	for (i = 0; i < MAX_OCTEON_OUTPUT_QUEUES; i++) {
 		/* could check  mask as well */
-		if (oct->droq[i])
-			vfree(oct->droq[i]);
+		vfree(oct->droq[i]);
 	}
 
 	for (i = 0; i < MAX_OCTEON_INSTR_QUEUES; i++) {
 		/* could check mask as well */
-		if (oct->instr_queue[i])
-			vfree(oct->instr_queue[i]);
+		vfree(oct->instr_queue[i]);
 	}
 
 	i = oct->octeon_id;
@@ -1078,10 +1076,7 @@ octeon_unregister_dispatch_fn(struct octeon_device *oct, u16 opcode,
 		oct->dispatch.count--;
 
 	spin_unlock_bh(&oct->dispatch.lock);
-
-	if (dfree)
-		vfree(dfree);
-
+	vfree(dfree);
 	return retval;
 }
 
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_droq.c b/drivers/net/ethernet/cavium/liquidio/octeon_droq.c
index 94b502a..4dba86e 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_droq.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_droq.c
@@ -216,9 +216,7 @@ int octeon_delete_droq(struct octeon_device *oct, u32 q_no)
 	dev_dbg(&oct->pci_dev->dev, "%s[%d]\n", __func__, q_no);
 
 	octeon_droq_destroy_ring_buffers(oct, droq);
-
-	if (droq->recv_buf_list)
-		vfree(droq->recv_buf_list);
+	vfree(droq->recv_buf_list);
 
 	if (droq->info_base_addr)
 		cnnic_free_aligned_dma(oct->pci_dev, droq->info_list,
diff --git a/drivers/net/ethernet/cavium/liquidio/request_manager.c b/drivers/net/ethernet/cavium/liquidio/request_manager.c
index 356796b..a2a2465 100644
--- a/drivers/net/ethernet/cavium/liquidio/request_manager.c
+++ b/drivers/net/ethernet/cavium/liquidio/request_manager.c
@@ -175,8 +175,7 @@ int octeon_delete_instr_queue(struct octeon_device *oct, u32 iq_no)
 		desc_size =
 		    CFG_GET_IQ_INSTR_TYPE(CHIP_FIELD(oct, cn6xxx, conf));
 
-	if (iq->request_list)
-		vfree(iq->request_list);
+	vfree(iq->request_list);
 
 	if (iq->base_addr) {
 		q_size = iq->max_count * desc_size;
-- 
2.4.5
