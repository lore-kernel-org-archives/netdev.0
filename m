From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] net: bcmgenet: device stats are unsigned long
Date: Fri, 15 Apr 2016 10:47:52 -0700
Message-ID: <1460742472.10638.78.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:36374 "EHLO
	mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750906AbcDORry (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Apr 2016 13:47:54 -0400
Received: by mail-pf0-f180.google.com with SMTP id e128so58749899pfe.3
        for <netdev@vger.kernel.org>; Fri, 15 Apr 2016 10:47:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

On 64bit kernels, device stats are 64bit wide, not 32bit.

Fixes: 1c1008c793fa4 ("net: bcmgenet: add main driver file")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c |    6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index cf6445d148ca..44ad1490b472 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -878,7 +878,11 @@ static void bcmgenet_get_ethtool_stats(struct net_device *dev,
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
 
