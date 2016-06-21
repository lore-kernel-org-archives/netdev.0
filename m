From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next] net: dsa: b53: Fix statistics readings
Date: Mon, 20 Jun 2016 18:26:53 -0700
Message-ID: <1466472413-25824-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
	vivien.didelot@savoirfairelinux.com, jogo@openwrt.org,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f193.google.com ([209.85.214.193]:33421 "EHLO
	mail-ob0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751235AbcFUB2k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2016 21:28:40 -0400
Received: by mail-ob0-f193.google.com with SMTP id f10so272776obr.0
        for <netdev@vger.kernel.org>; Mon, 20 Jun 2016 18:27:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Due to a typo we would always be using the MIB counter width of the
first element of the counter array instead of the current element, and
we would always be accessing the register statistics with a 64-bits
read, while some could be 32-bits. This got unnoticed in testing with
MDIO and SRAB which tolerate doing this, but testing with the SPI bus
revealed bogus values being returned. Fix this by using the proper
iterator here.

Fixes: 967dd82ffc52 ("net: dsa: b53: Add support for Broadcom RoboSwitch")
Reported-by: Jonas Gorski <jogo@openwrt.org>
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/b53/b53_common.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/dsa/b53/b53_common.c b/drivers/net/dsa/b53/b53_common.c
index 668d329b3e72..48fc63c22b6a 100644
--- a/drivers/net/dsa/b53/b53_common.c
+++ b/drivers/net/dsa/b53/b53_common.c
@@ -679,7 +679,7 @@ static void b53_get_ethtool_stats(struct dsa_switch *ds, int port,
 	for (i = 0; i < mib_size; i++) {
 		s = &mibs[i];
 
-		if (mibs->size == 8) {
+		if (s->size == 8) {
 			b53_read64(dev, B53_MIB_PAGE(port), s->offset, &val);
 		} else {
 			u32 val32;
-- 
2.7.4
