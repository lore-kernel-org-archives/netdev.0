From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch iproute2 1/3] iproute2: arpd: use ll_addr_a2n and ll_addr_n2a
Date: Thu, 15 May 2014 15:10:20 +0200
Message-ID: <1400159422-11797-2-git-send-email-jiri@resnulli.us>
References: <1400159422-11797-1-git-send-email-jiri@resnulli.us>
Cc: stephen@networkplumber.org, mschmidt@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f51.google.com ([209.85.215.51]:46099 "EHLO
	mail-la0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751497AbaEONKc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2014 09:10:32 -0400
Received: by mail-la0-f51.google.com with SMTP id gf5so782870lab.10
        for <netdev@vger.kernel.org>; Thu, 15 May 2014 06:10:30 -0700 (PDT)
In-Reply-To: <1400159422-11797-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 misc/arpd.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/misc/arpd.c b/misc/arpd.c
index bfe7de9..0839e3f 100644
--- a/misc/arpd.c
+++ b/misc/arpd.c
@@ -36,6 +36,7 @@
 
 #include "libnetlink.h"
 #include "utils.h"
+#include "rt_names.h"
 
 int resolve_hosts;
 
@@ -721,8 +722,7 @@ int main(int argc, char **argv)
 				goto do_abort;
 			}
 
-			dbdat.data = hexstring_a2n(macbuf, b1, 6);
-			if (dbdat.data == NULL)
+			if (ll_addr_a2n((char *) b1, 6, macbuf) != 6)
 				goto do_abort;
 			dbdat.size = 6;
 
@@ -747,7 +747,7 @@ int main(int argc, char **argv)
 					printf("%-8d %-15s %s\n",
 					       key->iface,
 					       inet_ntoa(*(struct in_addr*)&key->addr),
-					       hexstring_n2a(dbdat.data, 6, b1, 18));
+					       ll_addr_n2a(dbdat.data, 6, ARPHRD_ETHER, b1, 18));
 				} else {
 					printf("%-8d %-15s FAILED: %dsec ago\n",
 					       key->iface,
-- 
1.9.0
