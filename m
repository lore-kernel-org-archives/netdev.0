From: Andreas Henriksson <andreas@fatal.se>
Subject: [PATCH iproute2] arpd: drop unnecessary explicit null termination
Date: Sun,  3 Jan 2016 17:09:44 +0100
Message-ID: <1451837384-2177-1-git-send-email-andreas@fatal.se>
Cc: netdev@vger.kernel.org, Andreas Henriksson <andreas@fatal.se>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from c-83-233-174-181.cust.bredband2.com ([83.233.174.181]:40679
	"EHLO pi.fatal.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751645AbcACQQ3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Jan 2016 11:16:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a followup to a previous commit 61170fd88d264c
"get rid of unnecessary fgets() buffer size limitation".

If fgets guarantees buffer will be null terminated in the
given size, then we can also drop the explicit termination.

While at it, also add an unrelated FIXME comment about
potential unlikely long comment handling bug spotted in
nearby code.

Signed-off-by: Andreas Henriksson <andreas@fatal.se>
---
 misc/arpd.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/misc/arpd.c b/misc/arpd.c
index 6bb9bd1..3be700d 100644
--- a/misc/arpd.c
+++ b/misc/arpd.c
@@ -702,12 +702,16 @@ int main(int argc, char **argv)
 			goto do_abort;
 		}
 
-		buf[sizeof(buf)-1] = 0;
 		while (fgets(buf, sizeof(buf), fp)) {
 			__u8 b1[6];
 			char ipbuf[128];
 			char macbuf[128];
 
+			/* FIXME: this does not properly handle the case where
+			 * the comment line is longer than sizeof(buf).
+			 * Should check if buf contains '\n' or skip upcoming
+			 * bufs until '\n' is found.
+			 */
 			if (buf[0] == '#')
 				continue;
 
-- 
2.1.4
