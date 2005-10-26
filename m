From: Santiago Leon <santil@us.ibm.com>
Subject: [PATCH 1/5] ibmveth fix bonding
Date: Wed, 26 Oct 2005 10:46:53 -0600
Message-ID: <20051026164539.21820.57374.sendpatchset@localhost.localdomain>
References: <20051026164532.21820.72673.sendpatchset@localhost.localdomain>
Cc: Santiago Leon <santil@us.ibm.com>, Jeff Garzik <jgarzik@pobox.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964811AbVJZQq6@vger.kernel.org>
To: Andrew Morton <akpm@osdl.org>, netdev <netdev@vger.kernel.org>,
	lkml <linux-kernel@vger.kernel.org>
In-Reply-To: <20051026164532.21820.72673.sendpatchset@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch updates dev->trans_start and dev->last_rx so that the ibmveth
driver can be used with the ARP monitor in the bonding driver. 

Signed-off-by: Santiago Leon <santil@us.ibm.com>
---

 drivers/net/ibmveth.c |    2 ++
 1 files changed, 2 insertions(+)

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
