From: Balazs Scheidler <bazsi@balabit.hu>
Subject: [PATCH] [TPROXY] supply a struct flowi->flags argument in
	inet_sk_rebuild_header()
Date: Tue, 18 Nov 2008 16:33:35 +0100
Message-ID: <c23fce5cd1bf67e9123ac6e5a776825b8664a124.1227023129.git.bazsi@balabit.hu>
References: <6afd3db7f90a6e8637f3f97607422abb8997c64b.1227023129.git.bazsi@balabit.hu>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from support.balabit.hu ([195.70.41.86]:39490 "EHLO lists.balabit.hu"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751668AbYKRPsF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Nov 2008 10:48:05 -0500
Received: from balabit.hu (unknown [10.80.0.254])
	by lists.balabit.hu (Postfix) with ESMTP id 0BADE39C3CC
	for <netdev@vger.kernel.org>; Tue, 18 Nov 2008 16:48:02 +0100 (CET)
In-Reply-To: <6afd3db7f90a6e8637f3f97607422abb8997c64b.1227023129.git.bazsi@balabit.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

    inet_sk_rebuild_header() does a new route lookup if the dst_entry
    associated with a socket becomes stale. However inet_sk_rebuild_header()
    didn't use struct flowi->flags, causing the route lookup to
    fail for foreign-bound IP_TRANSPARENT sockets, causing an error
    state to be set for the sockets in question.

Signed-off-by: Balazs Scheidler <bazsi@balabit.hu>
---
 net/ipv4/af_inet.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 1fbff5f..1aa2dc9 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1117,6 +1117,7 @@ int inet_sk_rebuild_header(struct sock *sk)
 			},
 		},
 		.proto = sk->sk_protocol,
+		.flags = inet_sk_flowi_flags(sk),
 		.uli_u = {
 			.ports = {
 				.sport = inet->sport,
-- 
1.5.4.3


