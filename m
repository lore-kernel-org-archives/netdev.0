From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH iproute2] Fix compile warning in get_addr_1
Date: Tue, 13 Dec 2016 15:34:32 -0800
Message-ID: <1481672072-14140-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org, stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:36539 "EHLO
        mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751014AbcLMXf5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Dec 2016 18:35:57 -0500
Received: by mail-pf0-f175.google.com with SMTP id 189so361112pfz.3
        for <netdev@vger.kernel.org>; Tue, 13 Dec 2016 15:34:40 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A recent cleanup causes a compile warning on Debian jessie:

    CC       utils.o
utils.c: In function ‘get_addr_1’:
utils.c:486:21: warning: passing argument 1 of ‘ll_addr_a2n’ from incompatible pointer type
   len = ll_addr_a2n(&addr->data, sizeof(addr->data), name);
                     ^
In file included from utils.c:34:0:
../include/rt_names.h:27:5: note: expected ‘char *’ but argument is of type ‘__u32 (*)[8]’
 int ll_addr_a2n(char *lladdr, int len, const char *arg);
     ^

Revert the removal of the typecast

Fixes: e1933b928125 ("utils: cleanup style")
Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 lib/utils.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/lib/utils.c b/lib/utils.c
index 316b048abcfc..83c9d097c608 100644
--- a/lib/utils.c
+++ b/lib/utils.c
@@ -483,7 +483,8 @@ int get_addr_1(inet_prefix *addr, const char *name, int family)
 	if (family == AF_PACKET) {
 		int len;
 
-		len = ll_addr_a2n(&addr->data, sizeof(addr->data), name);
+		len = ll_addr_a2n((char *) &addr->data, sizeof(addr->data),
+				  name);
 		if (len < 0)
 			return -1;
 
-- 
2.1.4
