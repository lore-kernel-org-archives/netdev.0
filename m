From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH 1/2] e1000: Simple optimizations in e1000_xmit_frame
Date: Fri, 05 Oct 2007 14:15:16 -0700
Message-ID: <20071005211516.13167.80891.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, krkumar2@in.ibm.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:40410 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762694AbXJEVPt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Oct 2007 17:15:49 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Krishna Kumar <krkumar2@in.ibm.com>

Some simple optimizations in e1000_xmit_frame.

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---

 drivers/net/e1000/e1000_main.c |    9 ++++-----
 1 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 10505de..0472638 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -3261,14 +3261,13 @@ e1000_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	unsigned int first, max_per_txd = E1000_MAX_DATA_PER_TXD;
 	unsigned int max_txd_pwr = E1000_MAX_TXD_PWR;
 	unsigned int tx_flags = 0;
-	unsigned int len = skb->len;
+	unsigned int len = skb->len - skb->data_len;
 	unsigned long flags;
-	unsigned int nr_frags = 0;
-	unsigned int mss = 0;
+	unsigned int nr_frags;
+	unsigned int mss;
 	int count = 0;
 	int tso;
 	unsigned int f;
-	len -= skb->data_len;
 
 	/* This goes back to the question of how to logically map a tx queue
 	 * to a flow.  Right now, performance is impacted slightly negatively
@@ -3302,7 +3301,7 @@ e1000_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 		* points to just header, pull a few bytes of payload from
 		* frags into skb->data */
 		hdr_len = skb_transport_offset(skb) + tcp_hdrlen(skb);
-		if (skb->data_len && (hdr_len == (skb->len - skb->data_len))) {
+		if (skb->data_len && hdr_len == len) {
 			switch (adapter->hw.mac_type) {
 				unsigned int pull_size;
 			case e1000_82544:
