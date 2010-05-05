From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 1/2] e1000e: increase rx fifo size to 36K on
	82574 and 82583
Date: Wed, 05 May 2010 01:25:42 -0700
Message-ID: <20100505082537.5956.86868.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta07.westchester.pa.mail.comcast.net ([76.96.62.64]:48290
	"EHLO qmta07.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932155Ab0EEI0A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 May 2010 04:26:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change increases the RX fifo size to 36K for standard frames and
decreases the TX fifo size to 4K.  The reason for this change is that on
slower systems the RX is much more likely to backfill and need space than
the TX is.  As long as the TX fifo is twice the size of the MTU we should
have more than enough TX fifo.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/82571.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/e1000e/82571.c b/drivers/net/e1000e/82571.c
index 17a25e1..1e73edd 100644
--- a/drivers/net/e1000e/82571.c
+++ b/drivers/net/e1000e/82571.c
@@ -1845,7 +1845,7 @@ struct e1000_info e1000_82574_info = {
 				  | FLAG_HAS_SMART_POWER_DOWN
 				  | FLAG_HAS_AMT
 				  | FLAG_HAS_CTRLEXT_ON_LOAD,
-	.pba			= 20,
+	.pba			= 36,
 	.max_hw_frame_size	= DEFAULT_JUMBO,
 	.get_variants		= e1000_get_variants_82571,
 	.mac_ops		= &e82571_mac_ops,
@@ -1862,7 +1862,7 @@ struct e1000_info e1000_82583_info = {
 				  | FLAG_HAS_SMART_POWER_DOWN
 				  | FLAG_HAS_AMT
 				  | FLAG_HAS_CTRLEXT_ON_LOAD,
-	.pba			= 20,
+	.pba			= 36,
 	.max_hw_frame_size	= ETH_FRAME_LEN + ETH_FCS_LEN,
 	.get_variants		= e1000_get_variants_82571,
 	.mac_ops		= &e82571_mac_ops,

