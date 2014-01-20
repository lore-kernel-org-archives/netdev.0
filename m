From: Joe Perches <joe@perches.com>
Subject: [PATCH 7/7] dsa: Use ether_addr_copy
Date: Mon, 20 Jan 2014 09:52:20 -0800
Message-ID: <3c33df937d3cf83447bad0d6d219bdf66b629735.1390239869.git.joe@perches.com>
References: <cover.1390239869.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0101.hostedemail.com ([216.40.44.101]:36064 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753568AbaATRwr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jan 2014 12:52:47 -0500
In-Reply-To: <cover.1390239869.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use ether_addr_copy instead of memcpy(a, b, ETH_ALEN) to
save some cycles on arm and powerpc.

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/dsa/slave.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 29d684e..02c0e17 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -156,7 +156,7 @@ static int dsa_slave_set_mac_address(struct net_device *dev, void *a)
 		dev_uc_del(master, dev->dev_addr);
 
 out:
-	memcpy(dev->dev_addr, addr->sa_data, ETH_ALEN);
+	ether_addr_copy(dev->dev_addr, addr->sa_data);
 
 	return 0;
 }
-- 
1.8.1.2.459.gbcd45b4.dirty
