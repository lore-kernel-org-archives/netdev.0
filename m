From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/10] ixgbe: fixup remaining call sites for arbitrary TCs
Date: Mon, 29 Aug 2011 01:41:01 -0700
Message-ID: <1314607268-26958-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1314607268-26958-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: John Fastabend <john.r.fastabend@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:35742 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753330Ab1H2IlP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Aug 2011 04:41:15 -0400
In-Reply-To: <1314607268-26958-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>

One existing call sites still expect either 4 or 8 traffic
classes to be specified. This fixes this allowing arbitrary
values up to 8 to work as expected.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
Tested-by: Ross Brattain <ross.b.brattain@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index f095a3b..2b1bb60 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -4481,7 +4481,7 @@ static void ixgbe_get_first_reg_idx(struct ixgbe_adapter *adapter, u8 tc,
 		break;
 	case ixgbe_mac_82599EB:
 	case ixgbe_mac_X540:
-		if (num_tcs == 8) {
+		if (num_tcs > 4) {
 			if (tc < 3) {
 				*tx = tc << 5;
 				*rx = tc << 4;
@@ -4492,7 +4492,7 @@ static void ixgbe_get_first_reg_idx(struct ixgbe_adapter *adapter, u8 tc,
 				*tx = ((tc + 8) << 3);
 				*rx = tc << 4;
 			}
-		} else if (num_tcs == 4) {
+		} else {
 			*rx =  tc << 5;
 			switch (tc) {
 			case 0:
-- 
1.7.6
