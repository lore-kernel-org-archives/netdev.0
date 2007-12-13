From: Masakazu Mokuno <mokuno@sm.sony.co.jp>
Subject: [PATCH 1/6] PS3: gelic: Fix the wrong dev_id passed
Date: Thu, 13 Dec 2007 21:05:10 +0900
Message-ID: <20071213205714.BF7C.MOKUNO@sm.sony.co.jp>
References: <20071213181146.BF69.MOKUNO@sm.sony.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: "Linux/PPC Development" <linuxppc-dev@ozlabs.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from MGW2.Sony.CO.JP ([137.153.0.14]:56699 "EHLO mgw2.sony.co.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751842AbXLMMG2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Dec 2007 07:06:28 -0500
In-Reply-To: <20071213181146.BF69.MOKUNO@sm.sony.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PS3: gelic: Fix the wrong dev_id passed

The device id for lv1_net_set_interrupt_status_indicator() would be wrong.
This path would be invoked only in the case of the initialization failure.

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

