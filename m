From: Andy Gospodarek <andy@greyhouse.net>
Subject: [patch] networking ipv4: remove total socket usage count from /proc/net/sockstat
Date: Mon, 16 Jan 2006 15:04:32 -0500
Message-ID: <20060116200432.GB14060@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751190AbWAPUFx@vger.kernel.org>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Printing the total number of sockets used in /proc/net/sockstat is out
of place in a file that is supposed to contain information related to
ipv4 sockets.  Removed output for total socket usage.

Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
---

 proc.c |    1 -
 1 files changed, 1 deletion(-)


diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
--- a/net/ipv4/proc.c
+++ b/net/ipv4/proc.c
@@ -60,7 +60,6 @@ static int fold_prot_inuse(struct proto 
  */
 static int sockstat_seq_show(struct seq_file *seq, void *v)
 {
-	socket_seq_show(seq);
 	seq_printf(seq, "TCP: inuse %d orphan %d tw %d alloc %d mem %d\n",
 		   fold_prot_inuse(&tcp_prot), atomic_read(&tcp_orphan_count),
 		   tcp_death_row.tw_count, atomic_read(&tcp_sockets_allocated),
