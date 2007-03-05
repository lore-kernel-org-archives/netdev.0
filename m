From: KOVACS Krisztian <hidden@balabit.hu>
Subject: [PATCH/RFC 07/13] Conditionally enable transparent flow flag when
	connecting
Date: Mon, 05 Mar 2007 16:46:01 +0100
Message-ID: <20070305154601.3471.968.stgit@nienna.balabit>
References: <20070305154451.3471.18396.stgit@nienna.balabit>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.balabit.hu ([212.92.18.33]:4348 "EHLO lists.balabit.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933545AbXCEPqD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Mar 2007 10:46:03 -0500
Received: from balabit.hu (unknown [10.80.0.254])
	by lists.balabit.hu (Postfix) with ESMTP id 1983F294020
	for <netdev@vger.kernel.org>; Mon,  5 Mar 2007 16:46:02 +0100 (CET)
In-Reply-To: <20070305154451.3471.18396.stgit@nienna.balabit>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Set FLOWI_FLAG_TRANSPARENT in flowi->flags if the socket has the
transparent socket option set. This way we selectively enable certain
connections with non-local source addresses to be routed.

Signed-off-by: KOVACS Krisztian <hidden@balabit.hu>

---

 include/net/route.h |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/include/net/route.h b/include/net/route.h
index 13da592..4dff368 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -161,6 +161,10 @@ static inline int ip_route_connect(struct rtable **rp, __be32 dst,
 					 .dport = dport } } };
 
 	int err;
+
+	if (inet_sk(sk)->transparent)
+		fl.flags |= FLOWI_FLAG_TRANSPARENT;
+
 	if (!dst || !src) {
 		err = __ip_route_output_key(rp, &fl);
 		if (err)

