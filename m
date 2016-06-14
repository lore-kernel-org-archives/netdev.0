From: Beniamino Galvani <bgalvani@redhat.com>
Subject: [iproute2 PATCH] utils: fix hex digits parsing in hexstring_a2n()
Date: Tue, 14 Jun 2016 22:55:17 +0200
Message-ID: <1465937717-16247-1-git-send-email-bgalvani@redhat.com>
To: netdev@vger.kernel.org, Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56653 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932082AbcFNUzh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jun 2016 16:55:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

strtoul() only modifies errno on overflow, so if errno is not zero
before calling the function its value is preserved and makes the
function fail for valid inputs; initialize it.

Signed-off-by: Beniamino Galvani <bgalvani@redhat.com>
---
 lib/utils.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/lib/utils.c b/lib/utils.c
index 70e85b7..7dceeb5 100644
--- a/lib/utils.c
+++ b/lib/utils.c
@@ -924,6 +924,7 @@ __u8 *hexstring_a2n(const char *str, __u8 *buf, int blen, unsigned int *len)
 
 		strncpy(tmpstr, str, 2);
 		tmpstr[2] = '\0';
+		errno = 0;
 		tmp = strtoul(tmpstr, &endptr, 16);
 		if (errno != 0 || tmp > 0xFF || *endptr != '\0')
 			return NULL;
-- 
2.5.5
