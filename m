From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] bnx2x: fix wrong return from bnx2x_trylock_hw_lock
Date: Fri, 27 Aug 2010 05:49:03 +0200
Message-ID: <1282880943.2501.13.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Vladislav Zolotarov <vladz@broadcom.com>,
	Eilon Greenstein <eilong@broadcom.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:39403 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752887Ab0H0DtJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Aug 2010 23:49:09 -0400
Received: by wwb28 with SMTP id 28so2671992wwb.1
        for <netdev@vger.kernel.org>; Thu, 26 Aug 2010 20:49:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bnx2x_trylock_hw_lock() returns a bool :

true if succeeded to acquire the lock.
false in case of error.

-EINVAL is not an acceptable value, since its promoted to true.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
Cosmetic patch, since compiler probably omits the code anyway.

diff --git a/drivers/net/bnx2x/bnx2x_main.c b/drivers/net/bnx2x/bnx2x_main.c
index f8c3f08..86cc4b0 100644
--- a/drivers/net/bnx2x/bnx2x_main.c
+++ b/drivers/net/bnx2x/bnx2x_main.c
@@ -781,7 +781,7 @@ static bool bnx2x_trylock_hw_lock(struct bnx2x *bp, u32 resource)
 		DP(NETIF_MSG_HW,
 		   "resource(0x%x) > HW_LOCK_MAX_RESOURCE_VALUE(0x%x)\n",
 		   resource, HW_LOCK_MAX_RESOURCE_VALUE);
-		return -EINVAL;
+		return false;
 	}
 
 	if (func <= 5)


