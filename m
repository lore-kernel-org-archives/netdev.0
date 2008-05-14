From: akpm@linux-foundation.org
Subject: [patch 10/11] rndis_host: increase delay in command response loop
Date: Wed, 14 May 2008 16:20:16 -0700
Message-ID: <200805142320.m4ENKGnk026640@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	linkfanel@yahoo.fr, davem@davemloft.net, david-b@pacbell.net,
	greg@kroah.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:41006 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754575AbYENXU7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2008 19:20:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pierre Ynard <linkfanel@yahoo.fr>

Some devices running some WinCE firmware (with SC_* Samsung processors
according to the SynCE project, verified on a HTC P3600 device) fail to
register because they apparently need extra time to respond correctly to
requests.  Increase the existing delay to satisfy them.  Based on code
from the SynCE project, on a suggestion of David Brownell.

This patch Works For Me(tm).

Signed-off-by: Pierre Ynard <linkfanel@yahoo.fr>
Acked-by: David Brownell <david-b@pacbell.net>
Cc: Greg KH <greg@kroah.com>
Cc: Jeff Garzik <jeff@garzik.org>
Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/usb/rndis_host.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN drivers/net/usb/rndis_host.c~rndis_host-increase-delay-in-command-response-loop drivers/net/usb/rndis_host.c
--- a/drivers/net/usb/rndis_host.c~rndis_host-increase-delay-in-command-response-loop
+++ a/drivers/net/usb/rndis_host.c
@@ -194,7 +194,7 @@ int rndis_command(struct usbnet *dev, st
 			dev_dbg(&info->control->dev,
 				"rndis response error, code %d\n", retval);
 		}
-		msleep(2);
+		msleep(20);
 	}
 	dev_dbg(&info->control->dev, "rndis response timeout\n");
 	return -ETIMEDOUT;
_
