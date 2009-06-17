From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH] sis190: use an adequate phy list entry as a fallback
Date: Wed, 17 Jun 2009 23:43:11 +0200
Message-ID: <20090617214311.GB27064@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arnaud Patard <apatard@mandriva.com>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:32864 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751355AbZFQVk7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2009 17:40:59 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When sis190 driver is trying to get default phy, if it doesn't find home
or lan phy, it falls back to the first phy in the phy list but list_entry()
points to a bogus entry. list_first_entry() should be used instead.

Signed-off-by: Arnaud Patard <apatard@mandriva.com>
Acked-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/sis190.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/sis190.c b/drivers/net/sis190.c
index e224766..1f040e8 100644
--- a/drivers/net/sis190.c
+++ b/drivers/net/sis190.c
@@ -1281,7 +1281,7 @@ static u16 sis190_default_phy(struct net_device *dev)
 		else if (phy_lan)
 			phy_default = phy_lan;
 		else
-			phy_default = list_entry(&tp->first_phy,
+			phy_default = list_first_entry(&tp->first_phy,
 						 struct sis190_phy, list);
 	}
 
-- 
1.6.2.2

