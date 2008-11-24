From: Denis Joseph Barrow <D.Barow@option.com>
Subject: respin of patches for linux-2.6.28-rc6 hso_einval.patch [patch 3/6]
Date: Mon, 24 Nov 2008 15:44:22 +0100
Message-ID: <492ABDC6.90208@option.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060203090007030507010800"
To: Linux USB kernel mailing list <linux-usb@vger.kernel.org>,
	Linux netdev Mailing list <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer1.option.com ([81.246.70.162]:37167 "EHLO
	mailer1.option.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752687AbYKXOon (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2008 09:44:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------060203090007030507010800
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Added check for IFF_UP in hso_resume, this should eliminate -EINVAL (-22)
errors caused from urb's being submitted twice, once by hso_resume
& once in hso_net_open, if suspend/resume USB power saving  mode is enabled
Signed-off-by: Denis Joseph Barrow <D.Barow@option.com>
---
Index: linux-2.6.28-rc6.patches/drivers/net/usb/hso.c
===================================================================
--- linux-2.6.28-rc6.patches.orig/drivers/net/usb/hso.c	2008-11-24 14:10:15.000000000 +0100
+++ linux-2.6.28-rc6.patches/drivers/net/usb/hso.c	2008-11-24 14:19:17.000000000 +0100
@@ -2762,18 +2762,21 @@
 		if (network_table[i] &&
 		    (network_table[i]->interface == iface)) {
 			hso_net = dev2net(network_table[i]);
-			/* First transmit any lingering data, then restart the
-			 * device. */
-			if (hso_net->skb_tx_buf) {
-				dev_dbg(&iface->dev,
-					"Transmitting lingering data\n");
-				hso_net_start_xmit(hso_net->skb_tx_buf,
-						   hso_net->net);
-				hso_net->skb_tx_buf = NULL;
+			if (hso_net->flags & IFF_UP) {
+				/* First transmit any lingering data,
+				   then restart the device. */
+				if (hso_net->skb_tx_buf) {
+					dev_dbg(&iface->dev,
+						"Transmitting"
+						" lingering data\n");
+					hso_net_start_xmit(hso_net->skb_tx_buf,
+							   hso_net->net);
+					hso_net->skb_tx_buf = NULL;
+				}
+				result = hso_start_net_device(network_table[i]);
+				if (result)
+					goto out;
 			}
-			result = hso_start_net_device(network_table[i]);
-			if (result)
-				goto out;
 		}
 	}
 

-- 
best regards,
D.J. Barrow

--------------060203090007030507010800
Content-Type: text/x-diff;
 name="hso_einval.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="hso_einval.patch"

Added check for IFF_UP in hso_resume, this should eliminate -EINVAL (-22)
errors caused from urb's being submitted twice, once by hso_resume
& once in hso_net_open, if suspend/resume USB power saving  mode is enabled
Signed-off-by: Denis Joseph Barrow <D.Barow@option.com>
---
Index: linux-2.6.28-rc6.patches/drivers/net/usb/hso.c
===================================================================
--- linux-2.6.28-rc6.patches.orig/drivers/net/usb/hso.c	2008-11-24 14:10:15.000000000 +0100
+++ linux-2.6.28-rc6.patches/drivers/net/usb/hso.c	2008-11-24 14:19:17.000000000 +0100
@@ -2762,18 +2762,21 @@
 		if (network_table[i] &&
 		    (network_table[i]->interface == iface)) {
 			hso_net = dev2net(network_table[i]);
-			/* First transmit any lingering data, then restart the
-			 * device. */
-			if (hso_net->skb_tx_buf) {
-				dev_dbg(&iface->dev,
-					"Transmitting lingering data\n");
-				hso_net_start_xmit(hso_net->skb_tx_buf,
-						   hso_net->net);
-				hso_net->skb_tx_buf = NULL;
+			if (hso_net->flags & IFF_UP) {
+				/* First transmit any lingering data,
+				   then restart the device. */
+				if (hso_net->skb_tx_buf) {
+					dev_dbg(&iface->dev,
+						"Transmitting"
+						" lingering data\n");
+					hso_net_start_xmit(hso_net->skb_tx_buf,
+							   hso_net->net);
+					hso_net->skb_tx_buf = NULL;
+				}
+				result = hso_start_net_device(network_table[i]);
+				if (result)
+					goto out;
 			}
-			result = hso_start_net_device(network_table[i]);
-			if (result)
-				goto out;
 		}
 	}
 

--------------060203090007030507010800--
