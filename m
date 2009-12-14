From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] sky2: print Optima chip name
Date: Mon, 14 Dec 2009 10:33:47 -0800
Message-ID: <20091214103347.691d7f3d@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:56195 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753049AbZLNSdy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Dec 2009 13:33:54 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Off by one in name lookup makes Optima display as (chip 0xbc)

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/sky2.c	2009-12-11 11:09:34.515284818 -0800
+++ b/drivers/net/sky2.c	2009-12-11 11:11:58.621253981 -0800
@@ -4530,7 +4530,7 @@ static const char *sky2_name(u8 chipid, 
 		"Optima",	/* 0xbc */
 	};
 
-	if (chipid >= CHIP_ID_YUKON_XL && chipid < CHIP_ID_YUKON_OPT)
+	if (chipid >= CHIP_ID_YUKON_XL && chipid <= CHIP_ID_YUKON_OPT)
 		strncpy(buf, name[chipid - CHIP_ID_YUKON_XL], sz);
 	else
 		snprintf(buf, sz, "(chip %#x)", chipid);
