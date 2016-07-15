From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net] net: nb8800: Fix SKB leak in nb8800_receive()
Date: Fri, 15 Jul 2016 16:41:16 -0700
Message-ID: <1468626084-31618-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>,
	=?UTF-8?q?M=C3=A5ns=20Rullg=C3=A5rd?= <mans@mansr.com>,
	Sebastian Frias <sf84@laposte.net>,
	Arnd Bergmann <arnd@arndb.de>,
	linux-kernel@vger.kernel.org (open list)
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:36043 "EHLO
	mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751475AbcGOXlo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jul 2016 19:41:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In case nb8800_receive() fails to allocate a fragment, we would leak the
SKB freshly allocated and just return, instead, free it.

Reported-by: coverity (CID 1341750)
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/aurora/nb8800.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/aurora/nb8800.c b/drivers/net/ethernet/aurora/nb8800.c
index 08a23e6b60e9..1a3555d03a96 100644
--- a/drivers/net/ethernet/aurora/nb8800.c
+++ b/drivers/net/ethernet/aurora/nb8800.c
@@ -259,6 +259,7 @@ static void nb8800_receive(struct net_device *dev, unsigned int i,
 		if (err) {
 			netdev_err(dev, "rx buffer allocation failed\n");
 			dev->stats.rx_dropped++;
+			dev_kfree_skb(skb);
 			return;
 		}
 
-- 
2.7.4
