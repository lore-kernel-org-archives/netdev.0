From: Christian Riesch <christian.riesch@omicron.at>
Subject: [PATCH net-next] asix: Fix return value in AX88172A driver bind function
Date: Wed, 18 Jul 2012 12:56:52 +0200
Message-ID: <1342609012-3075-1-git-send-email-christian.riesch@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Christian Riesch <christian.riesch@omicron.at>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.omicron.at ([212.183.10.25]:48906 "EHLO ns.omicron.at"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753450Ab2GRK4D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Jul 2012 06:56:03 -0400
Received: from counter.omicron.at ([212.183.10.29])
	by ns.omicron.at (8.13.1/8.13.1) with ESMTP id q6IAtuGH000480
	for <netdev@vger.kernel.org>; Wed, 18 Jul 2012 12:56:01 +0200
Received: from mary.at.omicron.at (mary.at.omicron.at [172.22.100.48])
	by counter.omicron.at (8.14.4/8.14.4) with ESMTP id q6IAtu2R017056
	for <netdev@vger.kernel.org>; Wed, 18 Jul 2012 12:55:56 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Return -ENOTSUPP if the initialization fails because the
device is configured for a mode that is not supported by the driver.

Signed-off-by: Christian Riesch <christian.riesch@omicron.at>
---
 drivers/net/usb/ax88172a.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/usb/ax88172a.c b/drivers/net/usb/ax88172a.c
index 534a144..3d0f8fa 100644
--- a/drivers/net/usb/ax88172a.c
+++ b/drivers/net/usb/ax88172a.c
@@ -274,6 +274,7 @@ static int ax88172a_bind(struct usbnet *dev, struct usb_interface *intf)
 		break;
 	default:
 		netdev_err(dev->net, "Interface mode not supported by driver\n");
+		ret = -ENOTSUPP;
 		goto free;
 	}
 
-- 
1.7.0.4
