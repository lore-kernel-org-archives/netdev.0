From: Petko Manolov <petkan@mip-labs.com>
Subject: [PATCH v3 2/2] pegasus: fixes reported packet length
Date: Wed, 27 Apr 2016 14:24:50 +0300
Message-ID: <1461756290-27421-3-git-send-email-petkan@mip-labs.com>
References: <1461756290-27421-1-git-send-email-petkan@mip-labs.com>
Cc: davem@davemloft.net, a1291762@gmail.com, johannes@sipsolutions.net,
	Petko Manolov <petkan@mip-labs.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lan.nucleusys.com ([92.247.61.126]:42502 "EHLO
	zztop.nucleusys.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751866AbcD0LY7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2016 07:24:59 -0400
In-Reply-To: <1461756290-27421-1-git-send-email-petkan@mip-labs.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The default Pegasus setup was to append the status and CRC at the end of each
received packet.  The status bits are used to update various stats, but CRC has
been ignored.  The new default is to not append CRC at the end of RX packets.

Signed-off-by: Petko Manolov <petkan@mip-labs.com>
---
 drivers/net/usb/pegasus.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/usb/pegasus.c b/drivers/net/usb/pegasus.c
index f919e20..82129ee 100644
--- a/drivers/net/usb/pegasus.c
+++ b/drivers/net/usb/pegasus.c
@@ -411,7 +411,7 @@ static int enable_net_traffic(struct net_device *dev, struct usb_device *usb)
 	int ret;
 
 	read_mii_word(pegasus, pegasus->phy, MII_LPA, &linkpart);
-	data[0] = 0xc9;
+	data[0] = 0xc8; /* TX & RX enable, append status, no CRC */
 	data[1] = 0;
 	if (linkpart & (ADVERTISE_100FULL | ADVERTISE_10FULL))
 		data[1] |= 0x20;	/* set full duplex */
@@ -497,7 +497,7 @@ static void read_bulk_callback(struct urb *urb)
 		pkt_len = buf[count - 3] << 8;
 		pkt_len += buf[count - 4];
 		pkt_len &= 0xfff;
-		pkt_len -= 8;
+		pkt_len -= 4;
 	}
 
 	/*
-- 
2.8.0.rc3
