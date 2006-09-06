From: Dirk Opfer <Dirk@Opfer-Online.de>
Subject: Re: [PATCH] Fix dm9000 release_resource
Date: Wed, 06 Sep 2006 19:53:32 +0200
Message-ID: <0ML29c-1GL1WY3G6t-0008TQ@mrelayeu.kundenserver.de>
References: <0ML25U-1GIK892FsT-0007pS@mrelayeu.kundenserver.de> <44FEE224.7030904@garzik.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030202040108050609020606"
Cc: netdev@vger.kernel.org, Ben Dooks <ben@simtec.co.uk>,
	Sascha Hauer <s.hauer@pengutronix.de>, dirk@opfer-online.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.187]:12792 "EHLO
	moutng.kundenserver.de") by vger.kernel.org with ESMTP
	id S1751228AbWIFRtU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Sep 2006 13:49:20 -0400
To: Jeff Garzik <jeff@garzik.org>
In-Reply-To: <44FEE224.7030904@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030202040108050609020606
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Jeff Garzik schrieb:
>
> Your patch is attached base64-encoded, which makes it impossible to
> comment on it inline.
>
>     Jeff
>
>
Sorry for that. I send this via webclient.

Here is another attempt.

dm9000_release_board calls release_resource with the platform resource
instead of the requested resource:

db->addr_res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
db->addr_req = request_mem_region(db->addr_res->start, i, pdev->name);

dm9000_release_board:

if (db->addr_res != NULL) {
release_resource(db->addr_res);
kfree(db->addr_req);

With this behavior the kernel will crash on the second removal. The
attached patch fix this problem.


Signed-off-by: Dirk Opfer <Dirk@Opfer-Online.de>


Dirk

--------------030202040108050609020606
Content-Type: text/plain;
 name="dm9000-fix-release-ressource.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="dm9000-fix-release-ressource.patch"

diff --git a/drivers/net/dm9000.c b/drivers/net/dm9000.c
index 3d76fa1..a860ebb 100644
--- a/drivers/net/dm9000.c
+++ b/drivers/net/dm9000.c
@@ -377,8 +377,8 @@ dm9000_release_board(struct platform_dev
 		kfree(db->data_req);
 	}
 
-	if (db->addr_res != NULL) {
-		release_resource(db->addr_res);
+	if (db->addr_req != NULL) {
+		release_resource(db->addr_req);
 		kfree(db->addr_req);
 	}
 }

--------------030202040108050609020606--
