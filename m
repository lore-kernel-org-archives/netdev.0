From: Flavio Leitner <fbl@redhat.com>
Subject: [PATCH net-next] tcp: ipv6: bind() use stronger condition for bind_conflict
Date: Tue,  5 Mar 2013 15:11:01 -0300
Message-ID: <1362507061-22475-1-git-send-email-fbl@redhat.com>
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Flavio Leitner <fbl@redhat.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:14648 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756434Ab3CESMt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Mar 2013 13:12:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We must try harder to get unique (addr, port) pairs when
doing port autoselection for sockets with SO_REUSEADDR
option set.

This is a continuation of commit aacd9289af8b82f5fb01bcdd53d0e3406d1333c7
for IPv6.

Signed-off-by: Flavio Leitner <fbl@redhat.com>
---
 net/ipv6/inet6_connection_sock.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/ipv6/inet6_connection_sock.c b/net/ipv6/inet6_connection_sock.c
index b386a2c..f7f49bf 100644
--- a/net/ipv6/inet6_connection_sock.c
+++ b/net/ipv6/inet6_connection_sock.c
@@ -55,6 +55,10 @@ int inet6_csk_bind_conflict(const struct sock *sk,
 				if (ipv6_rcv_saddr_equal(sk, sk2))
 					break;
 			}
+			if (!relax && reuse && sk2->sk_reuse &&
+			    sk2->sk_state != TCP_LISTEN &&
+			    ipv6_rcv_saddr_equal(sk, sk2))
+				break;
 		}
 	}
 
-- 
1.8.1.4
