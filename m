From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH 3/44] [XFRM] STATE: Allow non IPsec protocol.
Date: Thu, 24 Aug 2006 00:02:04 +0900
Message-ID: <1156345365325-git-send-email-yoshfuji@linux-ipv6.org>
References: <11563453651167-git-send-email-yoshfuji@linux-ipv6.org> <11563453651533-git-send-email-yoshfuji@linux-ipv6.org> <11563453653169-git-send-email-yoshfuji@linux-ipv6.org>
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org,
	Masahide NAKAMURA <nakam@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pc9.nezu.wide.ad.jp ([203.178.142.216]:56712 "EHLO
	jupiter.linux-ipv6.org") by vger.kernel.org with ESMTP
	id S964912AbWHWPCt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 11:02:49 -0400
To: davem@davemloft.net
In-Reply-To: <11563453653169-git-send-email-yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Masahide NAKAMURA <nakam@linux-ipv6.org>

It will be added two more transformation protocols (routing header
and destination options header) for Mobile IPv6.
xfrm_id_proto_match() can be handle zero as all, IPSEC_PROTO_ANY as
all IPsec and otherwise as exact one.
Based on MIPL2 kernel patch.

Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 include/net/xfrm.h   |    5 ++++-
 net/xfrm/xfrm_user.c |    2 +-
 2 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 6f29529..2ad9c1a 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -839,7 +839,10 @@ static inline int xfrm_state_kern(struct
 
 static inline int xfrm_id_proto_match(u8 proto, u8 userproto)
 {
-	return (userproto == IPSEC_PROTO_ANY || proto == userproto);
+	return (!userproto || proto == userproto ||
+		(userproto == IPSEC_PROTO_ANY && (proto == IPPROTO_AH ||
+						  proto == IPPROTO_ESP ||
+						  proto == IPPROTO_COMP)));
 }
 
 /*
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 471439d..3db8515 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -540,7 +540,7 @@ static int xfrm_dump_sa(struct sk_buff *
 	info.nlmsg_flags = NLM_F_MULTI;
 	info.this_idx = 0;
 	info.start_idx = cb->args[0];
-	(void) xfrm_state_walk(IPSEC_PROTO_ANY, dump_one_state, &info);
+	(void) xfrm_state_walk(0, dump_one_state, &info);
 	cb->args[0] = info.this_idx;
 
 	return skb->len;
-- 
1.4.0

