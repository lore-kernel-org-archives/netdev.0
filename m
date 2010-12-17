From: Dan Carpenter <error27@gmail.com>
Subject: [patch] USB: mcs7830: return negative if auto negotiate fails
Date: Fri, 17 Dec 2010 16:25:43 +0300
Message-ID: <20101217132542.GL1639@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Greg Kroah-Hartman <gregkh@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:46695 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754656Ab0LQN0J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Dec 2010 08:26:09 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The original code returns 0 on success and 1 on failure.  In fact, at
this point, "ret" is already either zero or a negative error code so
we can just return it directly.

Signed-off-by: Dan Carpenter <error27@gmail.com>

diff --git a/drivers/net/usb/mcs7830.c b/drivers/net/usb/mcs7830.c
index a6281e3..f3fe8e1 100644
--- a/drivers/net/usb/mcs7830.c
+++ b/drivers/net/usb/mcs7830.c
@@ -351,7 +351,7 @@ static int mcs7830_set_autoneg(struct usbnet *dev, int ptrUserPhyMode)
 	if (!ret)
 		ret = mcs7830_write_phy(dev, MII_BMCR,
 				BMCR_ANENABLE | BMCR_ANRESTART	);
-	return ret < 0 ? : 0;
+	return ret;
 }
 
 
