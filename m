From: akpm@osdl.org
Subject: [patch 17/18] gcc-3.5: tcp_put_port() fix
Date: Sun, 25 Jan 2004 03:08:21 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200401251108.i0PB8Lo25193@mail.osdl.org>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



include/net/tcp.h:741: sorry, unimplemented: inlining failed in call to 'tcp_put_port': function body not available
net/ipv4/tcp_timer.c:1506: sorry, unimplemented: called from here



---

 include/net/tcp.h   |    2 +-
 net/ipv4/tcp_ipv4.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff -puN include/net/tcp.h~gcc-35-tcp_put_port-fix include/net/tcp.h
--- 25/include/net/tcp.h~gcc-35-tcp_put_port-fix	2004-01-17 14:37:33.000000000 -0800
+++ 25-akpm/include/net/tcp.h	2004-01-17 14:37:33.000000000 -0800
@@ -738,7 +738,7 @@ DECLARE_SNMP_STAT(struct tcp_mib, tcp_st
 #define TCP_ADD_STATS_BH(field, val)	SNMP_ADD_STATS_BH(tcp_statistics, field, val)
 #define TCP_ADD_STATS_USER(field, val)	SNMP_ADD_STATS_USER(tcp_statistics, field, val)
 
-extern inline void		tcp_put_port(struct sock *sk);
+extern void			tcp_put_port(struct sock *sk);
 extern void			tcp_inherit_port(struct sock *sk, struct sock *child);
 
 extern void			tcp_v4_err(struct sk_buff *skb, u32);
diff -puN net/ipv4/tcp_ipv4.c~gcc-35-tcp_put_port-fix net/ipv4/tcp_ipv4.c
--- 25/net/ipv4/tcp_ipv4.c~gcc-35-tcp_put_port-fix	2004-01-17 14:38:37.000000000 -0800
+++ 25-akpm/net/ipv4/tcp_ipv4.c	2004-01-17 14:38:50.000000000 -0800
@@ -313,7 +313,7 @@ static void __tcp_put_port(struct sock *
 	spin_unlock(&head->lock);
 }
 
-inline void tcp_put_port(struct sock *sk)
+void tcp_put_port(struct sock *sk)
 {
 	local_bh_disable();
 	__tcp_put_port(sk);

_
