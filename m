From: Jacob Keller <jacob.e.keller@intel.com>
Subject: [net-next PATCH] [RFC] [v2] net: add option to enable error queue packets waking select
Date: Thu, 28 Mar 2013 14:19:25 -0700
Message-ID: <20130328211925.7644.15781.stgit@jekeller-hub.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Jeffrey Kirsher <jeffrey.t.kirsher@intel.com>,
	Richard Cochran <richardcochran@gmail.com>,
	Matthew Vick <matthew.vick@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:36476 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753027Ab3C1VT1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Mar 2013 17:19:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, when a socket receives something on the error queue it only wakes up
the socket on select if it is in the "read" list, that is the socket has
something to read. It is useful also to wake the socket if it is in the error
list, which would enable software to wait on error queue packets without waking
up for regular data on the socket. The main use case is for receiving
timestamped transmit packets which return the timestamp to the socket via the
error queue. This enables an application to select on the socket for the error
queue only instead of for the regular traffic.

-v2-
* Added the SO_SELECT_ERR_QUEUE socket option to every architechture specific file
* Modified every socket poll function that checks error queue

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Cc: Jeffrey Kirsher <jeffrey.t.kirsher@intel.com>
Cc: Richard Cochran <richardcochran@gmail.com>
Cc: Matthew Vick <matthew.vick@intel.com>
---
 arch/alpha/include/uapi/asm/socket.h   |    2 ++
 arch/avr32/include/uapi/asm/socket.h   |    2 ++
 arch/cris/include/uapi/asm/socket.h    |    2 ++
 arch/frv/include/uapi/asm/socket.h     |    2 ++
 arch/h8300/include/uapi/asm/socket.h   |    2 ++
 arch/ia64/include/uapi/asm/socket.h    |    2 ++
 arch/m32r/include/uapi/asm/socket.h    |    2 ++
 arch/mips/include/uapi/asm/socket.h    |    2 ++
 arch/mn10300/include/uapi/asm/socket.h |    2 ++
 arch/parisc/include/uapi/asm/socket.h  |    2 ++
 arch/powerpc/include/uapi/asm/socket.h |    2 ++
 arch/s390/include/uapi/asm/socket.h    |    2 ++
 arch/sparc/include/uapi/asm/socket.h   |    2 ++
 arch/xtensa/include/uapi/asm/socket.h  |    2 ++
 include/net/sock.h                     |    1 +
 include/uapi/asm-generic/socket.h      |    2 ++
 net/bluetooth/af_bluetooth.c           |    3 ++-
 net/core/datagram.c                    |    4 +++-
 net/core/sock.c                        |    8 ++++++++
 net/iucv/af_iucv.c                     |    3 ++-
 net/nfc/llcp/sock.c                    |    3 ++-
 net/sctp/socket.c                      |    3 ++-
 net/unix/af_unix.c                     |    4 +++-
 23 files changed, 53 insertions(+), 6 deletions(-)

diff --git a/arch/alpha/include/uapi/asm/socket.h b/arch/alpha/include/uapi/asm/socket.h
index c519552..eee6ea7 100644
--- a/arch/alpha/include/uapi/asm/socket.h
+++ b/arch/alpha/include/uapi/asm/socket.h
@@ -79,4 +79,6 @@
 
 #define SO_LOCK_FILTER		44
 
+#define SO_SELECT_ERR_QUEUE	45
+
 #endif /* _UAPI_ASM_SOCKET_H */
diff --git a/arch/avr32/include/uapi/asm/socket.h b/arch/avr32/include/uapi/asm/socket.h
index 51c6401..37401f5 100644
--- a/arch/avr32/include/uapi/asm/socket.h
+++ b/arch/avr32/include/uapi/asm/socket.h
@@ -72,4 +72,6 @@
 
 #define SO_LOCK_FILTER		44
 
+#define SO_SELECT_ERR_QUEUE	45
+
 #endif /* __ASM_AVR32_SOCKET_H */
