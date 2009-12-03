From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 04/08: nf_nat_helper: tidy up adjust_tcp_sequence
Date: Thu,  3 Dec 2009 21:19:37 +0100 (MET)
Message-ID: <20091203201936.8831.52977.sendpatchset@x2.localnet>
References: <20091203201931.8831.92922.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20091203201931.8831.92922.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 76ac894080019c6619d3c3bf615db42a43a77f32
Author: Hannes Eder <heder@google.com>
Date:   Thu Nov 5 15:51:19 2009 +0100

    netfilter: nf_nat_helper: tidy up adjust_tcp_sequence
    
    The variable 'other_way' gets initialized but is not read afterwards,
    so remove it.  Pass the right arguments to a pr_debug call.
    
    While being at tidy up a bit and it fix this checkpatch warning:
      WARNING: suspect code indent for conditional statements
    
    Signed-off-by: Hannes Eder <heder@google.com>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/ipv4/netfilter/nf_nat_helper.c b/net/ipv4/netfilter/nf_nat_helper.c
index 09172a6..5bf6a92 100644
--- a/net/ipv4/netfilter/nf_nat_helper.c
+++ b/net/ipv4/netfilter/nf_nat_helper.c
@@ -41,18 +41,14 @@ adjust_tcp_sequence(u32 seq,
 		    struct nf_conn *ct,
 		    enum ip_conntrack_info ctinfo)
 {
-	int dir;
-	struct nf_nat_seq *this_way, *other_way;
+	enum ip_conntrack_dir dir = CTINFO2DIR(ctinfo);
 	struct nf_conn_nat *nat = nfct_nat(ct);
+	struct nf_nat_seq *this_way = &nat->seq[dir];
 
-	pr_debug("adjust_tcp_sequence: seq = %u, sizediff = %d\n", seq, seq);
-
-	dir = CTINFO2DIR(ctinfo);
-
-	this_way = &nat->seq[dir];
-	other_way = &nat->seq[!dir];
+	pr_debug("adjust_tcp_sequence: seq = %u, sizediff = %d\n",
+		 seq, sizediff);
 
-	pr_debug("nf_nat_resize_packet: Seq_offset before: ");
+	pr_debug("adjust_tcp_sequence: Seq_offset before: ");
 	DUMP_OFFSET(this_way);
 
 	spin_lock_bh(&nf_nat_seqofs_lock);
@@ -63,13 +59,13 @@ adjust_tcp_sequence(u32 seq,
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
+	pr_debug("adjust_tcp_sequence: Seq_offset after: ");
 	DUMP_OFFSET(this_way);
 }
 
