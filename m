From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 2/4] e1000e: suppress compile warnings on certain
	archs
Date: Tue, 29 Jun 2010 21:12:30 -0700
Message-ID: <20100630041228.8652.61761.stgit@localhost.localdomain>
References: <20100630040959.8652.31147.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta14.emeryville.ca.mail.comcast.net ([76.96.27.212]:41821
	"EHLO qmta14.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750851Ab0F3EMt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jun 2010 00:12:49 -0400
In-Reply-To: <20100630040959.8652.31147.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Commit 84f4ee902ad3ee964b7b3a13d5b7cf9c086e9916 causes compile warnings on
architectures that have unsigned long long's that are not 64-bit, e.g.
ia64.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/netdev.c |   38 +++++++++++++++++++++-----------------
 1 files changed, 21 insertions(+), 17 deletions(-)

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 3e53ca7..6aa795a 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -224,10 +224,10 @@ static void e1000e_dump(struct e1000_adapter *adapter)
 	buffer_info = &tx_ring->buffer_info[tx_ring->next_to_clean];
 	printk(KERN_INFO " %5d %5X %5X %016llX %04X %3X %016llX\n",
 		0, tx_ring->next_to_use, tx_ring->next_to_clean,
-		(u64)buffer_info->dma,
+		(unsigned long long)buffer_info->dma,
 		buffer_info->length,
 		buffer_info->next_to_watch,
-		(u64)buffer_info->time_stamp);
+		(unsigned long long)buffer_info->time_stamp);
 
 	/* Print TX Rings */
 	if (!netif_msg_tx_done(adapter))
@@ -279,9 +279,11 @@ static void e1000e_dump(struct e1000_adapter *adapter)
 			"%04X  %3X %016llX %p",
 		       (!(le64_to_cpu(u0->b) & (1<<29)) ? 'l' :
 			((le64_to_cpu(u0->b) & (1<<20)) ? 'd' : 'c')), i,
-		       le64_to_cpu(u0->a), le64_to_cpu(u0->b),
-		       (u64)buffer_info->dma, buffer_info->length,
-		       buffer_info->next_to_watch, (u64)buffer_info->time_stamp,
+		       (unsigned long long)le64_to_cpu(u0->a),
+		       (unsigned long long)le64_to_cpu(u0->b),
+		       (unsigned long long)buffer_info->dma,
+		       buffer_info->length, buffer_info->next_to_watch,
+		       (unsigned long long)buffer_info->time_stamp,
 		       buffer_info->skb);
 		if (i == tx_ring->next_to_use && i == tx_ring->next_to_clean)
 			printk(KERN_CONT " NTC/U\n");
@@ -356,19 +358,19 @@ rx_ring_summary:
 				printk(KERN_INFO "RWB[0x%03X]     %016llX "
 					"%016llX %016llX %016llX "
 					"---------------- %p", i,
-					le64_to_cpu(u1->a),
-					le64_to_cpu(u1->b),
-					le64_to_cpu(u1->c),
-					le64_to_cpu(u1->d),
+					(unsigned long long)le64_to_cpu(u1->a),
+					(unsigned long long)le64_to_cpu(u1->b),
+					(unsigned long long)le64_to_cpu(u1->c),
+					(unsigned long long)le64_to_cpu(u1->d),
 					buffer_info->skb);
 			} else {
 				printk(KERN_INFO "R  [0x%03X]     %016llX "
 					"%016llX %016llX %016llX %016llX %p", i,
-					le64_to_cpu(u1->a),
-					le64_to_cpu(u1->b),
-					le64_to_cpu(u1->c),
-					le64_to_cpu(u1->d),
-					(u64)buffer_info->dma,
+					(unsigned long long)le64_to_cpu(u1->a),
+					(unsigned long long)le64_to_cpu(u1->b),
+					(unsigned long long)le64_to_cpu(u1->c),
+					(unsigned long long)le64_to_cpu(u1->d),
+					(unsigned long long)buffer_info->dma,
 					buffer_info->skb);
 
 				if (netif_msg_pktdata(adapter))
@@ -405,9 +407,11 @@ rx_ring_summary:
 			buffer_info = &rx_ring->buffer_info[i];
 			u0 = (struct my_u0 *)rx_desc;
 			printk(KERN_INFO "Rl[0x%03X]    %016llX %016llX "
-				"%016llX %p",
-				i, le64_to_cpu(u0->a), le64_to_cpu(u0->b),
-				(u64)buffer_info->dma, buffer_info->skb);
+				"%016llX %p", i,
+				(unsigned long long)le64_to_cpu(u0->a),
+				(unsigned long long)le64_to_cpu(u0->b),
+				(unsigned long long)buffer_info->dma,
+				buffer_info->skb);
 			if (i == rx_ring->next_to_use)
 				printk(KERN_CONT " NTU\n");
 			else if (i == rx_ring->next_to_clean)

