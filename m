From: Amerigo Wang <amwang@redhat.com>
Subject: [Patch] net: export TCP send buffer size via netlink
Date: Mon, 1 Feb 2010 02:59:32 -0500
Message-ID: <20100201080256.4084.30962.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Amerigo Wang <amwang@redhat.com>,
	David Miller <davem@davemloft.net>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Currently, we can only get TCP send buffer size by
getsockopt (SO_SNDBUF or TCP_INFO), this is not enough
for the tools like netstat or ss to read.

Show TCP send buffer size via netlink NETLINK_INET_DIAG.

Signed-off-by: WANG Cong <amwang@redhat.com>
Cc: David Miller <davem@davemloft.net>

---
diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 7fee8a4..46768de 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -136,6 +136,7 @@ struct tcp_info {
 	__u32	tcpi_ato;
 	__u32	tcpi_snd_mss;
 	__u32	tcpi_rcv_mss;
+	__u32	tcpi_sndbuf;
 
 	__u32	tcpi_unacked;
 	__u32	tcpi_sacked;
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index b0a26bb..b3d6a62 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2385,6 +2385,7 @@ void tcp_get_info(struct sock *sk, struct tcp_info *info)
 	info->tcpi_retransmits = icsk->icsk_retransmits;
 	info->tcpi_probes = icsk->icsk_probes_out;
 	info->tcpi_backoff = icsk->icsk_backoff;
+	info->tcpi_sndbuf = sk->sk_sndbuf;
 
 	if (tp->rx_opt.tstamp_ok)
 		info->tcpi_options |= TCPI_OPT_TIMESTAMPS;
