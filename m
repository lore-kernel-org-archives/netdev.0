From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] net/tipc/port.c: fix NULL dereference
Date: Wed, 1 Nov 2006 01:40:37 +0100
Message-ID: <20061101004037.GZ27968@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tipc-discussion@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from emailhub.stusta.mhn.de ([141.84.69.5]:50962 "HELO
	mailout.stusta.mhn.de") by vger.kernel.org with SMTP
	id S1945956AbWKAAki (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Oct 2006 19:40:38 -0500
To: per.liden@ericsson.com, jon.maloy@ericsson.com,
	allan.stephens@windriver.com
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The correct order is: NULL check before dereference

Spotted by the Coverity checker.

Signed-off-by: Adrian Bunk <bunk@stusta.de>

--- linux-2.6/net/tipc/port.c.old	2006-11-01 00:37:58.000000000 +0100
+++ linux-2.6/net/tipc/port.c	2006-11-01 00:38:27.000000000 +0100
@@ -1136,11 +1136,12 @@
 	int res = -EINVAL;
 
 	p_ptr = tipc_port_lock(ref);
+	if (!p_ptr)
+		return -EINVAL;
+
 	dbg("tipc_publ %u, p_ptr = %x, conn = %x, scope = %x, "
 	    "lower = %u, upper = %u\n",
 	    ref, p_ptr, p_ptr->publ.connected, scope, seq->lower, seq->upper);
-	if (!p_ptr)
-		return -EINVAL;
 	if (p_ptr->publ.connected)
 		goto exit;
 	if (seq->lower > seq->upper)

