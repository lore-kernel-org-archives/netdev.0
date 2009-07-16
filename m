From: Vincent CUISSARD <vincent.cuissard@gmail.com>
Subject: [PATCH] cdc-eem: bad crc checking
Date: Thu, 16 Jul 2009 18:08:58 +0200
Message-ID: <5ca532980907160908k3c18fd16k18e17f92a18de5a8@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f226.google.com ([209.85.219.226]:35911 "EHLO
	mail-ew0-f226.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932526AbZGPQI7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jul 2009 12:08:59 -0400
Received: by ewy26 with SMTP id 26so244233ewy.37
        for <netdev@vger.kernel.org>; Thu, 16 Jul 2009 09:08:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the driver received an EEM packet with CRC option enabled, driver must
compute and check the CRC of the Ethernet data. Previous version computes CRC
on Ethernet data plus the original CRC value. Skbuff is correctly trimed but
the old length is used when CRC is computed.


Signed-off-by: Vincent CUISSARD <vincent.cuissard@gmail.com>
---
 drivers/net/usb/cdc_eem.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/usb/cdc_eem.c b/drivers/net/usb/cdc_eem.c
index 80e0177..b9e7162 100644
--- a/drivers/net/usb/cdc_eem.c
+++ b/drivers/net/usb/cdc_eem.c
@@ -311,7 +311,7 @@ static int eem_rx_fixup(struct usbnet *dev, struct
sk_buff *skb)
 			 *	bmCRC = 0	: CRC = 0xDEADBEEF
 			 */
 			if (header & BIT(14))
-				crc2 = ~crc32_le(~0, skb2->data, len);
+				crc2 = ~crc32_le(~0, skb2->data, skb2->len);
 			else
 				crc2 = 0xdeadbeef;
