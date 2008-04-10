From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH 1/5] [SCTP] Correct /proc/net/assocs formatting error
Date: Thu, 10 Apr 2008 15:39:51 -0400
Message-ID: <1207856394-19321-2-git-send-email-vladislav.yasevich@hp.com>
References: <1207856394-19321-1-git-send-email-vladislav.yasevich@hp.com>
Cc: linux-sctp@vger.kernel.org,
	lksctp-developers@lists.sourceforge.net, netdev@vger.kernel.org,
	Neil Horman <nhorman@tuxdriver.com>,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0029.austin.hp.com ([15.216.28.36]:25929 "EHLO
	g1t0029.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753377AbYDJTkB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Apr 2008 15:40:01 -0400
In-Reply-To: <1207856394-19321-1-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>

Recently I posted a patch to add some informational items to
/proc/net/sctp/assocs.  All the information is correct, but because
of how the seqfile show operation is laid out, some of the formatting
is backwards.  This patch corrects that formatting, so that the new
information appears at the end of each line, rather than in the middle.

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 net/sctp/proc.c |   14 +++++++-------
 1 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/net/sctp/proc.c b/net/sctp/proc.c
index ddca90e..99062f5 100644
--- a/net/sctp/proc.c
+++ b/net/sctp/proc.c
@@ -322,8 +322,7 @@ static int sctp_assocs_seq_show(struct seq_file *seq, void *v)
 		sk = epb->sk;
 		seq_printf(seq,
 			   "%8p %8p %-3d %-3d %-2d %-4d "
-			   "%4d %8d %8d %7d %5lu %-5d %5d "
-			   "%8lu %5d %5d %4d %4d %4d %8d ",
+			   "%4d %8d %8d %7d %5lu %-5d %5d ",
 			   assoc, sk, sctp_sk(sk)->type, sk->sk_state,
 			   assoc->state, hash,
 			   assoc->assoc_id,
@@ -331,15 +330,16 @@ static int sctp_assocs_seq_show(struct seq_file *seq, void *v)
 			   atomic_read(&assoc->rmem_alloc),
 			   sock_i_uid(sk), sock_i_ino(sk),
 			   epb->bind_addr.port,
-			   assoc->peer.port,
-			   assoc->hbinterval, assoc->c.sinit_max_instreams,
-			   assoc->c.sinit_num_ostreams, assoc->max_retrans,
-			   assoc->init_retries, assoc->shutdown_retries,
-			   assoc->rtx_data_chunks);
+			   assoc->peer.port);
 		seq_printf(seq, " ");
 		sctp_seq_dump_local_addrs(seq, epb);
 		seq_printf(seq, "<-> ");
 		sctp_seq_dump_remote_addrs(seq, assoc);
+		seq_printf(seq, "\t%8lu %5d %5d %4d %4d %4d %8d ",
+			assoc->hbinterval, assoc->c.sinit_max_instreams,
+			assoc->c.sinit_num_ostreams, assoc->max_retrans,
+			assoc->init_retries, assoc->shutdown_retries,
+			assoc->rtx_data_chunks);
 		seq_printf(seq, "\n");
 	}
 	read_unlock(&head->lock);
-- 
1.5.3.5

