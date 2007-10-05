From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH 2/2] e1000e: Simple optimizations in e1000_xmit_frame
Date: Fri, 05 Oct 2007 14:15:23 -0700
Message-ID: <20071005211523.13167.53985.stgit@localhost.localdomain>
References: <20071005211516.13167.80891.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, krkumar2@in.ibm.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:40410 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763040AbXJEVPt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Oct 2007 17:15:49 -0400
In-Reply-To: <20071005211516.13167.80891.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

After an e1000 patch from Krishna Kumar <krkumar2@in.ibm.com>.

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000e/netdev.c |    9 ++++-----
 1 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 71c9fed..033e124 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -3424,14 +3424,13 @@ static int e1000_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	unsigned int max_per_txd = E1000_MAX_PER_TXD;
 	unsigned int max_txd_pwr = E1000_MAX_TXD_PWR;
 	unsigned int tx_flags = 0;
-	unsigned int len = skb->len;
+	unsigned int len = skb->len - skb->data_len;
 	unsigned long irq_flags;
-	unsigned int nr_frags = 0;
-	unsigned int mss = 0;
+	unsigned int nr_frags;
+	unsigned int mss;
 	int count = 0;
 	int tso;
 	unsigned int f;
-	len -= skb->data_len;
 
 	if (test_bit(__E1000_DOWN, &adapter->state)) {
 		dev_kfree_skb_any(skb);
@@ -3459,7 +3458,7 @@ static int e1000_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 		* points to just header, pull a few bytes of payload from
 		* frags into skb->data */
 		hdr_len = skb_transport_offset(skb) + tcp_hdrlen(skb);
-		if (skb->data_len && (hdr_len == (skb->len - skb->data_len))) {
+		if (skb->data_len && (hdr_len == len)) {
 			unsigned int pull_size;
 
 			pull_size = min((unsigned int)4, skb->data_len);
