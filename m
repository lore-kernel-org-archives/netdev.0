From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH net-next] sctp: Clean up TEST_FRAME hacks.
Date: Thu, 19 Mar 2009 17:43:03 -0400
Message-ID: <49C2BC67.8030709@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, linux-sctp@vger.kernel.org
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0006.atlanta.hp.com ([15.192.0.43]:33092 "EHLO
	g5t0006.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753947AbZCSVnH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2009 17:43:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove 2 TEST_FRAME hacks that are no longer needed.  These allowed
sctp regression tests to compile before, but are no longer needed.

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 include/net/sctp/sctp.h |    7 -------
 net/sctp/output.c       |    5 +----
 2 files changed, 1 insertions(+), 11 deletions(-)

diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
index 9e226be..9f80a76 100644
--- a/include/net/sctp/sctp.h
+++ b/include/net/sctp/sctp.h
@@ -62,13 +62,6 @@
  *   and will continue to evolve.
  */

-
-
-#ifdef TEST_FRAME
-#undef CONFIG_SCTP_DBG_OBJCNT
-#undef CONFIG_SYSCTL
-#endif /* TEST_FRAME */
-
 #include <linux/types.h>
 #include <linux/slab.h>
 #include <linux/in.h>
diff --git a/net/sctp/output.c b/net/sctp/output.c
index 07d5890..7d08f52 100644
--- a/net/sctp/output.c
+++ b/net/sctp/output.c
@@ -49,13 +49,10 @@
 #include <linux/ipv6.h>
 #include <linux/init.h>
 #include <net/inet_ecn.h>
+#include <net/ip.h>
 #include <net/icmp.h>
 #include <net/net_namespace.h>

-#ifndef TEST_FRAME
-#include <net/tcp.h>
-#endif /* TEST_FRAME (not defined) */
-
 #include <linux/socket.h> /* for sa_family_t */
 #include <net/sock.h>

-- 
1.5.4.3

