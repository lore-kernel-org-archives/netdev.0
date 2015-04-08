From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next] vxlan: fix a shadow local variable
Date: Wed,  8 Apr 2015 10:17:58 -0700
Message-ID: <1428513478-7852-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:32908 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753584AbbDHRSK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2015 13:18:10 -0400
Received: by paboj16 with SMTP id oj16so120921330pab.0
        for <netdev@vger.kernel.org>; Wed, 08 Apr 2015 10:18:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 79b16aadea32cce077
("udp_tunnel: Pass UDP socket down through udp_tunnel{, 6}_xmit_skb()")
introduce 'sk' but we already have one inner 'sk'.

Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 drivers/net/vxlan.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 51baac7..682838b 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1977,7 +1977,6 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 		iptunnel_xmit_stats(err, &dev->stats, dev->tstats);
 #if IS_ENABLED(CONFIG_IPV6)
 	} else {
-		struct sock *sk = vxlan->vn_sock->sock->sk;
 		struct dst_entry *ndst;
 		struct flowi6 fl6;
 		u32 flags;
-- 
1.8.3.1
