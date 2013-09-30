From: Peter Korsgaard <peter@korsgaard.com>
Subject: [PATCH] dm9601: fix IFF_ALLMULTI handling
Date: Mon, 30 Sep 2013 23:28:20 +0200
Message-ID: <1380576500-8531-1-git-send-email-peter@korsgaard.com>
Cc: joseph_chang@davicom.com.tw, Peter Korsgaard <peter@korsgaard.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f177.google.com ([209.85.215.177]:58408 "EHLO
	mail-ea0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754855Ab3I3V2f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Sep 2013 17:28:35 -0400
Received: by mail-ea0-f177.google.com with SMTP id f15so2950363eak.22
        for <netdev@vger.kernel.org>; Mon, 30 Sep 2013 14:28:34 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pass-all-multicast is controlled by bit 3 in RX control, not bit 2
(pass undersized frames).

Reported-by: Joseph Chang <joseph_chang@davicom.com.tw>
Signed-off-by: Peter Korsgaard <peter@korsgaard.com>
---
 drivers/net/usb/dm9601.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/usb/dm9601.c b/drivers/net/usb/dm9601.c
index 2dbb946..c6867f9 100644
--- a/drivers/net/usb/dm9601.c
+++ b/drivers/net/usb/dm9601.c
@@ -303,7 +303,7 @@ static void dm9601_set_multicast(struct net_device *net)
 		rx_ctl |= 0x02;
 	} else if (net->flags & IFF_ALLMULTI ||
 		   netdev_mc_count(net) > DM_MAX_MCAST) {
-		rx_ctl |= 0x04;
+		rx_ctl |= 0x08;
 	} else if (!netdev_mc_empty(net)) {
 		struct netdev_hw_addr *ha;
 
-- 
1.7.10.4
