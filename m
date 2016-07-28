From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH -next] net: ipv6: use list_move instead of list_del/list_add
Date: Thu, 28 Jul 2016 16:19:03 +0000
Message-ID: <1469722743-15317-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <weiyj.lk@gmail.com>, netdev@vger.kernel.org
To: "David S . Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:33468 "EHLO
	mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932500AbcG1QTO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jul 2016 12:19:14 -0400
Received: by mail-pa0-f68.google.com with SMTP id q2so3789176pap.0
        for <netdev@vger.kernel.org>; Thu, 28 Jul 2016 09:19:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using list_move() instead of list_del() + list_add().

Signed-off-by: Wei Yongjun <weiyj.lk@gmail.com>
---
 net/ipv6/addrconf.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 6287a8b..ab3e796 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -3624,8 +3624,7 @@ restart:
 			state = ifa->state;
 			ifa->state = INET6_IFADDR_STATE_DEAD;
 
-			list_del(&ifa->if_list);
-			list_add(&ifa->if_list, &del_list);
+			list_move(&ifa->if_list, &del_list);
 		}
 
 		spin_unlock_bh(&ifa->lock);
