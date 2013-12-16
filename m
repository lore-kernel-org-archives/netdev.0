From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] isdn: use strlcpy() instead strcpy()
Date: Mon, 16 Dec 2013 12:46:26 +0300
Message-ID: <20131216094626.GC13831@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Karsten Keil <isdn@linux-pingi.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:25484 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752301Ab3LPJqx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 04:46:53 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I don't think the in-kernel drivers ever hit this strcpy() so this
doesn't change how the code works.  But strcpy() is safer.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/isdn/sc/event.c b/drivers/isdn/sc/event.c
index 717003a3bdf4..833d96c2cf92 100644
--- a/drivers/isdn/sc/event.c
+++ b/drivers/isdn/sc/event.c
@@ -57,7 +57,7 @@ int indicate_status(int card, int event, ulong Channel, char *Data)
 			memcpy(&cmd.parm.setup, Data, sizeof(cmd.parm.setup));
 			break;
 		default:
-			strcpy(cmd.parm.num, Data);
+			strlcpy(cmd.parm.num, Data, sizeof(cmd.parm.num));
 		}
 	}
 
