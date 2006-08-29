From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 04/26] e1000: ring buffers resources cleanup
Date: Tue, 29 Aug 2006 09:44:23 -0700
Message-ID: <20060829164423.6872.583.stgit@gitlost.site>
References: <20060829164153.6872.1713.stgit@gitlost.site>
Cc: netdev@vger.kernel.org, akpm@osdl.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:28938 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S965076AbWH2QgJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2006 12:36:09 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20060829164153.6872.1713.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Memory leak was found in 2.6.18-rc4 and e1000 7.2.7 from sourceforge: We
should free resources allocated for previous rings if following allocation
fails.

Signed-off-by: Vasily Averin <vvs@sw.ru>
Signed-off-by: Andrew Morton <akpm@osdl.org>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000_main.c |   14 ++++++--------
 1 files changed, 6 insertions(+), 8 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index c273b45..426811a 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -1395,10 +1395,6 @@ setup_tx_desc_die:
  * 				  (Descriptors) for all queues
  * @adapter: board private structure
  *
- * If this function returns with an error, then it's possible one or
- * more of the rings is populated (while the rest are not).  It is the
- * callers duty to clean those orphaned rings.
- *
  * Return 0 on success, negative on failure
  **/
 
@@ -1412,6 +1408,9 @@ e1000_setup_all_tx_resources(struct e100
 		if (err) {
 			DPRINTK(PROBE, ERR,
 				"Allocation for Tx Queue %u failed\n", i);
+			for (i-- ; i >= 0; i--)
+				e1000_free_tx_resources(adapter,
+							&adapter->tx_ring[i]);
 			break;
 		}
 	}
@@ -1651,10 +1650,6 @@ setup_rx_desc_die:
  * 				  (Descriptors) for all queues
  * @adapter: board private structure
  *
- * If this function returns with an error, then it's possible one or
- * more of the rings is populated (while the rest are not).  It is the
- * callers duty to clean those orphaned rings.
- *
  * Return 0 on success, negative on failure
  **/
 
@@ -1668,6 +1663,9 @@ e1000_setup_all_rx_resources(struct e100
 		if (err) {
 			DPRINTK(PROBE, ERR,
 				"Allocation for Rx Queue %u failed\n", i);
+			for (i-- ; i >= 0; i--)
+				e1000_free_rx_resources(adapter,
+							&adapter->rx_ring[i]);
 			break;
 		}
 	}



---
Auke Kok <auke-jan.h.kok@intel.com>
