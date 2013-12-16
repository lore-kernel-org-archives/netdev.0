From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH -next] xen-netback: fix some error return code
Date: Mon, 16 Dec 2013 13:49:29 +0800
Message-ID: <CAPgLHd9aQQq-gLuNzGaYP2TSz=5Xk_GqgS=MSrAB7Tnn0nCydw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei@trendmicro.com.cn, xen-devel@lists.xenproject.org,
	netdev@vger.kernel.org
To: ian.campbell@citrix.com, wei.liu2@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f50.google.com ([209.85.214.50]:37935 "EHLO
	mail-bk0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750962Ab3LPFta (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 00:49:30 -0500
Received: by mail-bk0-f50.google.com with SMTP id e11so2182189bkh.9
        for <netdev@vger.kernel.org>; Sun, 15 Dec 2013 21:49:29 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Fix to return -EPROTO error code instead of 0(overwrite by maybe_pull_tail())
if skb_partial_csum_set() return false.

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 drivers/net/xen-netback/netback.c | 16 ++++++++++++----
 1 file changed, 12 insertions(+), 4 deletions(-)

diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index 800496b..b16daa7 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -1108,8 +1108,10 @@ static int checksum_setup_ip(struct xenvif *vif, struct sk_buff *skb,
 			goto out;
 
 		if (!skb_partial_csum_set(skb, off,
-					  offsetof(struct tcphdr, check)))
+					  offsetof(struct tcphdr, check))) {
+			err = -EPROTO;
 			goto out;
+		}
 
 		if (recalculate_partial_csum)
 			tcp_hdr(skb)->check =
@@ -1126,8 +1128,10 @@ static int checksum_setup_ip(struct xenvif *vif, struct sk_buff *skb,
 			goto out;
 
 		if (!skb_partial_csum_set(skb, off,
-					  offsetof(struct udphdr, check)))
+					  offsetof(struct udphdr, check))) {
+			err = -EPROTO;
 			goto out;
+		}
 
 		if (recalculate_partial_csum)
 			udp_hdr(skb)->check =
@@ -1249,8 +1253,10 @@ static int checksum_setup_ipv6(struct xenvif *vif, struct sk_buff *skb,
 			goto out;
 
 		if (!skb_partial_csum_set(skb, off,
-					  offsetof(struct tcphdr, check)))
+					  offsetof(struct tcphdr, check))) {
+			err = -EPROTO;
 			goto out;
+		}
 
 		if (recalculate_partial_csum)
 			tcp_hdr(skb)->check =
@@ -1267,8 +1273,10 @@ static int checksum_setup_ipv6(struct xenvif *vif, struct sk_buff *skb,
 			goto out;
 
 		if (!skb_partial_csum_set(skb, off,
-					  offsetof(struct udphdr, check)))
+					  offsetof(struct udphdr, check))) {
+			err = -EPROTO;
 			goto out;
+		}
 
 		if (recalculate_partial_csum)
 			udp_hdr(skb)->check =
