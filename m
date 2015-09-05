From: Denis Kirjanov <kda@linux-powerpc.org>
Subject: [PATCH] iproute: print more verbose error on route cache flush
Date: Sat,  5 Sep 2015 10:40:50 +0300
Message-ID: <1441438850-4793-1-git-send-email-kda@linux-powerpc.org>
Cc: netdev@vger.kernel.org, Denis Kirjanov <kda@linux-powerpc.org>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f180.google.com ([209.85.217.180]:33700 "EHLO
	mail-lb0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750749AbbIEITA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Sep 2015 04:19:00 -0400
Received: by lbcjc2 with SMTP id jc2so21338615lbc.0
        for <netdev@vger.kernel.org>; Sat, 05 Sep 2015 01:18:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Before:
kda@vfirst ~/devel/iproute2 $ ./ip/ip route flush cache
Cannot open "/proc/sys/net/ipv4/route/flush"

After:
kda@vfirst ~/devel/iproute2/ip $ ./ip route flush cache
Cannot open "/proc/sys/net/ipv4/route/flush": Permission denied

Signed-off-by: Denis Kirjanov <kda@linux-powerpc.org>
---
 ip/iproute.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/ip/iproute.c b/ip/iproute.c
index 8f49e62..abe4180 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -1213,7 +1213,8 @@ static int iproute_flush_cache(void)
 	char *buffer = "-1";
 
 	if (flush_fd < 0) {
-		fprintf (stderr, "Cannot open \"%s\"\n", ROUTE_FLUSH_PATH);
+		fprintf (stderr, "Cannot open \"%s\": %s\n",
+				ROUTE_FLUSH_PATH, strerror(errno));
 		return -1;
 	}
 
-- 
2.4.0
