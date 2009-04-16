From: Oliver Neukum <oliver@neukum.org>
Subject: [patch]handle EPERM in pegasus
Date: Thu, 16 Apr 2009 13:23:25 +0200
Message-ID: <200904161323.26443.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, petkan@users.sourceforge.net,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out002.kontent.com ([81.88.40.216]:55388 "EHLO
	smtp-out002.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753375AbZDPLXE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2009 07:23:04 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

EPERM means that disconnect() is runnung. It should be treated like
ENODEV

Signed-off-by: Oliver Neukum <oliver@neukum.org>

---

commit 7f5315f57f7f9d0834f23a3ad5b267c96a4a24c7
Author: Oliver Neukum <oneukum@linux-yyhs.site>
Date:   Tue Apr 7 09:48:24 2009 +0200

    handle disconnect error code in pegasus correctly

diff --git a/drivers/net/usb/pegasus.c b/drivers/net/usb/pegasus.c
index a8228d8..2138535 100644
--- a/drivers/net/usb/pegasus.c
+++ b/drivers/net/usb/pegasus.c
@@ -899,6 +899,7 @@ static int pegasus_start_xmit(struct sk_buff *skb, struct 
net_device *net)
 			/* cleanup should already have been scheduled */
 			break;
 		case -ENODEV:		/* disconnect() upcoming */
+		case -EPERM:
 			netif_device_detach(pegasus->net);
 			break;
 		default:


