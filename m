From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH RFC v2 27/32] net: dsa: If a switch fails to probe, defer probing
Date: Sun, 28 Feb 2016 17:41:35 +0100
Message-ID: <1456677700-23027-28-git-send-email-andrew@lunn.ch>
References: <1456677700-23027-1-git-send-email-andrew@lunn.ch>
Cc: Andrew Lunn <andrew@lunn.ch>
To: Florian Fainelli <f.fainelli@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:44977 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759764AbcB1QnA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Feb 2016 11:43:00 -0500
In-Reply-To: <1456677700-23027-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Switches are either listed in device tree or platform_data. They
should exist. If the probe fails, defer the probe, which is the likely
cause of failure, not broken device tree or platform data.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
Acked-by: Florian Fainelli <f.fainelli@gmail.com>
---
 net/dsa/dsa.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index f3ffc937b152..c61b7ab092f5 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -435,7 +435,7 @@ dsa_switch_setup(struct dsa_switch_tree *dst, int index,
 	if (drv == NULL) {
 		netdev_err(dst->master_netdev, "[%d]: could not detect attached switch\n",
 			   index);
-		return ERR_PTR(-EINVAL);
+		return ERR_PTR(-EPROBE_DEFER);
 	}
 	netdev_info(dst->master_netdev, "[%d]: detected a %s switch\n",
 		    index, name);
-- 
2.7.0
