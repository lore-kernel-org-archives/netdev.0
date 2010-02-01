From: Amerigo Wang <amwang@redhat.com>
Subject: [Patch v2] net: export TCP send buffer size via netlink
Date: Mon, 1 Feb 2010 04:18:28 -0500
Message-ID: <20100201092153.4194.91507.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>,
	Amerigo Wang <amwang@redhat.com>,
	David Miller <davem@davemloft.net>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

V1 -> V2:
Keep ABI compatiblity of struct tcp_info.

Currently, we can only get TCP send buffer size by
getsockopt (SO_SNDBUF or TCP_INFO), this is not enough
for the tools like netstat or ss to read.

Show TCP send buffer size via netlink NETLINK_INET_DIAG.

Signed-off-by: WANG Cong <amwang@redhat.com>
Cc: David Miller <davem@davemloft.net>
Cc: Eric Dumazet <eric.dumazet@gmail.com>

---

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 7fee8a4..b63f541 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -163,6 +163,8 @@ struct tcp_info {
 	__u32	tcpi_rcv_space;
 
 	__u32	tcpi_total_retrans;
+
+	__u32	tcpi_sndbuf;
 };
 
 /* for TCP_MD5SIG socket option */
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
