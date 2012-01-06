From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [RFC] pktgen: set correct max and min in pktgen_setup_inject()
Date: Fri, 6 Jan 2012 16:13:47 +0300
Message-ID: <20120106131346.GA2491@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jesse Brandeburg <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet15.oracle.com ([148.87.113.117]:22515 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751090Ab2AFNN5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2012 08:13:57 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In 882716604ec "pktgen: fix multiple queue warning" we added special
logic to handle the case where ntxq is zero.  It's not clear to me that
ntxq can actually be zero.  But if it were then we would set
->queue_map_min and ->queue_map_max to USHRT_MAX when probably we want
to set them to zero?

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 449fe0f..65f80c7 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -2024,13 +2024,13 @@ static void pktgen_setup_inject(struct pktgen_dev *pkt_dev)
 		pr_warning("WARNING: Requested queue_map_min (zero-based) (%d) exceeds valid range [0 - %d] for (%d) queues on %s, resetting\n",
 			   pkt_dev->queue_map_min, (ntxq ?: 1) - 1, ntxq,
 			   pkt_dev->odevname);
-		pkt_dev->queue_map_min = ntxq - 1;
+		pkt_dev->queue_map_min = (ntxq ?: 1) - 1;
 	}
 	if (pkt_dev->queue_map_max >= ntxq) {
 		pr_warning("WARNING: Requested queue_map_max (zero-based) (%d) exceeds valid range [0 - %d] for (%d) queues on %s, resetting\n",
 			   pkt_dev->queue_map_max, (ntxq ?: 1) - 1, ntxq,
 			   pkt_dev->odevname);
-		pkt_dev->queue_map_max = ntxq - 1;
+		pkt_dev->queue_map_max = (ntxq ?: 1) - 1;
 	}
 
 	/* Default to the interface's mac if not explicitly set. */
