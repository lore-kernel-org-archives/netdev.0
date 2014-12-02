From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 2/2] net: phy: bcm7xxx: add an explicit version check for GPHY rev G0
Date: Tue,  2 Dec 2014 15:28:02 -0800
Message-ID: <1417562882-2511-3-git-send-email-f.fainelli@gmail.com>
References: <1417562882-2511-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:60524 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932722AbaLBX2P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Dec 2014 18:28:15 -0500
Received: by mail-pd0-f172.google.com with SMTP id y13so14125569pdi.31
        for <netdev@vger.kernel.org>; Tue, 02 Dec 2014 15:28:14 -0800 (PST)
In-Reply-To: <1417562882-2511-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

GPHY revision G0 has its version rolled over to 0x10, introduce an
explicit check for that revision and invoke the proper workaround
function for it.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/bcm7xxx.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/phy/bcm7xxx.c b/drivers/net/phy/bcm7xxx.c
index 7a53af4346e4..974ec4515269 100644
--- a/drivers/net/phy/bcm7xxx.c
+++ b/drivers/net/phy/bcm7xxx.c
@@ -252,6 +252,8 @@ static int bcm7xxx_28nm_config_init(struct phy_device *phydev)
 		break;
 	case 0xe0:
 	case 0xf0:
+	/* Rev G0 introduces a roll over */
+	case 0x10:
 		ret = bcm7xxx_28nm_e0_plus_afe_config_init(phydev);
 		break;
 	default:
-- 
2.1.0
