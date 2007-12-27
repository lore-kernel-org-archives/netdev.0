From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: [PATCH net-2.6.25] CAN: Fix plain integer definitions in userspace
 header & new CAN version 20071227
Date: Thu, 27 Dec 2007 21:14:57 +0100
Message-ID: <477407C1.1050405@hartkopp.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090004090901040507060806"
Cc: Sam Ravnborg <sam@ravnborg.org>,
	Urs Thuermann <urs@isnogud.escape.de>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cg-p07-fb.rzone.de ([81.169.146.215]:33071 "EHLO
	cg-p07-fb.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752068AbXL0UQs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Dec 2007 15:16:48 -0500
Received: from mo-p00-ob.rzone.de (klopstock-mo-p00-ob.mail [192.168.63.66])
	by charnel-fb-04.store (RZmta 14.0) with ESMTP id R00205jBRDS1OA
	for <netdev@vger.kernel.org>; Thu, 27 Dec 2007 21:16:47 +0100 (MET)
	(envelope-from: <oliver@hartkopp.net>)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------090004090901040507060806
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This patch fixes the use of plain integers instead of __u32 in a struct 
that is visible from kernel space and user space. As this change is user 
visible this patch also updates the CAN version to 20071227.

Thanks to Sam Ravnborg for pointing out the wrong plain int usage.

It applies on the current net-2.6.25 tree.

Tnx & best regards,
Oliver

Signed-off-by: Oliver Hartkopp <oliver@hartkopp.net>
Acked-by: Sam Ravnborg <sam@ravnborg.org>
---


--------------090004090901040507060806
Content-Type: text/x-diff;
 name="plain_int.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="plain_int.patch"

diff -uprN -X net-2.6.25/Documentation/dontdiff net-2.6.25/include/linux/can/bcm.h export/net2625-2007-12-27/include/linux/can/bcm.h
--- net-2.6.25/include/linux/can/bcm.h	2007-12-15 19:33:20.000000000 +0100
+++ export/net2625-2007-12-27/include/linux/can/bcm.h	2007-12-27 20:35:54.000000000 +0100
@@ -26,12 +26,12 @@
  * @frames:    array of CAN frames.
  */
 struct bcm_msg_head {
-	int opcode;
-	int flags;
-	int count;
+	__u32 opcode;
+	__u32 flags;
+	__u32 count;
 	struct timeval ival1, ival2;
 	canid_t can_id;
-	int nframes;
+	__u32 nframes;
 	struct can_frame frames[0];
 };
 
diff -uprN -X net-2.6.25/Documentation/dontdiff net-2.6.25/include/linux/can/core.h export/net2625-2007-12-27/include/linux/can/core.h
--- net-2.6.25/include/linux/can/core.h	2007-12-15 19:33:20.000000000 +0100
+++ export/net2625-2007-12-27/include/linux/can/core.h	2007-12-27 20:35:54.000000000 +0100
@@ -19,7 +19,7 @@
 #include <linux/skbuff.h>
 #include <linux/netdevice.h>
 
-#define CAN_VERSION "20071116"
+#define CAN_VERSION "20071227"
 
 /* increment this number each time you change some user-space interface */
 #define CAN_ABI_VERSION "8"

--------------090004090901040507060806--
