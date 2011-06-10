From: Petr Sabata <contyk@redhat.com>
Subject: [PATCH] iproute2: Check getline() return code correctly
Date: Fri, 10 Jun 2011 14:49:27 +0200
Message-ID: <1307710167-28868-1-git-send-email-contyk@redhat.com>
Cc: Petr Sabata <contyk@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41986 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756156Ab1FJMtV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Jun 2011 08:49:21 -0400
Received: from int-mx01.intmail.prod.int.phx2.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id p5ACnLIX005024
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Fri, 10 Jun 2011 08:49:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current implementation is always false, no matter what happens.

Signed-off-by: Petr Sabata <contyk@redhat.com>
---
 lib/utils.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/utils.c b/lib/utils.c
index 1b42222..76cadea 100644
--- a/lib/utils.c
+++ b/lib/utils.c
@@ -702,7 +702,7 @@ ssize_t getcmdline(char **linep, size_t *lenp, FILE *in)
 		size_t len1 = 0;
 		size_t cc1;
 
-		if ((cc1 = getline(&line1, &len1, in)) < 0) {
+		if ((cc1 = getline(&line1, &len1, in)) == (size_t)-1) {
 			fprintf(stderr, "Missing continuation line\n");
 			return cc1;
 		}
-- 
1.7.5.2

