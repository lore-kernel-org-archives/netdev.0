From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] ipv6: tcp: fix panic in SYN processing
Date: Wed, 23 Nov 2011 12:33:56 +0100
Message-ID: <1322048036.17693.6.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:45420 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752983Ab1KWLd7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2011 06:33:59 -0500
Received: by vbbfc26 with SMTP id fc26so297555vbb.19
        for <netdev@vger.kernel.org>; Wed, 23 Nov 2011 03:33:58 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 72a3effaf633bc ([NET]: Size listen hash tables using backlog
hint) added a bug allowing inet6_synq_hash() to return an out of bound
array index, because of u16 overflow.

Bug can happen if system admins set net.core.somaxconn &
net.ipv4.tcp_max_syn_backlog sysctls to values greater than 65536

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv6/inet6_connection_sock.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/inet6_connection_sock.c b/net/ipv6/inet6_connection_sock.c
index fee46d5..1567fb1 100644
--- a/net/ipv6/inet6_connection_sock.c
+++ b/net/ipv6/inet6_connection_sock.c
@@ -85,7 +85,7 @@ struct dst_entry *inet6_csk_route_req(struct sock *sk,
  * request_sock (formerly open request) hash tables.
  */
 static u32 inet6_synq_hash(const struct in6_addr *raddr, const __be16 rport,
-			   const u32 rnd, const u16 synq_hsize)
+			   const u32 rnd, const u32 synq_hsize)
 {
 	u32 c;
 
