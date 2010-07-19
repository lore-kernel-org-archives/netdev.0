From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 2/5] ixgbe: drop support for UDP in RSS hash
	generation
Date: Mon, 19 Jul 2010 16:59:27 -0700
Message-ID: <20100719235925.14112.65890.stgit@localhost.localdomain>
References: <20100719235831.14112.14175.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta14.emeryville.ca.mail.comcast.net ([76.96.27.212]:43373
	"EHLO qmta14.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S967269Ab0GSX7t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jul 2010 19:59:49 -0400
In-Reply-To: <20100719235831.14112.14175.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change removes UDP from the supported protocols for RSS hashing.  The
reason for removing this protocol is because IP fragmentation was causing a
network flow to be broken into two streams, one for fragmented, and one for
non-fragmented and this in turn was causing out-of-order issues.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Acked-by: Don Skidmore <donald.c.skidmore@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index b235aa1..813d2cb 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -2800,10 +2800,8 @@ static void ixgbe_configure_rx(struct ixgbe_adapter *adapter)
 		    /* Perform hash on these packet types */
 		mrqc |= IXGBE_MRQC_RSS_FIELD_IPV4
 		      | IXGBE_MRQC_RSS_FIELD_IPV4_TCP
-		      | IXGBE_MRQC_RSS_FIELD_IPV4_UDP
 		      | IXGBE_MRQC_RSS_FIELD_IPV6
-		      | IXGBE_MRQC_RSS_FIELD_IPV6_TCP
-		      | IXGBE_MRQC_RSS_FIELD_IPV6_UDP;
+		      | IXGBE_MRQC_RSS_FIELD_IPV6_TCP;
 	}
 	IXGBE_WRITE_REG(hw, IXGBE_MRQC, mrqc);
 

