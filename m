From: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Subject: [PATCH] net: ethernet: ibm: ehea: ehea_qmr.c:  Fix for possible null pointer dereference
Date: Sun, 18 May 2014 18:01:21 +0200
Message-ID: <1400428881-10310-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Cc: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>,
	linux-kernel@vger.kernel.org
To: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There is otherwise a risk of a possible null pointer dereference.

Was largely found by using a static code analysis program called cppcheck.

Signed-off-by: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
---
 drivers/net/ethernet/ibm/ehea/ehea_qmr.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ibm/ehea/ehea_qmr.c b/drivers/net/ethernet/ibm/ehea/ehea_qmr.c
index 9b03033..a0820f7 100644
--- a/drivers/net/ethernet/ibm/ehea/ehea_qmr.c
+++ b/drivers/net/ethernet/ibm/ehea/ehea_qmr.c
@@ -103,12 +103,14 @@ out_nomem:
 
 static void hw_queue_dtor(struct hw_queue *queue)
 {
-	int pages_per_kpage = PAGE_SIZE / queue->pagesize;
+	int pages_per_kpage;
 	int i, nr_pages;
 
 	if (!queue || !queue->queue_pages)
 		return;
 
+	pages_per_kpage = PAGE_SIZE / queue->pagesize;
+
 	nr_pages = queue->queue_length / queue->pagesize;
 
 	for (i = 0; i < nr_pages; i += pages_per_kpage)
-- 
1.7.10.4
