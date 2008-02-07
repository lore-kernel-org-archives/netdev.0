From: Masakazu Mokuno <mokuno@sm.sony.co.jp>
Subject: [PATCH 1/7] PS3: gelic: Fix the wrong dev_id passed
Date: Thu, 07 Feb 2008 19:57:41 +0900
Message-ID: <20080207195725.AD40.40F06B3A@sm.sony.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, geoffrey.levand@am.sony.com,
	Geert Uytterhoeven <Geert.Uytterhoeven@sonycom.com>
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from MGW3.Sony.CO.JP ([137.153.0.15]:60222 "EHLO mgw3.sony.co.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754798AbYBGK5t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Feb 2008 05:57:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PS3: gelic: Fix the wrong dev_id passed

The device id for lv1_net_set_interrupt_status_indicator() is wrong.
This path would be invoked only in the case of an initialization failure.

Signed-off-by: Masakazu Mokuno <mokuno@sm.sony.co.jp>
---
 drivers/net/ps3_gelic_net.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- a/drivers/net/ps3_gelic_net.c
+++ b/drivers/net/ps3_gelic_net.c
@@ -1512,7 +1512,7 @@ static int ps3_gelic_driver_probe (struc
 
 fail_setup_netdev:
 	lv1_net_set_interrupt_status_indicator(bus_id(card),
-					       bus_id(card),
+					       dev_id(card),
 					       0 , 0);
 fail_status_indicator:
 	ps3_dma_region_free(dev->d_region);


