From: Daniel Mack <daniel@caiaq.de>
Subject: [PATCH] libertas: name the network device wlan%d
Date: Tue, 11 Aug 2009 16:13:32 +0200
Message-ID: <1250000012-25673-1-git-send-email-daniel@caiaq.de>
Cc: Daniel Mack <daniel@caiaq.de>, Roel Kluin <roel.kluin@gmail.com>,
	"John W. Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org
To: libertas-dev@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from buzzloop.caiaq.de ([212.112.241.133]:49963 "EHLO
	buzzloop.caiaq.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750929AbZHKONp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Aug 2009 10:13:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Devices created by the libertas driver are currently called eth%d. Which
is wrong, because the device does not at all have anything to do with
Ethernet. And it is also confusing when used on devices with more than
one network device.

Fix this by calling it wlan%d.

Signed-off-by: Daniel Mack <daniel@caiaq.de>
Cc: Roel Kluin <roel.kluin@gmail.com>
Cc: John W. Linville <linville@tuxdriver.com>
Cc: netdev@vger.kernel.org
---
 drivers/net/wireless/libertas/main.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/wireless/libertas/main.c b/drivers/net/wireless/libertas/main.c
index 89575e4..584022f 100644
--- a/drivers/net/wireless/libertas/main.c
+++ b/drivers/net/wireless/libertas/main.c
@@ -1204,6 +1204,7 @@ struct lbs_private *lbs_add_card(void *card, struct device *dmdev)
 	SET_NETDEV_DEV(dev, dmdev);
 
 	priv->rtap_net_dev = NULL;
+	strcpy(dev->name, "wlan%d");
 
 	lbs_deb_thread("Starting main thread...\n");
 	init_waitqueue_head(&priv->waitq);
-- 
1.6.3.3

