From: Jakub Sitnicki <jkbs@redhat.com>
Subject: [iproute PATCH] iproute: Remove useless check for nexthop keyword when setting RTA_OIF
Date: Wed,  7 Jun 2017 15:23:13 +0200
Message-ID: <20170607132313.5290-1-jkbs@redhat.com>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:33060 "EHLO
        mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751203AbdFGNXQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Jun 2017 09:23:16 -0400
Received: by mail-wm0-f47.google.com with SMTP id m7so33207880wmg.0
        for <netdev@vger.kernel.org>; Wed, 07 Jun 2017 06:23:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When modifying a route we set the RTA_OIF attribute only if a device was
specified with "dev" or "oif" keyword. But for some unknown reason we
earlier alternatively check also for the presence of "nexthop" keyword,
even though it has no effect. So remove the pointless check.

Signed-off-by: Jakub Sitnicki <jkbs@redhat.com>
---
 ip/iproute.c | 12 +++++-------
 1 file changed, 5 insertions(+), 7 deletions(-)

diff --git a/ip/iproute.c b/ip/iproute.c
index b4ca291..4fd36a1 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -1241,16 +1241,14 @@ static int iproute_modify(int cmd, unsigned int flags, int argc, char **argv)
 	if (!dst_ok)
 		usage();
 
-	if (d || nhs_ok)  {
+	if (d) {
 		int idx;
 
-		if (d) {
-			if ((idx = ll_name_to_index(d)) == 0) {
-				fprintf(stderr, "Cannot find device \"%s\"\n", d);
-				return -1;
-			}
-			addattr32(&req.n, sizeof(req), RTA_OIF, idx);
+		if ((idx = ll_name_to_index(d)) == 0) {
+			fprintf(stderr, "Cannot find device \"%s\"\n", d);
+			return -1;
 		}
+		addattr32(&req.n, sizeof(req), RTA_OIF, idx);
 	}
 
 	if (mxrta->rta_len > RTA_LENGTH(0)) {
-- 
2.9.4
