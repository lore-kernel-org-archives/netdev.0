From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH] ixgbe: fix compile warning without DCB
Date: Thu, 19 Nov 2009 23:07:58 -0800
Message-ID: <20091120070745.30460.28687.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta05.emeryville.ca.mail.comcast.net ([76.96.30.48]:50070 "EHLO
	QMTA05.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755833AbZKTHIJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2009 02:08:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When DCB is disabled, gcc warns about an unused varaible.  Fixed by making
the variable only available when DCB is enabled.

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index a5036f7..7cc6e93 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -240,7 +240,9 @@ static void ixgbe_unmap_and_free_tx_resource(struct ixgbe_adapter *adapter,
 static inline bool ixgbe_tx_is_paused(struct ixgbe_adapter *adapter,
                                       struct ixgbe_ring *tx_ring)
 {
+#ifdef CONFIG_IXGBE_DCB
 	int tc;
+#endif
 	u32 txoff = IXGBE_TFCS_TXOFF;
 
 #ifdef CONFIG_IXGBE_DCB

