From: David Brownell <david-b@pacbell.net>
Subject: [patch 2.6.26-rc1-git] rndis_host:  longer timeout (bugzilla 10590)
Date: Sat, 10 May 2008 22:54:38 -0700
Message-ID: <200805102254.38665.david-b@pacbell.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Pierre Ynard <linkfanel@yahoo.fr>
To: Network development list <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp122.sbc.mail.sp1.yahoo.com ([69.147.64.95]:25879 "HELO
	smtp122.sbc.mail.sp1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750920AbYEKFyq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 May 2008 01:54:46 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pierre Ynard <linkfanel@yahoo.fr>

Some devices running some WinCE firmware (with SC_* Samsung processors
according to the SynCE project, verified on a HTC P3600 device) fail to
register because they apparently need extra time to respond correctly
to requests. Increase the existing delay to satisfy them. Based on code
from the SynCE project, on a suggestion of David Brownell.

This patch Works For Me(tm).

  Resoves:  http://bugzilla.kernel.org/show_bug.cgi?id=10590

Signed-off-by: Pierre Ynard <linkfanel@yahoo.fr>
Signed-off-by: David Brownell <dbrownell@users.sourceforge.net>

--- a/drivers/net/usb/rndis_host.c
+++ b/drivers/net/usb/rndis_host.c
@@ -194,7 +194,7 @@ int rndis_command(struct usbnet *dev, struct rndis_msg_hdr *buf)
 			dev_dbg(&info->control->dev,
 				"rndis response error, code %d\n", retval);
 		}
-		msleep(2);
+		msleep(20);
 	}
 	dev_dbg(&info->control->dev, "rndis response timeout\n");
 	return -ETIMEDOUT;


