From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 3/3] sctp: Replace four seq_printf() calls by seq_puts()
Date: Mon, 1 May 2017 15:33:29 +0200
Message-ID: <e1c75816-be5a-2ddb-101e-4abf08e140f1@users.sourceforge.net>
References: <ea9206ca-2a2f-095e-d764-3f819610d5e8@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>,
        Neil Horman <nhorman@tuxdriver.com>,
        Vlad Yasevich <vyasevich@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <ea9206ca-2a2f-095e-d764-3f819610d5e8@users.sourceforge.net>
Content-Language: en-GB
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Mon, 1 May 2017 14:54:18 +0200

Strings which did not contain data format specifications should be put
into a sequence. Thus use the corresponding function "seq_puts".

This issue was detected by using the Coccinelle software.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 net/sctp/proc.c | 16 +++++++---------
 1 file changed, 7 insertions(+), 9 deletions(-)

diff --git a/net/sctp/proc.c b/net/sctp/proc.c
index 458087681490..a9dc4538db44 100644
--- a/net/sctp/proc.c
+++ b/net/sctp/proc.c
@@ -184,7 +184,8 @@ static void *sctp_eps_seq_start(struct seq_file *seq, loff_t *pos)
 		*pos = 0;
 
 	if (*pos == 0)
-		seq_printf(seq, " ENDPT     SOCK   STY SST HBKT LPORT   UID INODE LADDRS\n");
+		seq_puts(seq,
+			 " ENDPT     SOCK   STY SST HBKT LPORT   UID INODE LADDRS\n");
 
 	return (void *)pos;
 }
@@ -326,11 +327,8 @@ static int sctp_assocs_seq_show(struct seq_file *seq, void *v)
 	struct sock *sk;
 
 	if (v == SEQ_START_TOKEN) {
-		seq_printf(seq, " ASSOC     SOCK   STY SST ST HBKT "
-				"ASSOC-ID TX_QUEUE RX_QUEUE UID INODE LPORT "
-				"RPORT LADDRS <-> RADDRS "
-				"HBINT INS OUTS MAXRT T1X T2X RTXC "
-				"wmema wmemq sndbuf rcvbuf\n");
+		seq_puts(seq,
+			 " ASSOC     SOCK   STY SST ST HBKT ASSOC-ID TX_QUEUE RX_QUEUE UID INODE LPORT RPORT LADDRS <-> RADDRS HBINT INS OUTS MAXRT T1X T2X RTXC wmema wmemq sndbuf rcvbuf\n");
 		return 0;
 	}
 
@@ -357,5 +355,5 @@ static int sctp_assocs_seq_show(struct seq_file *seq, void *v)
 	sctp_seq_dump_local_addrs(seq, epb);
-	seq_printf(seq, "<-> ");
+	seq_puts(seq, "<-> ");
 	sctp_seq_dump_remote_addrs(seq, assoc);
 	seq_printf(seq, "\t%8lu %5d %5d %4d %4d %4d %8d "
 		   "%8d %8d %8d %8d",
@@ -419,8 +417,8 @@ static int sctp_remaddr_seq_show(struct seq_file *seq, void *v)
 	struct sctp_transport *transport, *tsp;
 
 	if (v == SEQ_START_TOKEN) {
-		seq_printf(seq, "ADDR ASSOC_ID HB_ACT RTO MAX_PATH_RTX "
-				"REM_ADDR_RTX START STATE\n");
+		seq_puts(seq,
+			 "ADDR ASSOC_ID HB_ACT RTO MAX_PATH_RTX REM_ADDR_RTX START STATE\n");
 		return 0;
 	}
 
-- 
2.12.2
