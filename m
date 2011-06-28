From: maksim.rayskiy@gmail.com
Subject: [RFC PATCH] asix: drop rx skb if header length is invalid
Date: Tue, 28 Jun 2011 14:21:31 -0700
Message-ID: <1309296091-31476-1-git-send-email-maksim.rayskiy@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Maksim Rayskiy" <mrayskiy@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2253 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751296Ab1F1VVz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Jun 2011 17:21:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Maksim Rayskiy <mrayskiy@broadcom.com>

Signed-off-by: Maksim Rayskiy <mrayskiy@broadcom.com>
---

I am using AX88772 usbnet dongle, and sometimes after system resume I am seeing 
corrupt rx packets which generate infinite number of 
asix_rx_fixup() Bad Header Length
messages.
Looking at asix_rx_fixup() I see that depending on what junk you get in skb you
may end up with never breaking the while loop. Would not it be safer to bail out
as soon as incorrect header length was detected?

 drivers/net/usb/asix.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/usb/asix.c b/drivers/net/usb/asix.c
index 6998aa6..9d7a6ec 100644
--- a/drivers/net/usb/asix.c
+++ b/drivers/net/usb/asix.c
@@ -317,6 +317,7 @@ static int asix_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 		if ((short)(header & 0x0000ffff) !=
 		    ~((short)((header & 0xffff0000) >> 16))) {
 			netdev_err(dev->net, "asix_rx_fixup() Bad Header Length\n");
+			return 0;
 		}
 		/* get the packet length */
 		size = (u16) (header & 0x0000ffff);
-- 
1.7.4.1


