From: David Miller <davem@davemloft.net>
Subject: Fix net-2.6.22 on sparc
Date: Fri, 09 Mar 2007 16:24:04 -0800 (PST)
Message-ID: <20070309.162404.99202412.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44798
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1767686AbXCJAYF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Mar 2007 19:24:05 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Eric, please look at whole files you are editing :) I'm sure
there is probably another case like this or two in the
other platform socket ioctl allocations you made.

Thanks.

commit 9415518744729743b017da2e08a71c5bb0d94108
Author: David S. Miller <davem@sunset.davemloft.net>
Date:   Fri Mar 9 16:22:52 2007 -0800

    [NET]: Fix SO_TIMESTAMPNS values allocated to sparc.
    
    They confliced with SO_BROADCAST which already uses the
    value 0x0020.
    
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/include/asm-sparc/socket.h b/include/asm-sparc/socket.h
index d77768e..7c14239 100644
--- a/include/asm-sparc/socket.h
+++ b/include/asm-sparc/socket.h
@@ -49,7 +49,7 @@
 
 #define SO_PEERSEC		0x001e
 #define SO_PASSSEC		0x001f
-#define SO_TIMESTAMPNS		0x0020
+#define SO_TIMESTAMPNS		0x0021
 #define SCM_TIMESTAMPNS		SO_TIMESTAMPNS
 
 /* Security levels - as per NRL IPv6 - don't actually do anything */
diff --git a/include/asm-sparc64/socket.h b/include/asm-sparc64/socket.h
index 1bd9f52..986441d 100644
--- a/include/asm-sparc64/socket.h
+++ b/include/asm-sparc64/socket.h
@@ -49,7 +49,7 @@
 
 #define SO_PEERSEC		0x001e
 #define SO_PASSSEC		0x001f
-#define SO_TIMESTAMPNS		0x0020
+#define SO_TIMESTAMPNS		0x0021
 #define SCM_TIMESTAMPNS		SO_TIMESTAMPNS
 
 /* Security levels - as per NRL IPv6 - don't actually do anything */
