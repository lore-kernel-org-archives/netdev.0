From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] snap: remove one synchronize_net()
Date: Mon, 23 May 2011 10:41:48 +0200
Message-ID: <1306140108.2869.7.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:63272 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751786Ab1EWIlv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 May 2011 04:41:51 -0400
Received: by wya21 with SMTP id 21so4016418wya.19
        for <netdev@vger.kernel.org>; Mon, 23 May 2011 01:41:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No need to wait for a rcu grace period after list insertion.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/802/psnap.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/net/802/psnap.c b/net/802/psnap.c
index 21cde8f..db6baf7 100644
--- a/net/802/psnap.c
+++ b/net/802/psnap.c
@@ -147,7 +147,6 @@ struct datalink_proto *register_snap_client(const unsigned char *desc,
 out:
 	spin_unlock_bh(&snap_lock);
 
-	synchronize_net();
 	return proto;
 }
 


