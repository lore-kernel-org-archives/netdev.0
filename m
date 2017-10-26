From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 6/6] i40e: Add programming descriptors to cleaned_count
Date: Thu, 26 Oct 2017 09:19:55 -0700
Message-ID: <20171026161955.4407-7-jeffrey.t.kirsher@intel.com>
References: <20171026161955.4407-1-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from [134.134.136.20] ([134.134.136.20]:55616 "EHLO mga02.intel.com"
        rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
        id S932446AbdJZQUV (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 26 Oct 2017 12:20:21 -0400
In-Reply-To: <20171026161955.4407-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch updates the i40e driver to include programming descriptors in
the cleaned_count. Without this change it becomes possible for us to leak
memory as we don't trigger a large enough allocation when the time comes to
allocate new buffers and we end up overwriting a number of rx_buffers equal
to the number of programming descriptors we encountered.

Fixes: 0e626ff7ccbf ("i40e: Fix support for flow director programming status")
Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Anders K. Pedersen <akp@cohaesio.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index ab142e05e196..120c68f78951 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -2102,6 +2102,7 @@ static int i40e_clean_rx_irq(struct i40e_ring *rx_ring, int budget)
 
 		if (unlikely(i40e_rx_is_programming_status(qword))) {
 			i40e_clean_programming_status(rx_ring, rx_desc, qword);
+			cleaned_count++;
 			continue;
 		}
 		size = (qword & I40E_RXD_QW1_LENGTH_PBUF_MASK) >>
-- 
2.14.2
