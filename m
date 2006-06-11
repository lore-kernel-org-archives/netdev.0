From: Daniel Drake <dsd@gentoo.org>
Subject: [PATCH] zd1211rw: disable TX queue during stop
Date: Sun, 11 Jun 2006 23:18:54 +0100 (BST)
Message-ID: <20060611221854.E5B778A231E@zog.reactivated.net>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta08-winn.ispmail.ntl.com ([81.103.221.48]:49630 "EHLO
	mtaout02-winn.ispmail.ntl.com") by vger.kernel.org with ESMTP
	id S1751083AbWFKWSu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 11 Jun 2006 18:18:50 -0400
To: linville@tuxdriver.com
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This avoids some potential races.

Signed-off-by: Daniel Drake <dsd@gentoo.org>

diff --git a/drivers/net/wireless/zd1211rw/zd_mac.c b/drivers/net/wireless/zd1211rw/zd_mac.c
index bbe067e..3bdc54d 100644
--- a/drivers/net/wireless/zd1211rw/zd_mac.c
+++ b/drivers/net/wireless/zd1211rw/zd_mac.c
@@ -197,6 +197,8 @@ int zd_mac_stop(struct net_device *netde
 	struct zd_mac *mac = zd_netdev_mac(netdev);
 	struct zd_chip *chip = &mac->chip;
 
+	netif_stop_queue(netdev);
+
 	/*
 	 * The order here deliberately is a little different from the open()
 	 * method, since we need to make sure there is no opportunity for RX
