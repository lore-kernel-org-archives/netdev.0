From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/15] i40e/i40evf: rename bytes_per_int to bytes_per_usec
Date: Fri, 29 Sep 2017 17:44:53 -0700
Message-ID: <20170930004507.20072-2-jeffrey.t.kirsher@intel.com>
References: <20170930004507.20072-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:23279 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752635AbdI3Apt (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 29 Sep 2017 20:45:49 -0400
In-Reply-To: <20170930004507.20072-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

This value is not calculating bytes_per_int, which would actually just
be bytes/ITR_COUNTDOWN_START, but rather it's calculating bytes/usecs.

Rename the variable for clarity so that future developers understand
what the value is actually calculating.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c   | 12 ++++++------
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c | 12 ++++++------
 2 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index f426762bd83a..d9fdf69bbc6e 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -960,14 +960,14 @@ static bool i40e_set_new_dynamic_itr(struct i40e_ring_container *rc)
 {
 	enum i40e_latency_range new_latency_range = rc->latency_range;
 	u32 new_itr = rc->itr;
-	int bytes_per_int;
+	int bytes_per_usec;
 	unsigned int usecs, estimated_usecs;
 
 	if (rc->total_packets == 0 || !rc->itr)
 		return false;
 
 	usecs = (rc->itr << 1) * ITR_COUNTDOWN_START;
-	bytes_per_int = rc->total_bytes / usecs;
+	bytes_per_usec = rc->total_bytes / usecs;
 
 	/* The calculations in this algorithm depend on interrupts actually
 	 * firing at the ITR rate. This may not happen if the packet rate is
@@ -993,18 +993,18 @@ static bool i40e_set_new_dynamic_itr(struct i40e_ring_container *rc)
 	 */
 	switch (new_latency_range) {
 	case I40E_LOWEST_LATENCY:
-		if (bytes_per_int > 10)
+		if (bytes_per_usec > 10)
 			new_latency_range = I40E_LOW_LATENCY;
 		break;
 	case I40E_LOW_LATENCY:
-		if (bytes_per_int > 20)
+		if (bytes_per_usec > 20)
 			new_latency_range = I40E_BULK_LATENCY;
-		else if (bytes_per_int <= 10)
+		else if (bytes_per_usec <= 10)
 			new_latency_range = I40E_LOWEST_LATENCY;
 		break;
 	case I40E_BULK_LATENCY:
 	default:
-		if (bytes_per_int <= 20)
+		if (bytes_per_usec <= 20)
 			new_latency_range = I40E_LOW_LATENCY;
 		break;
 	}
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index c32c62462c84..37e1de886d48 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -358,14 +358,14 @@ static bool i40e_set_new_dynamic_itr(struct i40e_ring_container *rc)
 {
 	enum i40e_latency_range new_latency_range = rc->latency_range;
 	u32 new_itr = rc->itr;
-	int bytes_per_int;
+	int bytes_per_usec;
 	unsigned int usecs, estimated_usecs;
 
 	if (rc->total_packets == 0 || !rc->itr)
 		return false;
 
 	usecs = (rc->itr << 1) * ITR_COUNTDOWN_START;
-	bytes_per_int = rc->total_bytes / usecs;
+	bytes_per_usec = rc->total_bytes / usecs;
 
 	/* The calculations in this algorithm depend on interrupts actually
 	 * firing at the ITR rate. This may not happen if the packet rate is
@@ -391,18 +391,18 @@ static bool i40e_set_new_dynamic_itr(struct i40e_ring_container *rc)
 	 */
 	switch (new_latency_range) {
 	case I40E_LOWEST_LATENCY:
-		if (bytes_per_int > 10)
+		if (bytes_per_usec > 10)
 			new_latency_range = I40E_LOW_LATENCY;
 		break;
 	case I40E_LOW_LATENCY:
-		if (bytes_per_int > 20)
+		if (bytes_per_usec > 20)
 			new_latency_range = I40E_BULK_LATENCY;
-		else if (bytes_per_int <= 10)
+		else if (bytes_per_usec <= 10)
 			new_latency_range = I40E_LOWEST_LATENCY;
 		break;
 	case I40E_BULK_LATENCY:
 	default:
-		if (bytes_per_int <= 20)
+		if (bytes_per_usec <= 20)
 			new_latency_range = I40E_LOW_LATENCY;
 		break;
 	}
-- 
2.14.1
