From: yuan linyu <cugyly@163.com>
Subject: [PATCH net-next 10/11] atm: skb_put_zero() used to optimize code
Date: Wed, 14 Jun 2017 22:58:39 +0800
Message-ID: <1497452319-5100-1-git-send-email-cugyly@163.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
        yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-16.163.com ([220.181.12.16]:49402 "EHLO m12-16.163.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751829AbdFNO7I (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 14 Jun 2017 10:59:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>

Signed-off-by: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
---
 net/atm/signaling.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/atm/signaling.c b/net/atm/signaling.c
index adb6e3d..380d496 100644
--- a/net/atm/signaling.c
+++ b/net/atm/signaling.c
@@ -150,8 +150,7 @@ void sigd_enq2(struct atm_vcc *vcc, enum atmsvc_msg_type type,
 	pr_debug("%d (0x%p)\n", (int)type, vcc);
 	while (!(skb = alloc_skb(sizeof(struct atmsvc_msg), GFP_KERNEL)))
 		schedule();
-	msg = (struct atmsvc_msg *)skb_put(skb, sizeof(struct atmsvc_msg));
-	memset(msg, 0, sizeof(*msg));
+	msg = (struct atmsvc_msg *)skb_put_zero(skb, sizeof(struct atmsvc_msg));
 	msg->type = type;
 	*(struct atm_vcc **) &msg->vcc = vcc;
 	*(struct atm_vcc **) &msg->listen_vcc = listen_vcc;
-- 
2.7.4
