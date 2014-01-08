From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: [PATCH net-next v2 3/5] tcp: metrics: New netlink attribute for src IP and dumped in netlink reply
Date: Wed,  8 Jan 2014 16:05:57 +0100
Message-ID: <1389193559-16756-4-git-send-email-christoph.paasch@uclouvain.be>
References: <1389193559-16756-1-git-send-email-christoph.paasch@uclouvain.be>
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Yuchung Cheng <ycheng@google.com>, Julian Anastasov <ja@ssi.bg>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:59503 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755664AbaAHPGT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jan 2014 10:06:19 -0500
Received: by mail-we0-f174.google.com with SMTP id q58so1545835wes.19
        for <netdev@vger.kernel.org>; Wed, 08 Jan 2014 07:06:17 -0800 (PST)
In-Reply-To: <1389193559-16756-1-git-send-email-christoph.paasch@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a new netlink attribute for the source-IP and appends it
to the netlink reply. Now, iproute2 can have access to the source-IP.

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
index de32aa41a846..199659f7a871 100644
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
