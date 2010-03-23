From: Jens Rottmann <JRottmann@LiPPERTEmbedded.de>
Subject: [PATCH] ksz884x: fix return value of netdev_set_eeprom
Date: Tue, 23 Mar 2010 15:23:50 +0100
Message-ID: <4BA8CEF6.2010707@LiPPERTEmbedded.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Tristram Ha <Tristram.Ha@micrel.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ksz884x: fix return value of netdev_set_eeprom

netdev_set_eeprom() confused ethtool by just returning 1 on error
instead of a proper -EINVAL.

Signed-off-by: Jens Rottmann <JRottmann@LiPPERTEmbedded.de>
---

--- linux-2.6.34-rc2-git1/drivers/net/ksz884x.c
+++ return_value_fixed/drivers/net/ksz884x.c
@@ -6322,7 +6322,7 @@ static int netdev_set_eeprom(struct net_
 	int len;

 	if (eeprom->magic != EEPROM_MAGIC)
-		return 1;
+		return -EINVAL;

 	len = (eeprom->offset + eeprom->len + 1) / 2;
 	for (i = eeprom->offset / 2; i < len; i++)
_
