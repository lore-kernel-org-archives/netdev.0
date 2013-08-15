From: Francesco Fusco <ffusco@redhat.com>
Subject: [PATCH net-next] net: proc_fs: trivial: print UIDs as unsigned int
Date: Thu, 15 Aug 2013 13:42:14 +0200
Message-ID: <bee30aaa49e84c82c8a7ca9939e7321e2c0a741d.1376566630.git.ffusco@redhat.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42868 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754182Ab3HOLmQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Aug 2013 07:42:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

UIDs are printed in the proc_fs as signed int, whereas
they are unsigned int.

Signed-off-by: Francesco Fusco <ffusco@redhat.com>
---
 net/appletalk/atalk_proc.c | 2 +-
 net/ipv4/ping.c            | 2 +-
 net/ipv4/raw.c             | 2 +-
 net/ipv4/tcp_ipv4.c        | 4 ++--
 net/ipv4/udp.c             | 2 +-
 net/ipv6/datagram.c        | 2 +-
 net/ipv6/tcp_ipv6.c        | 4 ++--
 net/ipx/ipx_proc.c         | 2 +-
 net/llc/llc_proc.c         | 2 +-
 net/phonet/socket.c        | 2 +-
 net/sctp/proc.c            | 4 ++--
 11 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/net/appletalk/atalk_proc.c b/net/appletalk/atalk_proc.c
