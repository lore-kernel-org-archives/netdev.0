From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next v4 2/3] packet_diag: disclose meminfo values
Date: Thu, 25 Apr 2013 18:53:53 +0200
Message-ID: <1366908834-21606-3-git-send-email-nicolas.dichtel@6wind.com>
References: <1366903930.8964.154.camel@edumazet-glaptop>
 <1366908834-21606-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, xiyou.wangcong@gmail.com,
	netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:56527 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758187Ab3DYQx5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Apr 2013 12:53:57 -0400
In-Reply-To: <1366908834-21606-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sk_rmem_alloc is disclosed via /proc/net/packet but not via netlink messages.
The goal is to have the same level of information.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 include/uapi/linux/packet_diag.h | 2 ++
 net/packet/diag.c                | 4 ++++
 2 files changed, 6 insertions(+)

diff --git a/include/uapi/linux/packet_diag.h b/include/uapi/linux/packet_diag.h
index 84f83a4..c0802c1 100644
--- a/include/uapi/linux/packet_diag.h
+++ b/include/uapi/linux/packet_diag.h
@@ -16,6 +16,7 @@ struct packet_diag_req {
 #define PACKET_SHOW_MCLIST	0x00000002 /* A set of packet_diag_mclist-s */
 #define PACKET_SHOW_RING_CFG	0x00000004 /* Rings configuration parameters */
 #define PACKET_SHOW_FANOUT	0x00000008
+#define PACKET_SHOW_MEMINFO	0x00000010
 
 struct packet_diag_msg {
 	__u8	pdiag_family;
@@ -33,6 +34,7 @@ enum {
 	PACKET_DIAG_TX_RING,
 	PACKET_DIAG_FANOUT,
 	PACKET_DIAG_UID,
+	PACKET_DIAG_MEMINFO,
 
 	__PACKET_DIAG_MAX,
 };
diff --git a/net/packet/diag.c b/net/packet/diag.c
index 04c8219..822fe9b 100644
--- a/net/packet/diag.c
+++ b/net/packet/diag.c
@@ -166,6 +166,10 @@ static int sk_diag_fill(struct sock *sk, struct sk_buff *skb,
 			pdiag_put_fanout(po, skb))
 		goto out_nlmsg_trim;
 
+	if ((req->pdiag_show & PACKET_SHOW_MEMINFO) &&
+	    sock_diag_put_meminfo(sk, skb, PACKET_DIAG_MEMINFO))
+		goto out_nlmsg_trim;
+
 	return nlmsg_end(skb, nlh);
 
 out_nlmsg_trim:
-- 
1.8.2.1
