From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH] igb: drop support for UDP hashing w/ RSS
Date: Thu, 01 Jul 2010 23:01:05 -0700
Message-ID: <20100702060056.16863.23072.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta12.westchester.pa.mail.comcast.net ([76.96.59.227]:48852
	"EHLO qmta12.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751593Ab0GBGBZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jul 2010 02:01:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change removes UDP from the supported protocols for RSS hashing.  The
reason for removing this protocol is because IP fragmentation was causing a
network flow to be broken into two streams, one for fragmented, and one for
non-fragmented and this in turn was causing out-of-order issues.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb_main.c |   18 ++++++++++--------
 1 files changed, 10 insertions(+), 8 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 9cb04e2..9465617 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -2717,14 +2717,16 @@ static void igb_setup_mrqc(struct igb_adapter *adapter)
 	}
 	igb_vmm_control(adapter);
 
-	mrqc |= (E1000_MRQC_RSS_FIELD_IPV4 |
-		 E1000_MRQC_RSS_FIELD_IPV4_TCP);
-	mrqc |= (E1000_MRQC_RSS_FIELD_IPV6 |
-		 E1000_MRQC_RSS_FIELD_IPV6_TCP);
-	mrqc |= (E1000_MRQC_RSS_FIELD_IPV4_UDP |
-		 E1000_MRQC_RSS_FIELD_IPV6_UDP);
-	mrqc |= (E1000_MRQC_RSS_FIELD_IPV6_UDP_EX |
-		 E1000_MRQC_RSS_FIELD_IPV6_TCP_EX);
+	/*
+	 * Generate RSS hash based on TCP port numbers and/or
+	 * IPv4/v6 src and dst addresses since UDP cannot be
+	 * hashed reliably due to IP fragmentation
+	 */
+	mrqc |= E1000_MRQC_RSS_FIELD_IPV4 |
+		E1000_MRQC_RSS_FIELD_IPV4_TCP |
+		E1000_MRQC_RSS_FIELD_IPV6 |
+		E1000_MRQC_RSS_FIELD_IPV6_TCP |
+		E1000_MRQC_RSS_FIELD_IPV6_TCP_EX;
 
 	wr32(E1000_MRQC, mrqc);
 }

