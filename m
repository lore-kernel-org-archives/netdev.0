From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] isdn: icn: use strlcpy() when parsing setup options
Date: Sun, 15 Mar 2015 13:48:03 +0300
Message-ID: <20150315104803.GA20691@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Karsten Keil <isdn@linux-pingi.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:37545 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751856AbbCOKsV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Mar 2015 06:48:21 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If you pass an invalid string here then you probably deserve the memory
corruption, but it annoys static analysis tools so lets fix it.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/isdn/icn/icn.c b/drivers/isdn/icn/icn.c
index 6a7447c..358a574 100644
--- a/drivers/isdn/icn/icn.c
+++ b/drivers/isdn/icn/icn.c
@@ -1609,7 +1609,7 @@ icn_setup(char *line)
 	if (ints[0] > 1)
 		membase = (unsigned long)ints[2];
 	if (str && *str) {
-		strcpy(sid, str);
+		strlcpy(sid, str, sizeof(sid));
 		icn_id = sid;
 		if ((p = strchr(sid, ','))) {
 			*p++ = 0;
