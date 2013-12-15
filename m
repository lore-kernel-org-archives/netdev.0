From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: [PATCH 4/4] tcp: metrics: Dump info of the source-address in netlink-reply
Date: Sun, 15 Dec 2013 13:10:44 +0100
Message-ID: <1387109444-1104-5-git-send-email-christoph.paasch@uclouvain.be>
References: <1387109444-1104-1-git-send-email-christoph.paasch@uclouvain.be>
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Julian Anastasov <ja@ssi.bg>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:38502 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754443Ab3LOMLM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Dec 2013 07:11:12 -0500
Received: by mail-ee0-f46.google.com with SMTP id d49so1667181eek.33
        for <netdev@vger.kernel.org>; Sun, 15 Dec 2013 04:11:11 -0800 (PST)
In-Reply-To: <1387109444-1104-1-git-send-email-christoph.paasch@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Christoph Paasch <christoph.paasch@uclouvain.be>
---
 include/uapi/linux/tcp_metrics.h | 2 ++
 net/ipv4/tcp_metrics.c           | 6 ++++++
 2 files changed, 8 insertions(+)

diff --git a/include/uapi/linux/tcp_metrics.h b/include/uapi/linux/tcp_metrics.h
index cb5157b55f32..54a37b13f2c4 100644
--- a/include/uapi/linux/tcp_metrics.h
+++ b/include/uapi/linux/tcp_metrics.h
@@ -35,6 +35,8 @@ enum {
 	TCP_METRICS_ATTR_FOPEN_SYN_DROPS,	/* u16, count of drops */
 	TCP_METRICS_ATTR_FOPEN_SYN_DROP_TS,	/* msecs age */
 	TCP_METRICS_ATTR_FOPEN_COOKIE,		/* binary */
+	TCP_METRICS_ATTR_SADDR_IPV4,		/* u32 */
+	TCP_METRICS_ATTR_SADDR_IPV6,		/* binary */
 
 	__TCP_METRICS_ATTR_MAX,
 };
diff --git a/net/ipv4/tcp_metrics.c b/net/ipv4/tcp_metrics.c
index 8d544bb475dc..e150f264c8e2 100644
--- a/net/ipv4/tcp_metrics.c
+++ b/net/ipv4/tcp_metrics.c
@@ -745,11 +745,17 @@ static int tcp_metrics_fill_info(struct sk_buff *msg,
 		if (nla_put_be32(msg, TCP_METRICS_ATTR_ADDR_IPV4,
 				tm->tcpm_daddr.addr.a4) < 0)
 			goto nla_put_failure;
+		if (nla_put_be32(msg, TCP_METRICS_ATTR_SADDR_IPV4,
+				tm->tcpm_saddr.addr.a4) < 0)
+			goto nla_put_failure;
 		break;
 	case AF_INET6:
 		if (nla_put(msg, TCP_METRICS_ATTR_ADDR_IPV6, 16,
 			    tm->tcpm_daddr.addr.a6) < 0)
 			goto nla_put_failure;
+		if (nla_put(msg, TCP_METRICS_ATTR_SADDR_IPV6, 16,
+			    tm->tcpm_saddr.addr.a6) < 0)
+			goto nla_put_failure;
 		break;
 	default:
 		return -EAFNOSUPPORT;
-- 
1.8.3.2
