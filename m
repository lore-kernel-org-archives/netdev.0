From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 17/18] igb: change descriptor control thresholds
Date: Wed, 17 Feb 2010 03:05:56 -0800
Message-ID: <20100217110555.17723.82362.stgit@localhost.localdomain>
References: <20100217105953.17723.36633.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Nicholas Nunley <nicholasx.d.nunley@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta12.westchester.pa.mail.comcast.net ([76.96.59.227]:56527
	"EHLO qmta12.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754873Ab0BQLGO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2010 06:06:14 -0500
In-Reply-To: <20100217105953.17723.36633.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nick Nunley <nicholasx.d.nunley@intel.com>

This change simplifies the code by setting RX_PTHRESH to 8 for
all devices, as it was unlikely that there was any advantage to
set it at 16 for earlier cards. Additionally TX_WTHRESH is
set to 1 for the 82576 NIC to improve performance by enabling
a minimal amount of write combining when writing back descriptors.

Signed-off-by: Nicholas Nunley <nicholasx.d.nunley@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/igb/igb.h b/drivers/net/igb/igb.h
index 7854b66..a177570 100644
--- a/drivers/net/igb/igb.h
+++ b/drivers/net/igb/igb.h
@@ -95,13 +95,13 @@ struct vf_data_storage {
  *           descriptors until either it has this many to write back, or the
  *           ITR timer expires.
  */
-#define IGB_RX_PTHRESH                    (hw->mac.type <= e1000_82576 ? 16 : 8)
+#define IGB_RX_PTHRESH                     8
 #define IGB_RX_HTHRESH                     8
 #define IGB_RX_WTHRESH                     1
 #define IGB_TX_PTHRESH                     8
 #define IGB_TX_HTHRESH                     1
 #define IGB_TX_WTHRESH                     ((hw->mac.type == e1000_82576 && \
-                                             adapter->msix_entries) ? 0 : 16)
+                                             adapter->msix_entries) ? 1 : 16)
 
 /* this is the size past which hardware will drop packets when setting LPE=0 */
 #define MAXIMUM_ETHERNET_VLAN_SIZE 1522

