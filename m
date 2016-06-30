From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net v2] net: bcmsysport: Device stats are unsigned long
Date: Thu, 30 Jun 2016 13:27:20 -0700
Message-ID: <1467318440-19152-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, edumazet@google.com, andrew@lunn.ch,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:35695 "EHLO
	mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751533AbcF3U1Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jun 2016 16:27:25 -0400
Received: by mail-pf0-f193.google.com with SMTP id t190so8187124pfb.2
        for <netdev@vger.kernel.org>; Thu, 30 Jun 2016 13:27:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 64bits kernels, device stats are 64bits wide, not 32bits.

Fixes: 80105befdb4b ("net: systemport: add Broadcom SYSTEMPORT Ethernet MAC driver")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
Changes in v2:

- use a plain cast to unsigned long

 drivers/net/ethernet/broadcom/bcmsysport.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bcmsysport.c b/drivers/net/ethernet/broadcom/bcmsysport.c
index 543bf38105c9..bfa26a2590c9 100644
--- a/drivers/net/ethernet/broadcom/bcmsysport.c
+++ b/drivers/net/ethernet/broadcom/bcmsysport.c
@@ -392,7 +392,7 @@ static void bcm_sysport_get_stats(struct net_device *dev,
 		else
 			p = (char *)priv;
 		p += s->stat_offset;
-		data[i] = *(u32 *)p;
+		data[i] = *(unsigned long *)p;
 	}
 }
 
-- 
2.7.4
