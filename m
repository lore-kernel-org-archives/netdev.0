From: Hannes Eder <heder@google.com>
Subject: [PATCH] netfilter: nf_nat_helper: tidy up adjust_tcp_sequence
Date: Tue, 22 Sep 2009 18:00:55 +0200
Message-ID: <20090922155911.20008.96214.stgit@jazzy.zrh.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The variable 'other_way' gets initialized but is not read afterwards,
so remove it.  Pass the right arguments to a pr_debug call.

While being at tidy up a bit and it fix this checkpatch warning:
  WARNING: suspect code indent for conditional statements

Signed-off-by: Hannes Eder <heder@google.com>

 net/ipv4/netfilter/nf_nat_helper.c |   21 ++++++++-------------
 1 files changed, 8 insertions(+), 13 deletions(-)

diff --git a/net/ipv4/netfilter/nf_nat_helper.c b/net/ipv4/netfilter/nf_nat_helper.c
index 09172a6..56daa1b 100644
--- a/net/ipv4/netfilter/nf_nat_helper.c
+++ b/net/ipv4/netfilter/nf_nat_helper.c
@@ -41,18 +41,13 @@ adjust_tcp_sequence(u32 seq,
 		    struct nf_conn *ct,
 		    enum ip_conntrack_info ctinfo)
 {
-	int dir;
-	struct nf_nat_seq *this_way, *other_way;
+	int dir = CTINFO2DIR(ctinfo);
 	struct nf_conn_nat *nat = nfct_nat(ct);
+	struct nf_nat_seq *this_way = &nat->seq[dir];
 
-	pr_debug("adjust_tcp_sequence: seq = %u, sizediff = %d\n", seq, seq);
-
-	dir = CTINFO2DIR(ctinfo);
-
-	this_way = &nat->seq[dir];
-	other_way = &nat->seq[!dir];
+	pr_debug("%s(): seq = %u, sizediff = %d\n", __func__, seq, sizediff);
 
-	pr_debug("nf_nat_resize_packet: Seq_offset before: ");
+	pr_debug("%s(): Seq_offset before: ", __func__);
 	DUMP_OFFSET(this_way);
 
 	spin_lock_bh(&nf_nat_seqofs_lock);
@@ -63,13 +58,13 @@ adjust_tcp_sequence(u32 seq,
 	 * retransmit */
 	if (this_way->offset_before == this_way->offset_after ||
 	    before(this_way->correction_pos, seq)) {
-		   this_way->correction_pos = seq;
-		   this_way->offset_before = this_way->offset_after;
-		   this_way->offset_after += sizediff;
+		this_way->correction_pos = seq;
+		this_way->offset_before = this_way->offset_after;
+		this_way->offset_after += sizediff;
 	}
 	spin_unlock_bh(&nf_nat_seqofs_lock);
 
-	pr_debug("nf_nat_resize_packet: Seq_offset after: ");
+	pr_debug("%s(): Seq_offset after: ", __func__);
 	DUMP_OFFSET(this_way);
 }
 