index c30f3a0..af46bc4 100644
--- a/net/appletalk/atalk_proc.c
+++ b/net/appletalk/atalk_proc.c
@@ -178,7 +178,7 @@ static int atalk_seq_socket_show(struct seq_file *seq, void *v)
 	at = at_sk(s);
 
 	seq_printf(seq, "%02X   %04X:%02X:%02X  %04X:%02X:%02X  %08X:%08X "
-			"%02X %d\n",
+			"%02X %u\n",
 		   s->sk_type, ntohs(at->src_net), at->src_node, at->src_port,
 		   ntohs(at->dest_net), at->dest_node, at->dest_port,
 		   sk_wmem_alloc_get(s),
diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
index 746427c..d7d9882 100644
--- a/net/ipv4/ping.c
+++ b/net/ipv4/ping.c
@@ -1082,7 +1082,7 @@ static void ping_v4_format_sock(struct sock *sp, struct seq_file *f,
 	__u16 srcp = ntohs(inet->inet_sport);
 
 	seq_printf(f, "%5d: %08X:%04X %08X:%04X"
-		" %02X %08X:%08X %02X:%08lX %08X %5d %8d %lu %d %pK %d%n",
+		" %02X %08X:%08X %02X:%08lX %08X %5u %8d %lu %d %pK %d%n",
 		bucket, src, srcp, dest, destp, sp->sk_state,
 		sk_wmem_alloc_get(sp),
 		sk_rmem_alloc_get(sp),
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index dd44e0a..41d8450 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -987,7 +987,7 @@ static void raw_sock_seq_show(struct seq_file *seq, struct sock *sp, int i)
 	      srcp  = inet->inet_num;
 
 	seq_printf(seq, "%4d: %08X:%04X %08X:%04X"
-		" %02X %08X:%08X %02X:%08lX %08X %5d %8d %lu %d %pK %d\n",
+		" %02X %08X:%08X %02X:%08lX %08X %5u %8d %lu %d %pK %d\n",
 		i, src, srcp, dest, destp, sp->sk_state,
 		sk_wmem_alloc_get(sp),
 		sk_rmem_alloc_get(sp),
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index ec27028..05a3d45 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2608,7 +2608,7 @@ static void get_openreq4(const struct sock *sk, const struct request_sock *req,
 	long delta = req->expires - jiffies;
 
 	seq_printf(f, "%4d: %08X:%04X %08X:%04X"
-		" %02X %08X:%08X %02X:%08lX %08X %5d %8d %u %d %pK%n",
+		" %02X %08X:%08X %02X:%08lX %08X %5u %8d %u %d %pK%n",
 		i,
 		ireq->loc_addr,
 		ntohs(inet_sk(sk)->inet_sport),
@@ -2666,7 +2666,7 @@ static void get_tcp4_sock(struct sock *sk, struct seq_file *f, int i, int *len)
 		rx_queue = max_t(int, tp->rcv_nxt - tp->copied_seq, 0);
 
 	seq_printf(f, "%4d: %08X:%04X %08X:%04X %02X %08X:%08X %02X:%08lX "
-			"%08X %5d %8d %lu %d %pK %lu %lu %u %u %d%n",
+			"%08X %5u %8d %lu %d %pK %lu %lu %u %u %d%n",
 		i, src, srcp, dest, destp, sk->sk_state,
 		tp->write_seq - tp->snd_una,
 		rx_queue,
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 9e88af0..0b24508 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -2159,7 +2159,7 @@ static void udp4_format_sock(struct sock *sp, struct seq_file *f,
 	__u16 srcp	  = ntohs(inet->inet_sport);
 
 	seq_printf(f, "%5d: %08X:%04X %08X:%04X"
-		" %02X %08X:%08X %02X:%08lX %08X %5d %8d %lu %d %pK %d%n",
+		" %02X %08X:%08X %02X:%08lX %08X %5u %8d %lu %d %pK %d%n",
 		bucket, src, srcp, dest, destp, sp->sk_state,
 		sk_wmem_alloc_get(sp),
 		sk_rmem_alloc_get(sp),
diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index 197e6f4..48b6bd2 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -890,7 +890,7 @@ void ip6_dgram_sock_seq_show(struct seq_file *seq, struct sock *sp,
 	src   = &np->rcv_saddr;
 	seq_printf(seq,
 		   "%5d: %08X%08X%08X%08X:%04X %08X%08X%08X%08X:%04X "
-		   "%02X %08X:%08X %02X:%08lX %08X %5d %8d %lu %d %pK %d\n",
+		   "%02X %08X:%08X %02X:%08lX %08X %5u %8d %lu %d %pK %d\n",
 		   bucket,
 		   src->s6_addr32[0], src->s6_addr32[1],
 		   src->s6_addr32[2], src->s6_addr32[3], srcp,
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 38c196c..5bcfadf 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1731,7 +1731,7 @@ static void get_openreq6(struct seq_file *seq,
 
 	seq_printf(seq,
 		   "%4d: %08X%08X%08X%08X:%04X %08X%08X%08X%08X:%04X "
-		   "%02X %08X:%08X %02X:%08lX %08X %5d %8d %d %d %pK\n",
+		   "%02X %08X:%08X %02X:%08lX %08X %5u %8d %d %d %pK\n",
 		   i,
 		   src->s6_addr32[0], src->s6_addr32[1],
 		   src->s6_addr32[2], src->s6_addr32[3],
@@ -1782,7 +1782,7 @@ static void get_tcp6_sock(struct seq_file *seq, struct sock *sp, int i)
 
 	seq_printf(seq,
 		   "%4d: %08X%08X%08X%08X:%04X %08X%08X%08X%08X:%04X "
-		   "%02X %08X:%08X %02X:%08lX %08X %5d %8d %lu %d %pK %lu %lu %u %u %d\n",
+		   "%02X %08X:%08X %02X:%08lX %08X %5u %8d %lu %d %pK %lu %lu %u %u %d\n",
 		   i,
 		   src->s6_addr32[0], src->s6_addr32[1],
 		   src->s6_addr32[2], src->s6_addr32[3], srcp,
diff --git a/net/ipx/ipx_proc.c b/net/ipx/ipx_proc.c
index 65e8833..e15c16a 100644
--- a/net/ipx/ipx_proc.c
+++ b/net/ipx/ipx_proc.c
@@ -213,7 +213,7 @@ static int ipx_seq_socket_show(struct seq_file *seq, void *v)
 			   ntohs(ipxs->dest_addr.sock));
 	}
 
-	seq_printf(seq, "%08X  %08X  %02X     %03d\n",
+	seq_printf(seq, "%08X  %08X  %02X     %03u\n",
 		   sk_wmem_alloc_get(s),
 		   sk_rmem_alloc_get(s),
 		   s->sk_state,
diff --git a/net/llc/llc_proc.c b/net/llc/llc_proc.c
index 7b4799c..1a3c7e0 100644
--- a/net/llc/llc_proc.c
+++ b/net/llc/llc_proc.c
@@ -147,7 +147,7 @@ static int llc_seq_socket_show(struct seq_file *seq, void *v)
 	}
 	seq_printf(seq, "@%02X ", llc->sap->laddr.lsap);
 	llc_ui_format_mac(seq, llc->daddr.mac);
-	seq_printf(seq, "@%02X %8d %8d %2d %3d %4d\n", llc->daddr.lsap,
+	seq_printf(seq, "@%02X %8d %8d %2d %3u %4d\n", llc->daddr.lsap,
 		   sk_wmem_alloc_get(sk),
 		   sk_rmem_alloc_get(sk) - llc->copied_seq,
 		   sk->sk_state,
diff --git a/net/phonet/socket.c b/net/phonet/socket.c
index 1afd138..77e38f7 100644
--- a/net/phonet/socket.c
+++ b/net/phonet/socket.c
@@ -793,7 +793,7 @@ static int pn_res_seq_show(struct seq_file *seq, void *v)
 		struct sock **psk = v;
 		struct sock *sk = *psk;
 
-		seq_printf(seq, "%02X %5d %lu%n",
+		seq_printf(seq, "%02X %5u %lu%n",
 			   (int) (psk - pnres.sk),
 			   from_kuid_munged(seq_user_ns(seq), sock_i_uid(sk)),
 			   sock_i_ino(sk), &len);
diff --git a/net/sctp/proc.c b/net/sctp/proc.c
index 82432bf..0c06421 100644
--- a/net/sctp/proc.c
+++ b/net/sctp/proc.c
@@ -226,7 +226,7 @@ static int sctp_eps_seq_show(struct seq_file *seq, void *v)
 		sk = epb->sk;
 		if (!net_eq(sock_net(sk), seq_file_net(seq)))
 			continue;
-		seq_printf(seq, "%8pK %8pK %-3d %-3d %-4d %-5d %5d %5lu ", ep, sk,
+		seq_printf(seq, "%8pK %8pK %-3d %-3d %-4d %-5d %5u %5lu ", ep, sk,
 			   sctp_sk(sk)->type, sk->sk_state, hash,
 			   epb->bind_addr.port,
 			   from_kuid_munged(seq_user_ns(seq), sock_i_uid(sk)),
@@ -336,7 +336,7 @@ static int sctp_assocs_seq_show(struct seq_file *seq, void *v)
 			continue;
 		seq_printf(seq,
 			   "%8pK %8pK %-3d %-3d %-2d %-4d "
-			   "%4d %8d %8d %7d %5lu %-5d %5d ",
+			   "%4d %8d %8d %7u %5lu %-5d %5d ",
 			   assoc, sk, sctp_sk(sk)->type, sk->sk_state,
 			   assoc->state, hash,
 			   assoc->assoc_id,
-- 
1.8.3.1
