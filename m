From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next 1/3] r8152: move r8152b_get_version
Date: Thu, 6 Nov 2014 12:47:38 +0800
Message-ID: <1394712342-15778-85-Taiwan-albertk@realtek.com>
References: <1394712342-15778-84-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:53498 "EHLO
	rtits2.realtek.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750999AbaKFEsO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2014 23:48:14 -0500
In-Reply-To: <1394712342-15778-84-Taiwan-albertk@realtek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move r8152b_get_version() to the location before rtl_ops_init().
Then, the rtl_ops_init() could use tp->version.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index fd41675..4b6db8a 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -3833,6 +3833,7 @@ static int rtl8152_probe(struct usb_interface *intf,
 	tp->netdev = netdev;
 	tp->intf = intf;
 
+	r8152b_get_version(tp);
 	ret = rtl_ops_init(tp, id);
 	if (ret)
 		goto out;
@@ -3866,11 +3867,9 @@ static int rtl8152_probe(struct usb_interface *intf,
 	tp->mii.phy_id_mask = 0x3f;
 	tp->mii.reg_num_mask = 0x1f;
 	tp->mii.phy_id = R8152_PHY_ID;
-	tp->mii.supports_gmii = 0;
 
 	intf->needs_remote_wakeup = 1;
 
-	r8152b_get_version(tp);
 	tp->rtl_ops.init(tp);
 	set_ethernet_addr(tp);
 
-- 
1.9.3
