From: Ian Coolidge <iancoolidge@gmail.com>
Subject: [PATCH 1/2] usb: gadget: g_ether: fix frame size check
Date: Tue,  6 Nov 2012 13:00:10 -0800
Message-ID: <1352235611-13066-2-git-send-email-iancoolidge@gmail.com>
References: <1352235611-13066-1-git-send-email-iancoolidge@gmail.com>
Cc: Ian Coolidge <iancoolidge@gmail.com>
To: Oliver Neukum <oliver@neukum.name>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Felipe Balbi <balbi@ti.com>, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:58457 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751870Ab2KFU7V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Nov 2012 15:59:21 -0500
In-Reply-To: <1352235611-13066-1-git-send-email-iancoolidge@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Checking skb->len against ETH_FRAME_LEN assumes a 1514
ethernet frame size. With an 802.1Q VLAN header, ethernet
frame length can now be 1518. Validate frame length against that.

Signed-off-by: Ian Coolidge <iancoolidge@gmail.com>
---
 drivers/usb/gadget/u_ether.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/usb/gadget/u_ether.c b/drivers/usb/gadget/u_ether.c
index 29c854b..ff2c70b 100644
--- a/drivers/usb/gadget/u_ether.c
+++ b/drivers/usb/gadget/u_ether.c
@@ -19,6 +19,7 @@
 #include <linux/ctype.h>
 #include <linux/etherdevice.h>
 #include <linux/ethtool.h>
+#include <linux/if_vlan.h>
 
 #include "u_ether.h"
 
@@ -301,7 +302,7 @@ static void rx_complete(struct usb_ep *ep, struct usb_request *req)
 		while (skb2) {
 			if (status < 0
 					|| ETH_HLEN > skb2->len
-					|| skb2->len > ETH_FRAME_LEN) {
+					|| skb2->len > VLAN_ETH_FRAME_LEN) {
 				dev->net->stats.rx_errors++;
 				dev->net->stats.rx_length_errors++;
 				DBG(dev, "rx length %d\n", skb2->len);
-- 
1.7.6.5