diff --git a/arch/cris/include/uapi/asm/socket.h b/arch/cris/include/uapi/asm/socket.h
index 50692b7..ba409c9 100644
--- a/arch/cris/include/uapi/asm/socket.h
+++ b/arch/cris/include/uapi/asm/socket.h
@@ -74,6 +74,8 @@
 
 #define SO_LOCK_FILTER		44
 
+#define SO_SELECT_ERR_QUEUE	45
+
 #endif /* _ASM_SOCKET_H */
 
 
diff --git a/arch/frv/include/uapi/asm/socket.h b/arch/frv/include/uapi/asm/socket.h
index 595391f..31dbb5d 100644
--- a/arch/frv/include/uapi/asm/socket.h
+++ b/arch/frv/include/uapi/asm/socket.h
@@ -72,5 +72,7 @@
 
 #define SO_LOCK_FILTER		44
 
+#define SO_SELECT_ERR_QUEUE	45
+
 #endif /* _ASM_SOCKET_H */
 
diff --git a/arch/h8300/include/uapi/asm/socket.h b/arch/h8300/include/uapi/asm/socket.h
index 43e3262..5d1c6d0 100644
--- a/arch/h8300/include/uapi/asm/socket.h
+++ b/arch/h8300/include/uapi/asm/socket.h
@@ -72,4 +72,6 @@
 
 #define SO_LOCK_FILTER		44
 
+#define SO_SELECT_ERR_QUEUE	45
+
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/ia64/include/uapi/asm/socket.h b/arch/ia64/include/uapi/asm/socket.h
index c567adc..6b4329f 100644
--- a/arch/ia64/include/uapi/asm/socket.h
+++ b/arch/ia64/include/uapi/asm/socket.h
@@ -81,4 +81,6 @@
 
 #define SO_LOCK_FILTER		44
 
+#define SO_SELECT_ERR_QUEUE	45
+
 #endif /* _ASM_IA64_SOCKET_H */
diff --git a/arch/m32r/include/uapi/asm/socket.h b/arch/m32r/include/uapi/asm/socket.h
index 519afa2..2a3b59e 100644
--- a/arch/m32r/include/uapi/asm/socket.h
+++ b/arch/m32r/include/uapi/asm/socket.h
@@ -72,4 +72,6 @@
 
 #define SO_LOCK_FILTER		44
 
+#define SO_SELECT_ERR_QUEUE	45
+
 #endif /* _ASM_M32R_SOCKET_H */
diff --git a/arch/mips/include/uapi/asm/socket.h b/arch/mips/include/uapi/asm/socket.h
index 47132f4..3b21150 100644
--- a/arch/mips/include/uapi/asm/socket.h
+++ b/arch/mips/include/uapi/asm/socket.h
@@ -90,4 +90,6 @@
 
 #define SO_LOCK_FILTER		44
 
+#define SO_SELECT_ERR_QUEUE	45
+
 #endif /* _UAPI_ASM_SOCKET_H */
diff --git a/arch/mn10300/include/uapi/asm/socket.h b/arch/mn10300/include/uapi/asm/socket.h
index 5c7c7c9..b4ce844 100644
--- a/arch/mn10300/include/uapi/asm/socket.h
+++ b/arch/mn10300/include/uapi/asm/socket.h
@@ -72,4 +72,6 @@
 
 #define SO_LOCK_FILTER		44
 
+#define SO_SELECT_ERR_QUEUE	45
+
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/parisc/include/uapi/asm/socket.h b/arch/parisc/include/uapi/asm/socket.h
index 526e4b9..70c512a 100644
--- a/arch/parisc/include/uapi/asm/socket.h
+++ b/arch/parisc/include/uapi/asm/socket.h
@@ -71,6 +71,8 @@
 
 #define SO_LOCK_FILTER		0x4025
 
+#define SO_SELECT_ERR_QUEUE	0x4026
+
 /* O_NONBLOCK clashes with the bits used for socket types.  Therefore we
  * have to define SOCK_NONBLOCK to a different value here.
  */
diff --git a/arch/powerpc/include/uapi/asm/socket.h b/arch/powerpc/include/uapi/asm/socket.h
index a26dcae..a36daf3 100644
--- a/arch/powerpc/include/uapi/asm/socket.h
+++ b/arch/powerpc/include/uapi/asm/socket.h
@@ -79,4 +79,6 @@
 
 #define SO_LOCK_FILTER		44
 
