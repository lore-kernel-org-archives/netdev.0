From: Nicolas DICHTEL <nicolas.dichtel@6wind.com>
Subject: [PATCH][NET]: fix dummy initialization
Date: Thu, 20 Jul 2006 17:27:33 +0200
Message-ID: <44BFA0E5.5040502@6wind.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080607040702080500060404"
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail01.net-streams.fr ([62.23.133.110]:29196 "EHLO
	net-streams.fr") by vger.kernel.org with ESMTP id S1030335AbWGTPYY
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Jul 2006 11:24:24 -0400
To: netdev <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------080607040702080500060404
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Same problem and same fix that for IFB.

Regards,
Nicolas


[NET][DUMMY] Avoid an oops when dummy_init_one() failed

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

--------------080607040702080500060404
Content-Type: text/x-patch;
 name="x.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x.diff"

--- a/drivers/net/dummy.c	2006-07-20 16:19:09.395351558 +0200
+++ b/drivers/net/dummy.c	2006-07-20 16:19:58.802327279 +0200
@@ -132,6 +132,7 @@
 	for (i = 0; i < numdummies && !err; i++)
 		err = dummy_init_one(i); 
 	if (err) { 
+		i--;
 		while (--i >= 0)
 			dummy_free_one(i);
 	}

--------------080607040702080500060404--
