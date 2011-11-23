From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] isdn: avoid copying too long drvid
Date: Wed, 23 Nov 2011 09:43:46 +0300
Message-ID: <20111123064345.GB6871@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Lucas De Marchi <lucas.demarchi@profusion.mobi>,
	Neil Horman <nhorman@tuxdriver.com>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Karsten Keil <isdn@linux-pingi.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet15.oracle.com ([148.87.113.117]:29223 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753048Ab1KWGoT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2011 01:44:19 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"cfg->drvid" comes from the user so there is a possibility they
didn't NUL terminate properly.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/isdn/i4l/isdn_net.c b/drivers/isdn/i4l/isdn_net.c
index 1f73d7f..487d214 100644
--- a/drivers/isdn/i4l/isdn_net.c
+++ b/drivers/isdn/i4l/isdn_net.c
@@ -2756,6 +2756,8 @@ isdn_net_setcfg(isdn_net_ioctl_cfg * cfg)
 			char *c,
 			*e;
 
+			if (strlen(cfg->drvid) >= sizeof(drvid))
+				return -EINVAL;
 			drvidx = -1;
 			chidx = -1;
 			strcpy(drvid, cfg->drvid);
