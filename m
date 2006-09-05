From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] bridge: random extra bytes on STP TCN packet
Date: Tue, 5 Sep 2006 09:59:07 -0700
Message-ID: <20060905095907.3d3c58f7@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bridge@osdl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:45712 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932150AbWIEQ7X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Sep 2006 12:59:23 -0400
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We seem to send 3 extra bytes in a TCN, which will be whatever happens
to be on the stack. Thanks to Aji_Srinivas@emc.com for seeing.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Naur a/net/bridge/br_stp_bpdu.c b/net/bridge/br_stp_bpdu.c
--- a/net/bridge/br_stp_bpdu.c	2006-09-03 23:40:08.000000000 +0530
+++ b/net/bridge/br_stp_bpdu.c	2006-09-03 23:40:33.000000000 +0530
@@ -121,7 +121,7 @@
 	buf[1] = 0;
 	buf[2] = 0;
 	buf[3] = BPDU_TYPE_TCN;
-	br_send_bpdu(p, buf, 7);
+	br_send_bpdu(p, buf, 4);
 }
 
 /*

