From: KOVACS Krisztian <hidden@sch.bme.hu>
Subject: [PATCH 04/14] Conditionally enable transparent flow flag when
	connecting
Date: Sat, 13 Oct 2007 19:31:01 +0200
Message-ID: <20071013173101.22517.34472.stgit@nessa.odu>
References: <20071013172857.22517.84760.stgit@nessa.odu>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7BIT
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from balu.sch.bme.hu ([152.66.208.40]:45511 "EHLO balu.sch.bme.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761609AbXJMSjq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Oct 2007 14:39:46 -0400
Received: from nessa.odu ([152.66.208.5])
 by balu.sch.bme.hu (Sun Java System Messaging Server 6.2-7.05 (built Sep  5
 2006)) with ESMTP id <0JPV00DUW1WR9X10@balu.sch.bme.hu> for
 netdev@vger.kernel.org; Sat, 13 Oct 2007 19:29:16 +0200 (CEST)
In-reply-to: <20071013172857.22517.84760.stgit@nessa.odu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Set FLOWI_FLAG_ANYSRC in flowi->flags if the socket has the
transparent socket option set. This way we selectively enable certain
connections with non-local source addresses to be routed.

Signed-off-by: KOVACS Krisztian <hidden@sch.bme.hu>
---

 include/net/route.h |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/include/net/route.h b/include/net/route.h
index 88fed3c..9788cc2 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -158,6 +158,10 @@ static inline int ip_route_connect(struct rtable **rp, __be32 dst,
 					 .dport = dport } } };
 
 	int err;
+
+	if (inet_sk(sk)->transparent)
+		fl.flags |= FLOWI_FLAG_ANYSRC;
+
 	if (!dst || !src) {
 		err = __ip_route_output_key(rp, &fl);
 		if (err)

