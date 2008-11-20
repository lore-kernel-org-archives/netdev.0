From: David Hollis <dhollis@davehollis.com>
Subject: [RESEND] [PATCH] asix.c: Fix AX88178 connectivity with 10/100 networks
Date: Thu, 20 Nov 2008 10:25:41 -0500
Message-ID: <1227194741.4420.37.camel@dhollis-lnx>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-lBxgp/BPbsGUcZZ0Ok09"
Cc: netdev@vger.kernel.org, pktoss@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vms173003pub.verizon.net ([206.46.173.3]:36632 "EHLO
	vms173003pub.verizon.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754869AbYKTPZ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2008 10:25:57 -0500
Received: from smtp.davehollis.com ([96.228.138.81]) by vms173003.mailsrvcs.net
 (Sun Java System Messaging Server 6.2-6.01 (built Apr  3 2006))
 with ESMTPA id <0KAN00FX41IYWG80@vms173003.mailsrvcs.net> for
 netdev@vger.kernel.org; Thu, 20 Nov 2008 09:25:46 -0600 (CST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-lBxgp/BPbsGUcZZ0Ok09
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Add AX_MEDIUM_ENCK also when speed = 10/100Mbps.  This makes the Belkin
F5D5055 device work properly.

Signed-off-by: Pantelis Koukousoulas <pktoss@gmail.com>
Acked-by: David Hollis <dhollis@davehollis.com>

--=-lBxgp/BPbsGUcZZ0Ok09
Content-Description: 
Content-Disposition: inline; filename="asix.c-enck.diff"
Content-Type: text/x-patch; charset="UTF-8"
Content-Transfer-Encoding: 7bit

--- a/drivers/net/usb/asix.c	2008-11-20 09:50:04.000000000 -0500
+++ b/drivers/net/usb/asix.c	2008-11-20 09:50:36.000000000 -0500
@@ -1102,12 +1102,14 @@ static int ax88178_link_reset(struct usb
 	mode = AX88178_MEDIUM_DEFAULT;
 
 	if (ecmd.speed == SPEED_1000)
-		mode |= AX_MEDIUM_GM | AX_MEDIUM_ENCK;
+		mode |= AX_MEDIUM_GM;
 	else if (ecmd.speed == SPEED_100)
 		mode |= AX_MEDIUM_PS;
 	else
 		mode &= ~(AX_MEDIUM_PS | AX_MEDIUM_GM);
 
+	mode |= AX_MEDIUM_ENCK;
+
 	if (ecmd.duplex == DUPLEX_FULL)
 		mode |= AX_MEDIUM_FD;
 	else

--=-lBxgp/BPbsGUcZZ0Ok09--

