From: Dan Carpenter <error27@gmail.com>
Subject: [patch] nui.c error handling
Date: Wed, 8 Apr 2009 14:39:28 +0300 (EAT)
Message-ID: <alpine.DEB.2.00.0904081437400.32632@bicker>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.25]:34586 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932885AbZDHLns (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2009 07:43:48 -0400
Received: by qw-out-2122.google.com with SMTP id 8so56150qwh.37
        for <netdev@vger.kernel.org>; Wed, 08 Apr 2009 04:43:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

platform_device_register_simple() returns ERR_PTR(), not NULL, if an error 
occurs.

Found by smatch (http://repo.or.cz/w/smatch.git).  Compile tested.

regards,
dan carpenter

Signed-off-by: Dan Carpenter <error27@gmail.com>

--- orig/drivers/net/niu.c	2009-04-07 21:59:22.000000000 +0300
+++ devel/drivers/net/niu.c	2009-04-07 22:00:45.000000000 +0300
@@ -8757,7 +8757,7 @@
 
 	plat_dev = platform_device_register_simple("niu", niu_parent_index,
 						   NULL, 0);
-	if (!plat_dev)
+	if (IS_ERR(plat_dev))
 		return NULL;
 
 	for (i = 0; attr_name(niu_parent_attributes[i]); i++) {
