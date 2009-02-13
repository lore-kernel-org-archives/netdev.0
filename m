From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 3/6] igb: cleanup incorrect comment and set IP
	Checksum Enable
Date: Thu, 12 Feb 2009 20:17:42 -0800
Message-ID: <20090213041742.3848.64015.stgit@lost.foo-projects.org>
References: <20090213041654.3848.39227.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta04.emeryville.ca.mail.comcast.net ([76.96.30.40]:38463 "EHLO
	QMTA04.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758741AbZBMESF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Feb 2009 23:18:05 -0500
In-Reply-To: <20090213041654.3848.39227.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

IP Checksum enable doesn't need packet split in order to function.  It only
requires the use of advanced descriptors which the current igb driver does.
So we can enable it always without any issues.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb_main.c |   14 ++++----------
 1 files changed, 4 insertions(+), 10 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 8701330..5a6bcef 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -1934,17 +1934,11 @@ static void igb_configure_rx(struct igb_adapter *adapter)
 	} else {
 		/* Enable Receive Checksum Offload for TCP and UDP */
 		rxcsum = rd32(E1000_RXCSUM);
-		if (adapter->rx_csum) {
-			rxcsum |= E1000_RXCSUM_TUOFL;
+		if (adapter->rx_csum)
+			rxcsum |= E1000_RXCSUM_TUOFL | E1000_RXCSUM_IPPCSE;
+		else
+			rxcsum &= ~(E1000_RXCSUM_TUOFL | E1000_RXCSUM_IPPCSE);
 
-			/* Enable IPv4 payload checksum for UDP fragments
-			 * Must be used in conjunction with packet-split. */
-			if (adapter->rx_ps_hdr_size)
-				rxcsum |= E1000_RXCSUM_IPPCSE;
-		} else {
-			rxcsum &= ~E1000_RXCSUM_TUOFL;
-			/* don't need to clear IPPCSE as it defaults to 0 */
-		}
 		wr32(E1000_RXCSUM, rxcsum);
 	}
 

