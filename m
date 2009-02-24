From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 1/2] ixgbe: Move ring features into an enum,
	allowing easier future maintenance
Date: Tue, 24 Feb 2009 15:40:37 -0800
Message-ID: <20090224234037.29312.54427.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta08.westchester.pa.mail.comcast.net ([76.96.62.80]:59542
	"EHLO QMTA08.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757317AbZBXXk5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2009 18:40:57 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

The ring_feature member of ixgbe_adapter is statically allocated based on
the supported features of the device.  When a new feature is added, we need
to manually update the static allocation.  This patch makes the feature
list an enum, eliminating the need for multiple updates to the code when
adding a new feature.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe.h |   14 ++++++++++----
 1 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index e98ace8..c0e56aa 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -148,9 +148,15 @@ struct ixgbe_ring {
 	u16 rx_buf_len;
 };
 
-#define RING_F_DCB  0
-#define RING_F_VMDQ 1
-#define RING_F_RSS  2
+enum ixgbe_ring_f_enum {
+	RING_F_NONE = 0,
+	RING_F_DCB,
+	RING_F_VMDQ,
+	RING_F_RSS,
+
+	RING_F_ARRAY_SIZE      /* must be last in enum set */
+};
+
 #define IXGBE_MAX_DCB_INDICES   8
 #define IXGBE_MAX_RSS_INDICES  16
 #define IXGBE_MAX_VMDQ_INDICES 16
@@ -249,7 +255,7 @@ struct ixgbe_adapter {
 	u64 non_eop_descs;
 	int num_msix_vectors;
 	int max_msix_q_vectors;         /* true count of q_vectors for device */
-	struct ixgbe_ring_feature ring_feature[3];
+	struct ixgbe_ring_feature ring_feature[RING_F_ARRAY_SIZE];
 	struct msix_entry *msix_entries;
 
 	u64 rx_hdr_split;

