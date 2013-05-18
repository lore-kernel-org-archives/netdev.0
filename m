From: Andreas Henriksson <andreas@fatal.se>
Subject: [PATCH] iproute2: fix build failure on sparc due to -Wformat and
 tv_usec
Date: Sat, 18 May 2013 18:18:51 +0200
Message-ID: <20130518161850.GA16019@amd64.fatal.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay-h21.telenor.se ([195.54.99.196]:33258 "EHLO
	smtprelay-h21.telenor.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752399Ab3ERQqG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 May 2013 12:46:06 -0400
Received: from ipb1.telenor.se (ipb1.telenor.se [195.54.127.164])
	by smtprelay-h21.telenor.se (Postfix) with ESMTP id 7F0F8D409
	for <netdev@vger.kernel.org>; Sat, 18 May 2013 18:20:31 +0200 (CEST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tv_usec is "suseconds_t" which is apparently usually
a signed long, but sometimes not....
Change the printf modifier to use signed and
cast the tv_usec to long in case it's not already long.

gcc -Wall -Wstrict-prototypes -Werror -Wmissing-prototypes -Wmissing-declarations -Wold-style-definition -O2 -I../include -DRESOLVE_HOSTNAMES -DLIBDIR=\"/usr/lib\" -DCONFDIR=\"/etc/iproute2\" -D_GNU_SOURCE -fPIC   -c -o utils.o utils.c
utils.c: In function 'print_timestamp':
utils.c:802:2: error: format '%lu' expects argument of type 'long unsigned int', but argument 4 has type '__suseconds_t' [-Werror=format]
cc1: all warnings being treated as errors

Signed-off-by: Andreas Henriksson <andreas@fatal.se>

---
 lib/utils.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/utils.c b/lib/utils.c
index bcd6002..dae1b51 100644
--- a/lib/utils.c
+++ b/lib/utils.c
@@ -799,7 +799,7 @@ int print_timestamp(FILE *fp)
 
 	tstr = asctime(localtime(&tv.tv_sec));
 	tstr[strlen(tstr)-1] = 0;
-	fprintf(fp, "Timestamp: %s %lu usec\n", tstr, tv.tv_usec);
+	fprintf(fp, "Timestamp: %s %ld usec\n", tstr, (long)tv.tv_usec);
 	return 0;
 }
 
-- 
1.7.10.4
