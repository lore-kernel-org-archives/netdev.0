From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.25] compilation fix for
 drivers/net/wireless/libertas/debugfs.c
Date: Thu, 27 Dec 2007 16:45:16 -0800 (PST)
Message-ID: <20071227.164516.236177397.davem@davemloft.net>
References: <20071227102454.GA14163@iris.sw.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: devel@openvz.org, mchan@broadcom.com, netdev@vger.kernel.org
To: den@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53258
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754663AbXL1ApQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Dec 2007 19:45:16 -0500
In-Reply-To: <20071227102454.GA14163@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Denis V. Lunev" <den@openvz.org>
Date: Thu, 27 Dec 2007 13:24:54 +0300

> Compilation fix. MAC_FMT is required for
> drivers/net/wireless/libertas/debugfs.c

Putting this public macro back into a header file just
for one driver's debug handling is just rediculious.

I've checked in the following fix instead, thanks.

commit f7b4d3b86615b95b104ca0a95902ca86373a6548
Author: David S. Miller <davem@davemloft.net>
Date:   Thu Dec 27 16:43:38 2007 -0800

    [LIBERTAS]: Remove last stray user of MAC_FMT.
    
    Reported by Denis V. Lunev
    
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/drivers/net/wireless/libertas/debugfs.c b/drivers/net/wireless/libertas/debugfs.c
index 0bda0b5..95dd4ed 100644
--- a/drivers/net/wireless/libertas/debugfs.c
+++ b/drivers/net/wireless/libertas/debugfs.c
@@ -243,7 +243,8 @@ static void libertas_parse_bssid(char *buf, size_t count,
 	if (!hold)
 		return;
 	hold += 6;
-	sscanf(hold, MAC_FMT, mac, mac+1, mac+2, mac+3, mac+4, mac+5);
+	sscanf(hold, "%02x:%02x:%02x:%02x:%02x:%02x",
+	       mac, mac+1, mac+2, mac+3, mac+4, mac+5);
 	memcpy(scan_cfg->bssid, mac, ETH_ALEN);
 }
 
