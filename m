From: Niv Yehezkel <executerx@gmail.com>
Subject: [PATCH] ipv4: removed redundant conditional
Date: Fri, 8 Aug 2014 04:27:37 -0400
Message-ID: <20140808082737.GA3847@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f42.google.com ([74.125.82.42]:35952 "EHLO
	mail-wg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753379AbaHHI1m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Aug 2014 04:27:42 -0400
Received: by mail-wg0-f42.google.com with SMTP id l18so5230687wgh.1
        for <netdev@vger.kernel.org>; Fri, 08 Aug 2014 01:27:40 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since fib_lookup cannot return ESRCH no longer,
checking for this error code is no longer neccesary.

Signed-off-by: Niv Yehezkel <executerx@gmail.com>
---
 net/ipv4/route.c |    2 --
 1 file changed, 2 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 082239f..23175cb 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1771,8 +1771,6 @@ local_input:
 no_route:
 	RT_CACHE_STAT_INC(in_no_route);
 	res.type = RTN_UNREACHABLE;
-	if (err == -ESRCH)
-		err = -ENETUNREACH;
 	goto local_input;
 
 	/*
-- 
1.7.10.4
