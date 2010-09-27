From: Ulrich Weber <uweber@astaro.com>
Subject: [PATCH] tproxy: check for transparent flag in ip_route_newports
Date: Mon, 27 Sep 2010 15:31:00 +0200
Message-ID: <20100927133100.GB8916@babylon>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-22.dex002.intermedia.net ([64.78.21.93]:46613 "EHLO
	dhost002-22.dex002.intermedia.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750745Ab0I0NbH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Sep 2010 09:31:07 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

as done in ip_route_connect()

Signed-off-by: Ulrich Weber <uweber@astaro.com>
---
 include/net/route.h |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/include/net/route.h b/include/net/route.h
index bd732d6..7e5e73b 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -199,6 +199,8 @@ static inline int ip_route_newports(struct rtable **rp, u8 protocol,
 		fl.fl_ip_sport = sport;
 		fl.fl_ip_dport = dport;
 		fl.proto = protocol;
+		if (inet_sk(sk)->transparent)
+			fl.flags |= FLOWI_FLAG_ANYSRC;
 		ip_rt_put(*rp);
 		*rp = NULL;
 		security_sk_classify_flow(sk, &fl);
-- 
1.7.1

