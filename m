From: Santiago Leon <santil@us.ibm.com>
Subject: [PATCH] 1/5 ibmveth fix bonding
Date: Tue, 25 Oct 2005 16:27:02 -0500
Message-ID: <1130275458.10524.425.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932394AbVJYV2R@vger.kernel.org>
To: netdev <netdev@vger.kernel.org>,
	lkml <linux-kernel@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch updates dev->trans_start and dev->last_rx so that the ibmveth
driver can be used with the ARP monitor in the bonding driver. 

Signed-off-by: Santiago Leon <santil@us.ibm.com>
---
 drivers/net/ibmveth.c |    2 ++
 1 files changed, 2 insertions(+)
---
diff -urN a/drivers/net/ibmveth.c b/drivers/net/ibmveth.c
--- a/drivers/net/ibmveth.c	2005-10-11 12:56:24.000000000 -0500
+++ b/drivers/net/ibmveth.c	2005-10-11 13:52:45.000000000 -0500
@@ -725,6 +725,7 @@
 	} else {
 		adapter->stats.tx_packets++;
 		adapter->stats.tx_bytes += skb->len;
+		netdev->trans_start = jiffies;
 	}
 
 	do {
@@ -776,6 +777,7 @@
 				adapter->stats.rx_packets++;
 				adapter->stats.rx_bytes += length;
 				frames_processed++;
+				netdev->last_rx = jiffies;
 			}
 		} else {
 			more_work = 0;

-- 
Santiago A. Leon
Power Linux Development
IBM Linux Technology Center
