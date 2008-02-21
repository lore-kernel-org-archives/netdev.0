From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH 1/7] ixgb: add RNBC counter - no buffer count - to ethtool
	stats
Date: Thu, 21 Feb 2008 15:10:41 -0800
Message-ID: <20080221231041.5595.4933.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:11050 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755941AbYBUXVl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Feb 2008 18:21:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This counter is valuable to determine if the system is unable
to timely return buffers to the hardware and this counter starts
to increase well before the hardware starts to drop packets. If
users experience rx_no_buffer_count increasing, they should increase
the amount of descriptors. That will provide more buffers for the
hardware and will decrease the chance of hard drops.

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/ixgb/ixgb_ethtool.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ixgb/ixgb_ethtool.c b/drivers/net/ixgb/ixgb_ethtool.c
index 53a9fd0..75f3a68 100644
--- a/drivers/net/ixgb/ixgb_ethtool.c
+++ b/drivers/net/ixgb/ixgb_ethtool.c
@@ -67,6 +67,7 @@ static struct ixgb_stats ixgb_gstrings_stats[] = {
 	{"rx_over_errors", IXGB_STAT(net_stats.rx_over_errors)},
 	{"rx_crc_errors", IXGB_STAT(net_stats.rx_crc_errors)},
 	{"rx_frame_errors", IXGB_STAT(net_stats.rx_frame_errors)},
+	{"rx_no_buffer_count", IXGB_STAT(stats.rnbc)},
 	{"rx_fifo_errors", IXGB_STAT(net_stats.rx_fifo_errors)},
 	{"rx_missed_errors", IXGB_STAT(net_stats.rx_missed_errors)},
 	{"tx_aborted_errors", IXGB_STAT(net_stats.tx_aborted_errors)},

