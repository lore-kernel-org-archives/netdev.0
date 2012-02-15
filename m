From: Toby Gray <toby.gray@realvnc.com>
Subject: [PATCH 5/5] usb: cdc-ncm: Allow NCM driver to determine dev->maxpacket
Date: Wed, 15 Feb 2012 14:47:41 +0000
Message-ID: <1329317261-3406-6-git-send-email-toby.gray@realvnc.com>
References: <1329317261-3406-1-git-send-email-toby.gray@realvnc.com>
Cc: netdev@vger.kernel.org, alexey.orishko@gmail.com,
	Toby Gray <toby.gray@realvnc.com>
To: Toby Gray <tg@realvnc.com>, Oliver Neukum <oliver@neukum.name>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	linux-usb@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from realvnc.com ([146.101.152.142]:53036 "EHLO realvnc.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759233Ab2BOOsA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Feb 2012 09:48:00 -0500
In-Reply-To: <1329317261-3406-1-git-send-email-toby.gray@realvnc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As the NCM driver does not necessarily select the alternate setting
which presents the data bulk endpoints, dev->maxpacket can't be set
correctly by usbnet.

This fixes this by getting the NCM driver to set the dev->maxpacket itself.

Signed-off-by: Toby Gray <toby.gray@realvnc.com>
---
 drivers/net/usb/cdc_ncm.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index e1b2d5d..158c3d8 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -600,6 +600,7 @@ advance:
 		ctx->out_ep->desc.bEndpointAddress & USB_ENDPOINT_NUMBER_MASK);
 	dev->status = ctx->status_ep;
 	dev->rx_urb_size = ctx->rx_max;
+	dev->maxpacket = usb_endpoint_maxp(&ctx->out_ep->desc);
 
 	/*
 	 * We should get an event when network connection is "connected" or
-- 
1.7.0.4
