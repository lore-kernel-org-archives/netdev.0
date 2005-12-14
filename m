From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [RFC][PATCH 1/3] TCP/IP Critical socket communication mechanism
Date: Wed, 14 Dec 2005 01:12:35 -0800 (PST)
Message-ID: <Pine.LNX.4.58.0512140045370.31720@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932239AbVLNJMi@vger.kernel.org>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Introduce a new socket option SO_CRITICAL to mark a socket as critical.
This socket option takes a integer boolean flag that can be set using
setsockopt() and read with getsockopt().
-----------------------------------------------------------------------

 include/asm-i386/socket.h    |    2 ++
 include/asm-powerpc/socket.h |    2 ++
 net/core/sock.c              |   13 ++++++++++++-
 3 files changed, 16 insertions(+), 1 deletions(-)

diff --git a/include/asm-i386/socket.h b/include/asm-i386/socket.h
index 802ae76..bd4ce8e 100644
--- a/include/asm-i386/socket.h
+++ b/include/asm-i386/socket.h
@@ -49,4 +49,6 @@

 #define SO_PEERSEC		31

+#define SO_CRITICAL		100
+
 #endif /* _ASM_SOCKET_H */
diff --git a/include/asm-powerpc/socket.h b/include/asm-powerpc/socket.h
index e4b8177..6cfb79a 100644
--- a/include/asm-powerpc/socket.h
+++ b/include/asm-powerpc/socket.h
@@ -56,4 +56,6 @@

 #define SO_PEERSEC		31

+#define SO_CRITICAL		100
+
 #endif	/* _ASM_POWERPC_SOCKET_H */
diff --git a/net/core/sock.c b/net/core/sock.c
index 13cc3be..d2d10cb 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -456,6 +456,13 @@ set_rcvbuf:
 			ret = -ENONET;
 			break;

+		case SO_CRITICAL:
+			if (valbool)
+				sk->sk_allocation |= __GFP_CRITICAL;
+			else
+				sk->sk_allocation &= ~__GFP_CRITICAL;
+			break;
+
 		/* We implement the SO_SNDLOWAT etc to
 		   not be settable (1003.1g 5.3) */
 		default:
@@ -616,7 +623,11 @@ int sock_getsockopt(struct socket *sock,

 		case SO_PEERSEC:
 			return security_socket_getpeersec(sock, optval, optlen, len);
-
+
+		case SO_CRITICAL:
+			v.val = ((sk->sk_allocation & __GFP_CRITICAL) != 0);
+			break;
+
 		default:
 			return(-ENOPROTOOPT);
 	}
