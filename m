From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net 1/2] net: dsa: Test array index before use
Date: Sat, 11 Jul 2015 18:02:10 -0700
Message-ID: <1436662931-8982-2-git-send-email-f.fainelli@gmail.com>
References: <1436662931-8982-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch, linux@roeck-us.net,
	dan.carpenter@oracle.com, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f42.google.com ([209.85.218.42]:36837 "EHLO
	mail-oi0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750935AbbGLBCS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jul 2015 21:02:18 -0400
Received: by oibn4 with SMTP id n4so3028536oib.3
        for <netdev@vger.kernel.org>; Sat, 11 Jul 2015 18:02:18 -0700 (PDT)
In-Reply-To: <1436662931-8982-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

port_index is used an index into an array, and this information comes
from Device Tree, make sure that port_index is not equal to the array
size before using it. Move the check against port_index earlier in the
loop.

Fixes: 5e95329b701c: ("dsa: add device tree bindings to register DSA switches")
Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 net/dsa/dsa.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 392e29a0227d..52beeb8829dc 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -642,6 +642,8 @@ static int dsa_of_probe(struct device *dev)
 				continue;
 
 			port_index = be32_to_cpup(port_reg);
+			if (port_index >= DSA_MAX_PORTS)
+				break;
 
 			port_name = of_get_property(port, "label", NULL);
 			if (!port_name)
@@ -666,8 +668,6 @@ static int dsa_of_probe(struct device *dev)
 					goto out_free_chip;
 			}
 
-			if (port_index == DSA_MAX_PORTS)
-				break;
 		}
 	}
 
-- 
2.1.4
