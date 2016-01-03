From: Andreas Henriksson <andreas@fatal.se>
Subject: [PATCH iproute2 v2 1/2] arpd: drop unnecessary explicit null termination
Date: Sun,  3 Jan 2016 19:39:32 +0100
Message-ID: <1451846374-2665-1-git-send-email-andreas@fatal.se>
References: <20160103090404.054e724b@xeon-e3>
Cc: netdev@vger.kernel.org, Andreas Henriksson <andreas@fatal.se>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from c-83-233-174-181.cust.bredband2.com ([83.233.174.181]:40680
	"EHLO pi.fatal.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751221AbcACSkF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Jan 2016 13:40:05 -0500
In-Reply-To: <20160103090404.054e724b@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a followup to a previous commit 61170fd88d264c
"get rid of unnecessary fgets() buffer size limitation".

If fgets guarantees buffer will be null terminated in the
given size, then we can also drop the explicit termination.

Signed-off-by: Andreas Henriksson <andreas@fatal.se>
---
 misc/arpd.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/misc/arpd.c b/misc/arpd.c
index 6bb9bd1..700dc50 100644
--- a/misc/arpd.c
+++ b/misc/arpd.c
@@ -702,7 +702,6 @@ int main(int argc, char **argv)
 			goto do_abort;
 		}
 
-		buf[sizeof(buf)-1] = 0;
 		while (fgets(buf, sizeof(buf), fp)) {
 			__u8 b1[6];
 			char ipbuf[128];
-- 
2.1.4
