From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next] net: dsa: Fix inverted test for multiple CPU interface
Date: Sun, 22 Jan 2017 22:16:45 +0100
Message-ID: <1485119805-30338-1-git-send-email-andrew@lunn.ch>
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:41146 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750703AbdAVVkR (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 22 Jan 2017 16:40:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove the wrong !, otherwise we get false positives about having
multiple CPU interfaces.

Fixes: b22de490869d ("net: dsa: store CPU switch structure in the tree")
Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 net/dsa/dsa.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 77cb78767f1d..1f3afeb673d6 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -225,7 +225,7 @@ static int dsa_switch_setup_one(struct dsa_switch *ds, struct device *parent)
 			continue;
 
 		if (!strcmp(name, "cpu")) {
-			if (!dst->cpu_switch) {
+			if (dst->cpu_switch) {
 				netdev_err(dst->master_netdev,
 					   "multiple cpu ports?!\n");
 				return -EINVAL;
-- 
2.11.0
