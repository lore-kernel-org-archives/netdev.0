From: Frank Pavlic <fpavlic@de.ibm.com>
Subject: [patch 2/6] s390: qeth driver statistics fixes
Date: Wed, 22 Mar 2006 16:28:34 +0100
Message-ID: <20060322162834.46fceecc@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932247AbWCVRmX@vger.kernel.org>
To: Jeff Garzik <jgarzik@pobox.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[patch 2/6] s390: qeth driver statistics fixes 

From: Ursula Braun <braunu@de.ibm.com>
	- display "unsigned int" values in /proc/qeth_perf with %u instead of %i
	- omit qdio header length when increasing card->stats.tx_bytes

Signed-off-by: Frank Pavlic <fpavlic@de.ibm.com>

diffstat:
qeth_main.c |    3 ++-
 qeth_proc.c |   38 +++++++++++++++++++-------------------
 2 files changed, 21 insertions(+), 20 deletions(-)

diff --git a/drivers/s390/net/qeth_main.c b/drivers/s390/net/qeth_main.c
index dba7f7f..634c395 100644
--- a/drivers/s390/net/qeth_main.c
+++ b/drivers/s390/net/qeth_main.c
@@ -4419,6 +4419,7 @@ qeth_send_packet(struct qeth_card *card,
 	int elements_needed = 0;
 	enum qeth_large_send_types large_send = QETH_LARGE_SEND_NO;
 	struct qeth_eddp_context *ctx = NULL;
+	int tx_bytes = skb->len;
 	int rc;
 
 	QETH_DBF_TEXT(trace, 6, "sendpkt");
@@ -4499,7 +4500,7 @@ qeth_send_packet(struct qeth_card *card,
 					      elements_needed, ctx);
 	if (!rc){
 		card->stats.tx_packets++;
-		card->stats.tx_bytes += skb->len;
+		card->stats.tx_bytes += tx_bytes;
 #ifdef CONFIG_QETH_PERF_STATS
 		if (skb_shinfo(skb)->tso_size &&
 		   !(large_send == QETH_LARGE_SEND_NO)) {
diff --git a/drivers/s390/net/qeth_proc.c b/drivers/s390/net/qeth_proc.c
index 3c6339d..1304641 100644
--- a/drivers/s390/net/qeth_proc.c
+++ b/drivers/s390/net/qeth_proc.c
@@ -192,27 +192,27 @@ qeth_perf_procfile_seq_show(struct seq_f
 			CARD_DDEV_ID(card),
 			QETH_CARD_IFNAME(card)
 		  );
-	seq_printf(s, "  Skb's/buffers received                 : %li/%i\n"
-		      "  Skb's/buffers sent                     : %li/%i\n\n",
+	seq_printf(s, "  Skb's/buffers received                 : %lu/%u\n"
+		      "  Skb's/buffers sent                     : %lu/%u\n\n",
 		        card->stats.rx_packets, card->perf_stats.bufs_rec,
 		        card->stats.tx_packets, card->perf_stats.bufs_sent
 		  );
-	seq_printf(s, "  Skb's/buffers sent without packing     : %li/%i\n"
-		      "  Skb's/buffers sent with packing        : %i/%i\n\n",
+	seq_printf(s, "  Skb's/buffers sent without packing     : %lu/%u\n"
+		      "  Skb's/buffers sent with packing        : %u/%u\n\n",
 		   card->stats.tx_packets - card->perf_stats.skbs_sent_pack,
 		   card->perf_stats.bufs_sent - card->perf_stats.bufs_sent_pack,
 		   card->perf_stats.skbs_sent_pack,
 		   card->perf_stats.bufs_sent_pack
 		  );
-	seq_printf(s, "  Skbs sent in SG mode                   : %i\n"
-		      "  Skb fragments sent in SG mode          : %i\n\n",
+	seq_printf(s, "  Skbs sent in SG mode                   : %u\n"
+		      "  Skb fragments sent in SG mode          : %u\n\n",
 		      card->perf_stats.sg_skbs_sent,
 		      card->perf_stats.sg_frags_sent);
-	seq_printf(s, "  large_send tx (in Kbytes)              : %i\n"
-		      "  large_send count                       : %i\n\n",
+	seq_printf(s, "  large_send tx (in Kbytes)              : %u\n"
+		      "  large_send count                       : %u\n\n",
 		      card->perf_stats.large_send_bytes >> 10,
 		      card->perf_stats.large_send_cnt);
-	seq_printf(s, "  Packing state changes no pkg.->packing : %i/%i\n"
+	seq_printf(s, "  Packing state changes no pkg.->packing : %u/%u\n"
 		      "  Watermarks L/H                         : %i/%i\n"
 		      "  Current buffer usage (outbound q's)    : "
 		      "%i/%i/%i/%i\n\n",
@@ -229,16 +229,16 @@ qeth_perf_procfile_seq_show(struct seq_f
 				atomic_read(&card->qdio.out_qs[3]->used_buffers)
 				: 0
 		  );
-	seq_printf(s, "  Inbound handler time (in us)           : %i\n"
-		      "  Inbound handler count                  : %i\n"
-		      "  Inbound do_QDIO time (in us)           : %i\n"
-		      "  Inbound do_QDIO count                  : %i\n\n"
-		      "  Outbound handler time (in us)          : %i\n"
-		      "  Outbound handler count                 : %i\n\n"
-		      "  Outbound time (in us, incl QDIO)       : %i\n"
-		      "  Outbound count                         : %i\n"
-		      "  Outbound do_QDIO time (in us)          : %i\n"
-		      "  Outbound do_QDIO count                 : %i\n\n",
+	seq_printf(s, "  Inbound handler time (in us)           : %u\n"
+		      "  Inbound handler count                  : %u\n"
+		      "  Inbound do_QDIO time (in us)           : %u\n"
+		      "  Inbound do_QDIO count                  : %u\n\n"
+		      "  Outbound handler time (in us)          : %u\n"
+		      "  Outbound handler count                 : %u\n\n"
+		      "  Outbound time (in us, incl QDIO)       : %u\n"
+		      "  Outbound count                         : %u\n"
+		      "  Outbound do_QDIO time (in us)          : %u\n"
+		      "  Outbound do_QDIO count                 : %u\n\n",
 		        card->perf_stats.inbound_time,
 			card->perf_stats.inbound_cnt,
 		        card->perf_stats.inbound_do_qdio_time,
