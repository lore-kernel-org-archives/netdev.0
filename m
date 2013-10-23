From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next] net: always inline net_secret_init
Date: Wed, 23 Oct 2013 08:44:50 +0200
Message-ID: <20131023064450.GA26236@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:51984 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751412Ab3JWGov (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Oct 2013 02:44:51 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently net_secret_init does not get inlined, so we always have a call
to net_secret_init even in the fast path.

Let's specify net_secret_init as __always_inline so we have the nop in
the fast-path without the call to net_secret_init and the unlikely path
at the epilogue of the function.

jump_labels handle the inlining correctly.

Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/core/secure_seq.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/secure_seq.c b/net/core/secure_seq.c
index b02fd16..90e8a82 100644
--- a/net/core/secure_seq.c
+++ b/net/core/secure_seq.c
@@ -15,7 +15,7 @@
 
 static u32 net_secret[NET_SECRET_SIZE] ____cacheline_aligned;
 
-static void net_secret_init(void)
+static __always_inline void net_secret_init(void)
 {
 	net_get_random_once(net_secret, sizeof(net_secret));
 }
-- 
1.8.3.1