+#define SO_SELECT_ERR_QUEUE	45
+
 #endif	/* _ASM_POWERPC_SOCKET_H */
diff --git a/arch/s390/include/uapi/asm/socket.h b/arch/s390/include/uapi/asm/socket.h
index f99eea7..2dacb306 100644
--- a/arch/s390/include/uapi/asm/socket.h
+++ b/arch/s390/include/uapi/asm/socket.h
@@ -78,4 +78,6 @@
 
 #define SO_LOCK_FILTER		44
 
+#define SO_SELECT_ERR_QUEUE	45
+
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/sparc/include/uapi/asm/socket.h b/arch/sparc/include/uapi/asm/socket.h
index cbbad74..89f49b6 100644
--- a/arch/sparc/include/uapi/asm/socket.h
+++ b/arch/sparc/include/uapi/asm/socket.h
@@ -68,6 +68,8 @@
 
 #define SO_LOCK_FILTER		0x0028
 
+#define SO_SELECT_ERR_QUEUE	0x0029
+
 /* Security levels - as per NRL IPv6 - don't actually do anything */
 #define SO_SECURITY_AUTHENTICATION		0x5001
 #define SO_SECURITY_ENCRYPTION_TRANSPORT	0x5002
diff --git a/arch/xtensa/include/uapi/asm/socket.h b/arch/xtensa/include/uapi/asm/socket.h
index 35905cb..a8f44f5 100644
--- a/arch/xtensa/include/uapi/asm/socket.h
+++ b/arch/xtensa/include/uapi/asm/socket.h
@@ -83,4 +83,6 @@
 
 #define SO_LOCK_FILTER		44
 
+#define SO_SELECT_ERR_QUEUE	45
+
 #endif	/* _XTENSA_SOCKET_H */
diff --git a/include/net/sock.h b/include/net/sock.h
index 14f6e9d..08f05f9 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -667,6 +667,7 @@ enum sock_flags {
 		     * user-space instead.
 		     */
 	SOCK_FILTER_LOCKED, /* Filter cannot be changed anymore */
+	SOCK_SELECT_ERR_QUEUE, /* Wake select on error queue */
 };
 
 static inline void sock_copy_flags(struct sock *nsk, struct sock *osk)
diff --git a/include/uapi/asm-generic/socket.h b/include/uapi/asm-generic/socket.h
index 4ef3acb..c5d2e3a 100644
--- a/include/uapi/asm-generic/socket.h
+++ b/include/uapi/asm-generic/socket.h
@@ -74,4 +74,6 @@
 
 #define SO_LOCK_FILTER		44
 
+#define SO_SELECT_ERR_QUEUE	45
+
 #endif /* __ASM_GENERIC_SOCKET_H */
