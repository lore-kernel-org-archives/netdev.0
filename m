From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: [PATCH 7/7] misc: replace NIPQUAD()
Date: Thu, 30 Oct 2008 17:13:48 -0700
Message-ID: <1225412028.5574.38.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.238]:38945 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754463AbYJaAOA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2008 20:14:00 -0400
Received: by rv-out-0506.google.com with SMTP id k40so905351rvb.1
        for <netdev@vger.kernel.org>; Thu, 30 Oct 2008 17:14:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using NIPQUAD() with NIPQUAD_FMT, %d.%d.%d.%d or %u.%u.%u.%u
can be replaced with %pI4

Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
---
 include/linux/sunrpc/svc_xprt.h            |    4 ++--
 include/net/ip_vs.h                        |    4 ++--
 include/net/netfilter/nf_conntrack_tuple.h |    6 +++---
 include/net/sctp/sctp.h                    |    4 ++--
 security/selinux/avc.c                     |    2 +-
 5 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
index 51cb75e..0127dac 100644
--- a/include/linux/sunrpc/svc_xprt.h
+++ b/include/linux/sunrpc/svc_xprt.h
@@ -139,8 +139,8 @@ static inline char *__svc_print_addr(struct sockaddr *addr,
 {
 	switch (addr->sa_family) {
 	case AF_INET:
-		snprintf(buf, len, "%u.%u.%u.%u, port=%u",
-			NIPQUAD(((struct sockaddr_in *) addr)->sin_addr),
+		snprintf(buf, len, "%pI4, port=%u",
+			&((struct sockaddr_in *)addr)->sin_addr,
 			ntohs(((struct sockaddr_in *) addr)->sin_port));
 		break;
 
diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index af48cad..fc63353 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -91,8 +91,8 @@ static inline const char *ip_vs_dbg_addr(int af, char *buf, size_t buf_len,
 			       &addr->in6) + 1;
 	else
 #endif
-		len = snprintf(&buf[*idx], buf_len - *idx, NIPQUAD_FMT,
-			       NIPQUAD(addr->ip)) + 1;
+		len = snprintf(&buf[*idx], buf_len - *idx, "%pI4",
+			       &addr->ip) + 1;
 
 	*idx += len;
 	BUG_ON(*idx > buf_len + 1);
diff --git a/include/net/netfilter/nf_conntrack_tuple.h b/include/net/netfilter/nf_conntrack_tuple.h
index 42f1fc9..f2f6aa7 100644
--- a/include/net/netfilter/nf_conntrack_tuple.h
+++ b/include/net/netfilter/nf_conntrack_tuple.h
@@ -112,10 +112,10 @@ struct nf_conntrack_tuple_mask
 static inline void nf_ct_dump_tuple_ip(const struct nf_conntrack_tuple *t)
 {
 #ifdef DEBUG
-	printk("tuple %p: %u " NIPQUAD_FMT ":%hu -> " NIPQUAD_FMT ":%hu\n",
+	printk("tuple %p: %u %pI4:%hu -> %pI4:%hu\n",
 	       t, t->dst.protonum,
-	       NIPQUAD(t->src.u3.ip), ntohs(t->src.u.all),
-	       NIPQUAD(t->dst.u3.ip), ntohs(t->dst.u.all));
+	       &t->src.u3.ip, ntohs(t->src.u.all),
+	       &t->dst.u3.ip, ntohs(t->dst.u.all));
 #endif
 }
 
diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
index e71b0f7..2379750 100644
--- a/include/net/sctp/sctp.h
+++ b/include/net/sctp/sctp.h
@@ -291,9 +291,9 @@ extern int sctp_debug_flag;
 			       otherparms); \
 		} else { \
 			printk(KERN_DEBUG \
-			       lead NIPQUAD_FMT trail, \
+			       lead "%pI4" trail, \
 			       leadparm, \
-			       NIPQUAD(saddr->v4.sin_addr.s_addr), \
+			       &saddr->v4.sin_addr.s_addr, \
 			       otherparms); \
 		} \
 	}
diff --git a/security/selinux/avc.c b/security/selinux/avc.c
index ed6af12..d43bd6b 100644
--- a/security/selinux/avc.c
+++ b/security/selinux/avc.c
@@ -504,7 +504,7 @@ static inline void avc_print_ipv4_addr(struct audit_buffer *ab, __be32 addr,
 				       __be16 port, char *name1, char *name2)
 {
 	if (addr)
-		audit_log_format(ab, " %s=" NIPQUAD_FMT, name1, NIPQUAD(addr));
+		audit_log_format(ab, " %s=%pI4", name1, &addr);
 	if (port)
 		audit_log_format(ab, " %s=%d", name2, ntohs(port));
 }
-- 
1.6.0.3.756.gb776d

