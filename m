From: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Subject: [PATCH 12/17] fakehard: claim all 2.4 Ghz channels as supported
Date: Fri,  6 Nov 2009 15:39:36 +0300
Message-ID: <1257511181-19403-13-git-send-email-dbaryshkov@gmail.com>
References: <1257511181-19403-1-git-send-email-dbaryshkov@gmail.com>
Cc: netdev@vger.kernel.org, Sergey Lapin <slapin@ossfans.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.27]:64857 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758099AbZKFMk5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2009 07:40:57 -0500
Received: by ey-out-2122.google.com with SMTP id 9so85501eyd.5
        for <netdev@vger.kernel.org>; Fri, 06 Nov 2009 04:41:03 -0800 (PST)
In-Reply-To: <1257511181-19403-1-git-send-email-dbaryshkov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make fakehard device claim all 2.4 Ghz channels from 802.15.4-2006,
802.15.4a-2007 as supported by the hw.

Signed-off-by: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
---
 drivers/ieee802154/fakehard.c |   10 +++++++++-
 1 files changed, 9 insertions(+), 1 deletions(-)

diff --git a/drivers/ieee802154/fakehard.c b/drivers/ieee802154/fakehard.c
index ccf83eb..70a9f9c 100644
--- a/drivers/ieee802154/fakehard.c
+++ b/drivers/ieee802154/fakehard.c
@@ -356,7 +356,15 @@ static int __devinit ieee802154fake_probe(struct platform_device *pdev)
 			dev->addr_len);
 	memcpy(dev->perm_addr, dev->dev_addr, dev->addr_len);
 
-	phy->channels_supported[0] = (1 << 27) - 1;
+	/*
+	 * For now we'd like to emulate 2.4 GHz-only device,
+	 * both O-QPSK and CSS
+	 */
+	/* 2.4 GHz O-QPSK 802.15.4-2003 */
+	phy->channels_supported[0] |= 0x7FFF800;
+	/* 2.4 GHz CSS 802.15.4a-2007 */
+	phy->channels_supported[3] |= 0x3fff;
+
 	phy->transmit_power = 0xbf;
 
 	dev->netdev_ops = &fake_ops;
-- 
1.6.5

