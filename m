From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 36/51] netem/maketable: Check return value of fstat()
Date: Sat, 12 Aug 2017 14:04:55 +0200
Message-ID: <20170812120510.28750-37-phil@nwl.cc>
References: <20170812120510.28750-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:41985 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752474AbdHLMHW (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 12 Aug 2017 08:07:22 -0400
In-Reply-To: <20170812120510.28750-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Otherwise info.st_size may contain garbage.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 netem/maketable.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/netem/maketable.c b/netem/maketable.c
index 6aff927be7040..ad660e7d457f0 100644
--- a/netem/maketable.c
+++ b/netem/maketable.c
@@ -24,8 +24,8 @@ readdoubles(FILE *fp, int *number)
 	int limit;
 	int n=0, i;
 
-	fstat(fileno(fp), &info);
-	if (info.st_size > 0) {
+	if (!fstat(fileno(fp), &info) &&
+	    info.st_size > 0) {
 		limit = 2*info.st_size/sizeof(double);	/* @@ approximate */
 	} else {
 		limit = 10000;
-- 
2.13.1
