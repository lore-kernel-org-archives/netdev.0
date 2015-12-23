From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH RFC 24/28] net: dsa: If a switch fails to probe, defer probing
Date: Wed, 23 Dec 2015 13:56:38 +0100
Message-ID: <1450875402-20740-25-git-send-email-andrew@lunn.ch>
References: <1450875402-20740-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Florian Fainelli <f.fainelli@gmail.com>, narmstrong@baylibre.com,
	vivien.didelot@savoirfairelinux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:48783 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757203AbbLWM6h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Dec 2015 07:58:37 -0500
In-Reply-To: <1450875402-20740-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Switches are either listed in device tree of platform_data. They
should exist. If the probe fails, defer the probe, which is the likely
cause of failure, not broken device tree or platform data.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 net/dsa/dsa.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 5e037772bb32..c5f55b672675 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -391,7 +391,7 @@ dsa_switch_setup(struct dsa_switch_tree *dst, int index,
 	if (drv == NULL) {
 		netdev_err(dst->master_netdev, "[%d]: could not detect attached switch\n",
 			   index);
-		return ERR_PTR(-EINVAL);
+		return ERR_PTR(-EPROBE_DEFER);
 	}
 	netdev_info(dst->master_netdev, "[%d]: detected a %s switch\n",
 		    index, name);
-- 
2.6.3
