From: Balazs Scheidler <bazsi@balabit.hu>
Subject: [PATCH] [TPROXY] fill struct flowi->flags in udp_sendmsg()
Date: Tue, 18 Nov 2008 16:26:32 +0100
Message-ID: <6afd3db7f90a6e8637f3f97607422abb8997c64b.1227023129.git.bazsi@balabit.hu>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from support.balabit.hu ([195.70.41.86]:39487 "EHLO lists.balabit.hu"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752010AbYKRPsF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Nov 2008 10:48:05 -0500
Received: from balabit.hu (unknown [10.80.0.254])
	by lists.balabit.hu (Postfix) with ESMTP id 2B3D939C3C7
	for <netdev@vger.kernel.org>; Tue, 18 Nov 2008 16:48:01 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

    udp_sendmsg() didn't fill struct flowi->flags, which means that
    the route lookup would fail for non-local IPs even if the
    IP_TRANSPARENT sockopt was set.

    This prevents sendto() to work properly for UDP sockets, whereas
    bind(foreign-ip) + connect() + send() worked fine.

Signed-off-by: Balazs Scheidler <bazsi@balabit.hu>
---
 net/ipv4/udp.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index cf02701..98c1fd0 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -633,6 +633,7 @@ int udp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 						.saddr = saddr,
 						.tos = tos } },
 				    .proto = sk->sk_protocol,
+				    .flags = inet_sk_flowi_flags(sk),
 				    .uli_u = { .ports =
 					       { .sport = inet->sport,
 						 .dport = dport } } };
-- 
1.5.4.3


