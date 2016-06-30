From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net] net: bcmsysport: Device stats are unsigned long
Date: Thu, 30 Jun 2016 10:56:29 -0700
Message-ID: <1467309389-12377-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, edumazet@google.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:36827 "EHLO
	mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752119AbcF3R4q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jun 2016 13:56:46 -0400
Received: by mail-pa0-f68.google.com with SMTP id av7so7718131pac.3
        for <netdev@vger.kernel.org>; Thu, 30 Jun 2016 10:56:34 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 64bits kernels, device stats are 64bits wide, not 32bits.

Fixes: 80105befdb4b ("net: systemport: add Broadcom SYSTEMPORT Ethernet MAC driver")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/bcmsysport.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bcmsysport.c b/drivers/net/ethernet/broadcom/bcmsysport.c
index 543bf38105c9..21f21e23e695 100644
--- a/drivers/net/ethernet/broadcom/bcmsysport.c
+++ b/drivers/net/ethernet/broadcom/bcmsysport.c
@@ -392,7 +392,11 @@ static void bcm_sysport_get_stats(struct net_device *dev,
 		else
 			p = (char *)priv;
 		p += s->stat_offset;
-		data[i] = *(u32 *)p;
+		if (sizeof(unsigned long) != sizeof(u32) &&
+		    s->stat_sizeof == sizeof(unsigned long))
+			data[i] = *(unsigned long *)p;
+		else
+			data[i] = *(u32 *)p;
 	}
 }
 
-- 
2.7.4
