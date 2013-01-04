From: Dan Williams <dcbw@redhat.com>
Subject: [PATCH 2/2] sierra_net: keep status interrupt URB active over
 netdev open/close
Date: Fri, 04 Jan 2013 10:51:29 -0600
Message-ID: <1357318289.5370.19.camel@dcbw.foobar.com>
References: <20110727141246.GC29616@orbit.nwl.cc>
	 <1357318096.5370.15.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Elina Pasheva <epasheva@sierrawireless.com>,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	Rory Filer <rfiler@sierrawireless.com>,
	Phil Sutter <phil@nwl.cc>
To: Oliver Neukum <oliver@neukum.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:22424 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754952Ab3ADQtL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Jan 2013 11:49:11 -0500
In-Reply-To: <1357318096.5370.15.camel@dcbw.foobar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver and firmware sync up through SYNC messages, and the
firmware's affirmative reply to these SYNC messages appears to be the
"Reset" indication received via the status interrupt endpoint.  Thus the
driver needs the status interrupt endpoint always active so that the
Reset indication can be received even if the netdev is closed, which is
the case right after device insertion.

Signed-off-by: Dan Williams <dcbw@redhat.com>
---
diff --git a/drivers/net/usb/sierra_net.c b/drivers/net/usb/sierra_net.c
index 18dd425..e6e2857 100644
--- a/drivers/net/usb/sierra_net.c
+++ b/drivers/net/usb/sierra_net.c
@@ -905,7 +905,7 @@ static struct sk_buff *sierra_net_tx_fixup(struct usbnet *dev,
 
 static const struct driver_info sierra_net_info_direct_ip = {
 	.description = "Sierra Wireless USB-to-WWAN Modem",
-	.flags = FLAG_WWAN | FLAG_SEND_ZLP,
+	.flags = FLAG_WWAN | FLAG_SEND_ZLP | FLAG_INTR_ALWAYS,
 	.bind = sierra_net_bind,
 	.unbind = sierra_net_unbind,
 	.status = sierra_net_status,
