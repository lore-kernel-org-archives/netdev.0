From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 13/13] igb: Fix sparse warning in igb_ptp_rx_pktstamp
Date: Tue, 30 Oct 2012 00:04:30 -0700
Message-ID: <1351580670-8292-14-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1351580670-8292-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:4367 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755336Ab2J3HEi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Oct 2012 03:04:38 -0400
In-Reply-To: <1351580670-8292-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change fixes a sparse warning triggered by us casting the timestamp in
the packet as a u64 instead of as a __le64.  This change corrects that in
order to resolve the sparse warning.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_ptp.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_ptp.c b/drivers/net/ethernet/intel/igb/igb_ptp.c
index a7db4ce..aa10f69 100644
--- a/drivers/net/ethernet/intel/igb/igb_ptp.c
+++ b/drivers/net/ethernet/intel/igb/igb_ptp.c
@@ -455,7 +455,7 @@ void igb_ptp_rx_pktstamp(struct igb_q_vector *q_vector,
 			 unsigned char *va,
 			 struct sk_buff *skb)
 {
-	u64 *regval = (u64 *)va;
+	__le64 *regval = (__le64 *)va;
 
 	/*
 	 * The timestamp is recorded in little endian format.
-- 
1.7.11.7