diff --git a/net/bluetooth/af_bluetooth.c b/net/bluetooth/af_bluetooth.c
index d3ee69b..409902f 100644
--- a/net/bluetooth/af_bluetooth.c
+++ b/net/bluetooth/af_bluetooth.c
@@ -422,7 +422,8 @@ unsigned int bt_sock_poll(struct file *file, struct socket *sock,
 		return bt_accept_poll(sk);
 
 	if (sk->sk_err || !skb_queue_empty(&sk->sk_error_queue))
-		mask |= POLLERR;
+		mask |= POLLERR |
+			sock_flag(sk, SOCK_SELECT_ERR_QUEUE) ? POLLPRI : 0;
 
 	if (sk->sk_shutdown & RCV_SHUTDOWN)
 		mask |= POLLRDHUP | POLLIN | POLLRDNORM;
diff --git a/net/core/datagram.c b/net/core/datagram.c
index 368f9c3..36da5b6 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -749,7 +749,9 @@ unsigned int datagram_poll(struct file *file, struct socket *sock,
 
 	/* exceptional events? */
 	if (sk->sk_err || !skb_queue_empty(&sk->sk_error_queue))
-		mask |= POLLERR;
+		mask |= POLLERR |
+			sock_flag(sk, SOCK_SELECT_ERR_QUEUE) ? POLLPRI : 0;
+
 	if (sk->sk_shutdown & RCV_SHUTDOWN)
 		mask |= POLLRDHUP | POLLIN | POLLRDNORM;
 	if (sk->sk_shutdown == SHUTDOWN_MASK)
diff --git a/net/core/sock.c b/net/core/sock.c
index a19e728..2ff5f36 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -907,6 +907,10 @@ set_rcvbuf:
 		sock_valbool_flag(sk, SOCK_NOFCS, valbool);
 		break;
 
+	case SO_SELECT_ERR_QUEUE:
+		sock_valbool_flag(sk, SOCK_SELECT_ERR_QUEUE, valbool);
+		break;
+
 	default:
 		ret = -ENOPROTOOPT;
 		break;
@@ -1160,6 +1164,10 @@ int sock_getsockopt(struct socket *sock, int level, int optname,
 		v.val = sock_flag(sk, SOCK_FILTER_LOCKED);
 		break;
 
+	case SO_SELECT_ERR_QUEUE:
+		v.val = sock_flag(sk, SOCK_SELECT_ERR_QUEUE);
+		break;
+
 	default:
 		return -ENOPROTOOPT;
 	}
diff --git a/net/iucv/af_iucv.c b/net/iucv/af_iucv.c
index a7d11ffe..f0550a3 100644
--- a/net/iucv/af_iucv.c
+++ b/net/iucv/af_iucv.c
@@ -1461,7 +1461,8 @@ unsigned int iucv_sock_poll(struct file *file, struct socket *sock,
 		return iucv_accept_poll(sk);
 
 	if (sk->sk_err || !skb_queue_empty(&sk->sk_error_queue))
-		mask |= POLLERR;
+		mask |= POLLERR |
+			sock_flag(sk, SOCK_SELECT_ERR_QUEUE) ? POLLPRI : 0;
 
 	if (sk->sk_shutdown & RCV_SHUTDOWN)
 		mask |= POLLRDHUP;
diff --git a/net/nfc/llcp/sock.c b/net/nfc/llcp/sock.c
index f1b377e..2d55e8a 100644
--- a/net/nfc/llcp/sock.c
+++ b/net/nfc/llcp/sock.c
@@ -521,7 +521,8 @@ static unsigned int llcp_sock_poll(struct file *file, struct socket *sock,
 		return llcp_accept_poll(sk);
 
 	if (sk->sk_err || !skb_queue_empty(&sk->sk_error_queue))
-		mask |= POLLERR;
+		mask |= POLLERR |
+			sock_flag(sk, SOCK_SELECT_ERR_QUEUE) ? POLLPRI : 0;
 
 	if (!skb_queue_empty(&sk->sk_receive_queue))
 		mask |= POLLIN | POLLRDNORM;
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index b907073..dd21ae3 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -6185,7 +6185,8 @@ unsigned int sctp_poll(struct file *file, struct socket *sock, poll_table *wait)
 
 	/* Is there any exceptional events?  */
 	if (sk->sk_err || !skb_queue_empty(&sk->sk_error_queue))
-		mask |= POLLERR;
+		mask |= POLLERR |
+			sock_flag(sk, SOCK_SELECT_ERR_QUEUE) ? POLLPRI : 0;
 	if (sk->sk_shutdown & RCV_SHUTDOWN)
 		mask |= POLLRDHUP | POLLIN | POLLRDNORM;
 	if (sk->sk_shutdown == SHUTDOWN_MASK)
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 51be64f..2d2ccf8 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -2197,7 +2197,9 @@ static unsigned int unix_dgram_poll(struct file *file, struct socket *sock,
 
 	/* exceptional events? */
 	if (sk->sk_err || !skb_queue_empty(&sk->sk_error_queue))
-		mask |= POLLERR;
+		mask |= POLLERR |
+			sock_flag(sk, SOCK_SELECT_ERR_QUEUE) ? POLLPRI : 0;
+
 	if (sk->sk_shutdown & RCV_SHUTDOWN)
 		mask |= POLLRDHUP | POLLIN | POLLRDNORM;
 	if (sk->sk_shutdown == SHUTDOWN_MASK)
