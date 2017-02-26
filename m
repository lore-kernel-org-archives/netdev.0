From: =?UTF-8?q?Paul=20H=C3=BCber?= <phueber@kernsp.in>
Subject: [PATCH net] l2tp: avoid use-after-free caused by l2tp_ip_backlog_recv
Date: Sun, 26 Feb 2017 17:58:19 +0100
Message-ID: <20170226165819.27660-1-phueber@kernsp.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from harbin.kernsp.in ([193.183.99.167]:40234 "EHLO harbin.kernsp.in"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750934AbdBZRGE (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 26 Feb 2017 12:06:04 -0500
Received: from fengshui.fritz.box (p578E7ED7.dip0.t-ipconnect.de [87.142.126.215])
        by harbin.kernsp.in (Postfix) with ESMTPSA id 23F2F28023
        for <netdev@vger.kernel.org>; Sun, 26 Feb 2017 16:57:16 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

l2tp_ip_backlog_recv may not return -1 if the packet gets dropped.
The return value is passed up to ip_local_deliver_finish, which treats
negative values as an IP protocol number for resubmission.

Signed-off-by: Paul Hüber <phueber@kernsp.in>
---
 net/l2tp/l2tp_ip.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/l2tp/l2tp_ip.c b/net/l2tp/l2tp_ip.c
index 28c21546d5b6..3ed30153a6f5 100644
--- a/net/l2tp/l2tp_ip.c
+++ b/net/l2tp/l2tp_ip.c
@@ -381,7 +381,7 @@ static int l2tp_ip_backlog_recv(struct sock *sk, struct sk_buff *skb)
 drop:
 	IP_INC_STATS(sock_net(sk), IPSTATS_MIB_INDISCARDS);
 	kfree_skb(skb);
-	return -1;
+	return 0;
 }
 
 /* Userspace will call sendmsg() on the tunnel socket to send L2TP
-- 
2.11.1
