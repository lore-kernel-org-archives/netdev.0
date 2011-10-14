From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 4/6] igb: enable l4 timestamping for v2 event packets
Date: Thu, 13 Oct 2011 23:21:26 -0700
Message-ID: <1318573288-18286-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1318573288-18286-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:8874 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751681Ab1JNGVd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Oct 2011 02:21:33 -0400
In-Reply-To: <1318573288-18286-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

When enabling hardware timestamping for ptp v2 event packets, the
software does not setup the queue for l4 packets, although layer 4
packets are valid for v2. This patch adds the flag which enables
setting up a queue and enabling udp packet timestamping.

Signed-off-by: Jacob E Keller <jacob.e.keller@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 06109af..c10cc71 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -6268,6 +6268,7 @@ static int igb_hwtstamp_ioctl(struct net_device *netdev,
 		tsync_rx_ctl |= E1000_TSYNCRXCTL_TYPE_EVENT_V2;
 		config.rx_filter = HWTSTAMP_FILTER_PTP_V2_EVENT;
 		is_l2 = true;
+		is_l4 = true;
 		break;
 	default:
 		return -ERANGE;
-- 
1.7.6.4
