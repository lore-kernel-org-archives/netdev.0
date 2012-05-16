From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: sock_flag() cleanup
Date: Wed, 16 May 2012 17:57:07 +0200
Message-ID: <1337183827.8512.1215.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:45581 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756001Ab2EPP5M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 May 2012 11:57:12 -0400
Received: by bkcji2 with SMTP id ji2so765477bkc.19
        for <netdev@vger.kernel.org>; Wed, 16 May 2012 08:57:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

- sock_flag() accepts a const pointer

- sock_flag() returns a boolean

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/sock.h |    2 +-
 net/core/sock.c    |   14 +++++++-------
 2 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index e613704..036f506 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -650,7 +650,7 @@ static inline void sock_reset_flag(struct sock *sk, enum sock_flags flag)
 	__clear_bit(flag, &sk->sk_flags);
 }
 
-static inline int sock_flag(struct sock *sk, enum sock_flags flag)
+static inline bool sock_flag(const struct sock *sk, enum sock_flags flag)
 {
 	return test_bit(flag, &sk->sk_flags);
 }
diff --git a/net/core/sock.c b/net/core/sock.c
index 26ed27f..9d144ee 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -849,7 +849,7 @@ int sock_getsockopt(struct socket *sock, int level, int optname,
 		break;
 
 	case SO_BROADCAST:
-		v.val = !!sock_flag(sk, SOCK_BROADCAST);
+		v.val = sock_flag(sk, SOCK_BROADCAST);
 		break;
 
 	case SO_SNDBUF:
@@ -865,7 +865,7 @@ int sock_getsockopt(struct socket *sock, int level, int optname,
 		break;
 
 	case SO_KEEPALIVE:
-		v.val = !!sock_flag(sk, SOCK_KEEPOPEN);
+		v.val = sock_flag(sk, SOCK_KEEPOPEN);
 		break;
 
 	case SO_TYPE:
@@ -887,7 +887,7 @@ int sock_getsockopt(struct socket *sock, int level, int optname,
 		break;
 
 	case SO_OOBINLINE:
-		v.val = !!sock_flag(sk, SOCK_URGINLINE);
+		v.val = sock_flag(sk, SOCK_URGINLINE);
 		break;
 
 	case SO_NO_CHECK:
@@ -900,7 +900,7 @@ int sock_getsockopt(struct socket *sock, int level, int optname,
 
 	case SO_LINGER:
 		lv		= sizeof(v.ling);
-		v.ling.l_onoff	= !!sock_flag(sk, SOCK_LINGER);
+		v.ling.l_onoff	= sock_flag(sk, SOCK_LINGER);
 		v.ling.l_linger	= sk->sk_lingertime / HZ;
 		break;
 
@@ -1012,11 +1012,11 @@ int sock_getsockopt(struct socket *sock, int level, int optname,
 		break;
 
 	case SO_RXQ_OVFL:
-		v.val = !!sock_flag(sk, SOCK_RXQ_OVFL);
+		v.val = sock_flag(sk, SOCK_RXQ_OVFL);
 		break;
 
 	case SO_WIFI_STATUS:
-		v.val = !!sock_flag(sk, SOCK_WIFI_STATUS);
+		v.val = sock_flag(sk, SOCK_WIFI_STATUS);
 		break;
 
 	case SO_PEEK_OFF:
@@ -1026,7 +1026,7 @@ int sock_getsockopt(struct socket *sock, int level, int optname,
 		v.val = sk->sk_peek_off;
 		break;
 	case SO_NOFCS:
-		v.val = !!sock_flag(sk, SOCK_NOFCS);
+		v.val = sock_flag(sk, SOCK_NOFCS);
 		break;
 	default:
 		return -ENOPROTOOPT;
