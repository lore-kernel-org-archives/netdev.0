From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: [PATCH 1/4] firewire: net: count stats.tx_packets and stats.tx_bytes
Date: Sun, 7 Nov 2010 22:39:30 +0100 (CET)
Message-ID: <tkrat.581b2b7b08a9998b@s5r6.in-berlin.de>
References: <tkrat.036c5d10fb83f85d@s5r6.in-berlin.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: linux1394-devel@lists.sourceforge.net
Return-path: <linux1394-devel-bounces@lists.sourceforge.net>
In-Reply-To: <tkrat.036c5d10fb83f85d@s5r6.in-berlin.de>
Content-Disposition: INLINE
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux1394-devel>,
	<mailto:linux1394-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux1394-devel>
List-Post: <mailto:linux1394-devel@lists.sourceforge.net>
List-Help: <mailto:linux1394-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux1394-devel>,
	<mailto:linux1394-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: linux1394-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Signed-off-by: Stefan Richter <stefanr@s5r6.in-berlin.de>
---
 drivers/firewire/net.c |    9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

Index: b/drivers/firewire/net.c
===================================================================
--- a/drivers/firewire/net.c
+++ b/drivers/firewire/net.c
@@ -907,6 +907,7 @@ static int fwnet_send_packet(struct fwne
 static void fwnet_transmit_packet_done(struct fwnet_packet_task *ptask)
 {
 	struct fwnet_device *dev = ptask->dev;
+	struct sk_buff *skb = ptask->skb;
 	unsigned long flags;
 	bool free;
 
@@ -917,8 +918,11 @@ static void fwnet_transmit_packet_done(s
 	/* Check whether we or the networking TX soft-IRQ is last user. */
 	free = (ptask->outstanding_pkts == 0 && !list_empty(&ptask->pt_link));
 
-	if (ptask->outstanding_pkts == 0)
+	if (ptask->outstanding_pkts == 0) {
 		list_del(&ptask->pt_link);
+		dev->netdev->stats.tx_packets++;
+		dev->netdev->stats.tx_bytes += skb->len;
+	}
 
 	spin_unlock_irqrestore(&dev->lock, flags);
 
@@ -927,7 +931,6 @@ static void fwnet_transmit_packet_done(s
 		u16 fg_off;
 		u16 datagram_label;
 		u16 lf;
-		struct sk_buff *skb;
 
 		/* Update the ptask to point to the next fragment and send it */
 		lf = fwnet_get_hdr_lf(&ptask->hdr);
@@ -954,7 +957,7 @@ static void fwnet_transmit_packet_done(s
 			datagram_label = fwnet_get_hdr_dgl(&ptask->hdr);
 			break;
 		}
-		skb = ptask->skb;
+
 		skb_pull(skb, ptask->max_payload);
 		if (ptask->outstanding_pkts > 1) {
 			fwnet_make_sf_hdr(&ptask->hdr, RFC2374_HDR_INTFRAG,

-- 
Stefan Richter
-=====-==-=- =-== --===
http://arcgraph.de/sr/



------------------------------------------------------------------------------
The Next 800 Companies to Lead America's Growth: New Video Whitepaper
David G. Thomson, author of the best-selling book "Blueprint to a 
Billion" shares his insights and actions to help propel your 
business during the next growth cycle. Listen Now!
http://p.sf.net/sfu/SAP-dev2dev
