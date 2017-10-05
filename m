From: William Tu <u9012063@gmail.com>
Subject: [PATCH net-next] ip_gre: check packet length and mtu correctly in erspan_fb_xmit
Date: Wed,  4 Oct 2017 17:14:05 -0700
Message-ID: <1507162445-18540-1-git-send-email-u9012063@gmail.com>
Cc: Xin Long <lucien.xin@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:33699 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750951AbdJEAOU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Oct 2017 20:14:20 -0400
Received: by mail-wm0-f65.google.com with SMTP id u138so8309816wmu.0
        for <netdev@vger.kernel.org>; Wed, 04 Oct 2017 17:14:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Similarly to early patch for erspan_xmit(), the ARPHDR_ETHER device
is the length of the whole ether packet.  So skb->len should subtract
the dev->hard_header_len.

Fixes: 1a66a836da63 ("gre: add collect_md mode to ERSPAN tunnel")
Signed-off-by: William Tu <u9012063@gmail.com>
Cc: Xin Long <lucien.xin@gmail.com>
---
 net/ipv4/ip_gre.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index b279c325c7f6..10b21fe5b3a6 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -579,7 +579,7 @@ static void erspan_fb_xmit(struct sk_buff *skb, struct net_device *dev,
 	if (gre_handle_offloads(skb, false))
 		goto err_free_rt;
 
-	if (skb->len > dev->mtu) {
+	if (skb->len - dev->hard_header_len > dev->mtu) {
 		pskb_trim(skb, dev->mtu);
 		truncate = true;
 	}
-- 
2.7.4
