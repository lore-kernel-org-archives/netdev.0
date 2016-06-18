From: Amitoj Kaur Chawla <amitoj1606@gmail.com>
Subject: [PATCH] net: cavium: liquidio: Use vzalloc instead of vmalloc
Date: Sat, 18 Jun 2016 12:23:20 +0530
Message-ID: <20160618065320.GA1906@amitoj-Inspiron-3542>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: julia.lawall@lip6.fr
To: derek.chickles@caviumnetworks.com,
	satananda.burla@caviumnetworks.com,
	felix.manlunas@caviumnetworks.com,
	raghu.vatsavayi@caviumnetworks.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

vzalloc combines vmalloc and memset 0.

The Coccinelle semantic patch used to make this change is as follows:
@@
type T;
T *d;
expression e;
statement S;
@@

        d =
-            vmalloc
+            vzalloc
             (...);
        if (!d) S
-       memset(d, 0, sizeof(T));

Signed-off-by: Amitoj Kaur Chawla <amitoj1606@gmail.com>
---
 drivers/net/ethernet/cavium/liquidio/octeon_device.c | 9 ++-------
 1 file changed, 2 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_device.c b/drivers/net/ethernet/cavium/liquidio/octeon_device.c
index f67641a..2bf90c1 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_device.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_device.c
@@ -759,13 +759,10 @@ int octeon_setup_instr_queues(struct octeon_device *oct)
 
 	for (i = 0; i < num_iqs; i++) {
 		oct->instr_queue[i] =
-			vmalloc(sizeof(struct octeon_instr_queue));
+			vzalloc(sizeof(struct octeon_instr_queue));
 		if (!oct->instr_queue[i])
 			return 1;
 
-		memset(oct->instr_queue[i], 0,
-		       sizeof(struct octeon_instr_queue));
-
 		oct->instr_queue[i]->app_ctx = (void *)(size_t)i;
 		if (octeon_init_instr_queue(oct, i, num_descs))
 			return 1;
@@ -795,12 +792,10 @@ int octeon_setup_output_queues(struct octeon_device *oct)
 	oct->num_oqs = 0;
 
 	for (i = 0; i < num_oqs; i++) {
-		oct->droq[i] = vmalloc(sizeof(*oct->droq[i]));
+		oct->droq[i] = vzalloc(sizeof(*oct->droq[i]));
 		if (!oct->droq[i])
 			return 1;
 
-		memset(oct->droq[i], 0, sizeof(struct octeon_droq));
-
 		if (octeon_init_droq(oct, i, num_descs, desc_size, NULL))
 			return 1;
 
-- 
1.9.1
