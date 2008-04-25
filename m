From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] tg3 : sparse cleanup
Date: Fri, 25 Apr 2008 08:31:35 +0200
Message-ID: <48117AC7.40507@cosmosbay.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010404050904040801090904"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2f.orange.fr ([80.12.242.152]:4023 "EHLO smtp2f.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756468AbYDYGbu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Apr 2008 02:31:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------010404050904040801090904
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Fix the following sparse warning :

drivers/net/tg3.c:4025:3: warning: context imbalance in 'tg3_restart_hw' 
- unexpected unlock

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>



--------------010404050904040801090904
Content-Type: text/plain;
 name="tg3.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="tg3.patch"

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index bc4c62b..e3f74c9 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -4017,6 +4017,8 @@ static int tg3_halt(struct tg3 *, int, int);
  * Invoked with tp->lock held.
  */
 static int tg3_restart_hw(struct tg3 *tp, int reset_phy)
+	__releases(tp->lock)
+	__acquires(tp->lock)
 {
 	int err;
 

--------------010404050904040801090904--


