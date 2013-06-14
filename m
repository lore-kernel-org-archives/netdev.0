From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Subject: [PATCH v5 net-next 4/4] net: add socket option for low latency polling
Date: Fri, 14 Jun 2013 16:33:57 +0300
Message-ID: <20130614133357.6126.15138.stgit@ladj378.jer.intel.com>
References: <20130614133314.6126.77315.stgit@ladj378.jer.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	e1000-devel@lists.sourceforge.net,
	Willem de Bruijn <willemb@google.com>,
	Eric Dumazet <erdnetdev@gmail.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Andi Kleen <andi@firstfloor.org>, HPA <hpa@zytor.com>,
	Eilon Greenstien <eilong@broadcom.com>,
	Or Gerlitz <or.gerlitz@gmail.com>,
	Amir Vadai <amirv@mellanox.com>,
	Alex Rosenbaum <alexr@mellanox.com>,
	Avner Ben Hanoch <avnerb@mellanox.com>,
	Or Kehati <ork@mellanox.com>, sockperf-dev@googlegroups.com,
	Eliezer Tamir <eliezer@tamir.org.il>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130614133314.6126.77315.stgit@ladj378.jer.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

adds a socket option for low latency polling.
This allows overriding the global sysctl value with a per-socket one.
Unexport sysctl_net_ll_poll since for now it's not needed in modules.

Signed-off-by: Eliezer Tamir <eliezer.tamir@linux.intel.com>
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
 include/net/ll_poll.h                  |   12 ++++++------
 include/net/sock.h                     |    2 ++
 include/uapi/asm-generic/socket.h      |    2 ++
 net/core/sock.c                        |   20 ++++++++++++++++++++
 net/socket.c                           |    1 -
 19 files changed, 58 insertions(+), 7 deletions(-)

diff --git a/arch/alpha/include/uapi/asm/socket.h b/arch/alpha/include/uapi/asm/socket.h
index eee6ea7..4885825 100644
--- a/arch/alpha/include/uapi/asm/socket.h
+++ b/arch/alpha/include/uapi/asm/socket.h
@@ -81,4 +81,6 @@
 
 #define SO_SELECT_ERR_QUEUE	45
 
+#define SO_LL			46
+
 #endif /* _UAPI_ASM_SOCKET_H */
diff --git a/arch/avr32/include/uapi/asm/socket.h b/arch/avr32/include/uapi/asm/socket.h
index 37401f5..79b6179 100644
--- a/arch/avr32/include/uapi/asm/socket.h
+++ b/arch/avr32/include/uapi/asm/socket.h
@@ -74,4 +74,6 @@
 
 #define SO_SELECT_ERR_QUEUE	45
 
+#define SO_LL			46
+
 #endif /* __ASM_AVR32_SOCKET_H */
diff --git a/arch/cris/include/uapi/asm/socket.h b/arch/cris/include/uapi/asm/socket.h
index ba409c9..47b1ec5 100644
--- a/arch/cris/include/uapi/asm/socket.h
+++ b/arch/cris/include/uapi/asm/socket.h
@@ -76,6 +76,8 @@
 
 #define SO_SELECT_ERR_QUEUE	45
 
+#define SO_LL			46
+
 #endif /* _ASM_SOCKET_H */
 
 
diff --git a/arch/frv/include/uapi/asm/socket.h b/arch/frv/include/uapi/asm/socket.h
index 31dbb5d..dbc0852 100644
--- a/arch/frv/include/uapi/asm/socket.h
+++ b/arch/frv/include/uapi/asm/socket.h
@@ -74,5 +74,7 @@
 
 #define SO_SELECT_ERR_QUEUE	45
 
+#define SO_LL			46
+
 #endif /* _ASM_SOCKET_H */
 
diff --git a/arch/h8300/include/uapi/asm/socket.h b/arch/h8300/include/uapi/asm/socket.h
index 5d1c6d0..a38d38a 100644
--- a/arch/h8300/include/uapi/asm/socket.h
+++ b/arch/h8300/include/uapi/asm/socket.h
@@ -74,4 +74,6 @@
 
 #define SO_SELECT_ERR_QUEUE	45
 
+#define SO_LL			46
+
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/ia64/include/uapi/asm/socket.h b/arch/ia64/include/uapi/asm/socket.h
index 6b4329f..d3358b7 100644
--- a/arch/ia64/include/uapi/asm/socket.h
+++ b/arch/ia64/include/uapi/asm/socket.h
@@ -83,4 +83,6 @@
 
 #define SO_SELECT_ERR_QUEUE	45
 
+#define SO_LL			46
+
 #endif /* _ASM_IA64_SOCKET_H */
diff --git a/arch/m32r/include/uapi/asm/socket.h b/arch/m32r/include/uapi/asm/socket.h
index 2a3b59e..44aaf46 100644
--- a/arch/m32r/include/uapi/asm/socket.h
+++ b/arch/m32r/include/uapi/asm/socket.h
@@ -74,4 +74,6 @@
 
 #define SO_SELECT_ERR_QUEUE	45
 
+#define SO_LL			46
+
 #endif /* _ASM_M32R_SOCKET_H */
diff --git a/arch/mips/include/uapi/asm/socket.h b/arch/mips/include/uapi/asm/socket.h
index 3b21150..6a07992 100644
--- a/arch/mips/include/uapi/asm/socket.h
+++ b/arch/mips/include/uapi/asm/socket.h
@@ -92,4 +92,6 @@
 
 #define SO_SELECT_ERR_QUEUE	45
 
+#define SO_LL			46
+
 #endif /* _UAPI_ASM_SOCKET_H */
diff --git a/arch/mn10300/include/uapi/asm/socket.h b/arch/mn10300/include/uapi/asm/socket.h
index b4ce844..db80fd3 100644
--- a/arch/mn10300/include/uapi/asm/socket.h
+++ b/arch/mn10300/include/uapi/asm/socket.h
@@ -74,4 +74,6 @@
 
 #define SO_SELECT_ERR_QUEUE	45
 
+#define SO_LL			46
+
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/parisc/include/uapi/asm/socket.h b/arch/parisc/include/uapi/asm/socket.h
index 70c512a..f866fff 100644
--- a/arch/parisc/include/uapi/asm/socket.h
+++ b/arch/parisc/include/uapi/asm/socket.h
@@ -73,6 +73,8 @@
 
 #define SO_SELECT_ERR_QUEUE	0x4026
 
+#define SO_LL			0x4027
+
 /* O_NONBLOCK clashes with the bits used for socket types.  Therefore we
  * have to define SOCK_NONBLOCK to a different value here.
  */
diff --git a/arch/powerpc/include/uapi/asm/socket.h b/arch/powerpc/include/uapi/asm/socket.h
index a36daf3..405fb09 100644
--- a/arch/powerpc/include/uapi/asm/socket.h
+++ b/arch/powerpc/include/uapi/asm/socket.h
@@ -81,4 +81,6 @@
 
 #define SO_SELECT_ERR_QUEUE	45
 
+#define SO_LL			46
+
 #endif	/* _ASM_POWERPC_SOCKET_H */
diff --git a/arch/s390/include/uapi/asm/socket.h b/arch/s390/include/uapi/asm/socket.h
index 2dacb306..0c5105fb 100644
--- a/arch/s390/include/uapi/asm/socket.h
+++ b/arch/s390/include/uapi/asm/socket.h
@@ -80,4 +80,6 @@
 
 #define SO_SELECT_ERR_QUEUE	45
 
+#define SO_LL			46
+
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/sparc/include/uapi/asm/socket.h b/arch/sparc/include/uapi/asm/socket.h
index 89f49b6..b46c3fa 100644
--- a/arch/sparc/include/uapi/asm/socket.h
+++ b/arch/sparc/include/uapi/asm/socket.h
@@ -70,6 +70,8 @@
 
 #define SO_SELECT_ERR_QUEUE	0x0029
 
+#define SO_LL			0x0030
+
 /* Security levels - as per NRL IPv6 - don't actually do anything */
 #define SO_SECURITY_AUTHENTICATION		0x5001
 #define SO_SECURITY_ENCRYPTION_TRANSPORT	0x5002
diff --git a/arch/xtensa/include/uapi/asm/socket.h b/arch/xtensa/include/uapi/asm/socket.h
index a8f44f5..b21ace4 100644
--- a/arch/xtensa/include/uapi/asm/socket.h
+++ b/arch/xtensa/include/uapi/asm/socket.h
@@ -85,4 +85,6 @@
 
 #define SO_SELECT_ERR_QUEUE	45
 
+#define SO_LL			46
+
 #endif	/* _XTENSA_SOCKET_H */
diff --git a/include/net/ll_poll.h b/include/net/ll_poll.h
index 6930cbd..fcc7c36 100644
--- a/include/net/ll_poll.h
+++ b/include/net/ll_poll.h
@@ -39,12 +39,12 @@ extern unsigned int sysctl_net_ll_poll __read_mostly;
 /* we can use sched_clock() because we don't care much about precision
  * we only care that the average is bounded
  */
-static inline u64 ll_end_time(void)
+static inline u64 ll_end_time(struct sock *sk)
 {
-	u64 end_time = ACCESS_ONCE(sysctl_net_ll_poll);
+	u64 end_time = ACCESS_ONCE(sk->sk_ll_usec);
 
 	/* we don't mind a ~2.5% imprecision
-	 * sysctl_net_ll_poll is a u_int so this can't overflow
+	 * sk->sk_ll_usec is a u_int so this can't overflow
 	 */
 	end_time = (end_time << 10) + sched_clock();
 
@@ -53,7 +53,7 @@ static inline u64 ll_end_time(void)
 
 static inline bool sk_valid_ll(struct sock *sk)
 {
-	return sysctl_net_ll_poll && sk->sk_napi_id &&
+	return sk->sk_ll_usec && sk->sk_napi_id &&
 	       !need_resched() && !signal_pending(current);
 }
 
@@ -65,7 +65,7 @@ static inline bool can_poll_ll(u64 end_time)
 static inline bool sk_poll_ll(struct sock *sk, int nonblock)
 {
 	const struct net_device_ops *ops;
-	u64 end_time = ll_end_time();
+	u64 end_time = ll_end_time(sk);
 	struct napi_struct *napi;
 	int rc = false;
 
@@ -118,7 +118,7 @@ static inline void sk_mark_ll(struct sock *sk, struct sk_buff *skb)
 
 #else /* CONFIG_NET_LL_RX_POLL */
 
-static inline u64 ll_end_time(void)
+static inline u64 ll_end_time(struct sock *sk)
 {
 	return 0;
 }
diff --git a/include/net/sock.h b/include/net/sock.h
index ac8e181..21db792 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -230,6 +230,7 @@ struct cg_proto;
   *	@sk_wmem_queued: persistent queue size
   *	@sk_forward_alloc: space allocated forward
   *	@sk_napi_id: id of the last napi context to receive data for sk
+  *	@sk_ll_usec: usecs to busypoll when there is no data
   *	@sk_allocation: allocation mode
   *	@sk_sndbuf: size of send buffer in bytes
   *	@sk_flags: %SO_LINGER (l_onoff), %SO_BROADCAST, %SO_KEEPALIVE,
@@ -328,6 +329,7 @@ struct sock {
 #endif
 #ifdef CONFIG_NET_LL_RX_POLL
 	unsigned int		sk_napi_id;
+	unsigned int		sk_ll_usec;
 #endif
 	atomic_t		sk_drops;
 	int			sk_rcvbuf;
diff --git a/include/uapi/asm-generic/socket.h b/include/uapi/asm-generic/socket.h
index c5d2e3a..ca3a20d 100644
--- a/include/uapi/asm-generic/socket.h
+++ b/include/uapi/asm-generic/socket.h
@@ -76,4 +76,6 @@
 
 #define SO_SELECT_ERR_QUEUE	45
 
+#define SO_LL			46
+
 #endif /* __ASM_GENERIC_SOCKET_H */
diff --git a/net/core/sock.c b/net/core/sock.c
index 788c0da..1e744b1 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -913,6 +913,19 @@ set_rcvbuf:
 		sock_valbool_flag(sk, SOCK_SELECT_ERR_QUEUE, valbool);
 		break;
 
+#ifdef CONFIG_NET_LL_RX_POLL
+	case SO_LL:
+		/* allow unprivileged users to decrease the value */
+		if ((val > sk->sk_ll_usec) && !capable(CAP_NET_ADMIN))
+			ret = -EPERM;
+		else {
+			if (val < 0)
+				ret = -EINVAL;
+			else
+				sk->sk_ll_usec = val;
+		}
+		break;
+#endif
 	default:
 		ret = -ENOPROTOOPT;
 		break;
@@ -1170,6 +1183,12 @@ int sock_getsockopt(struct socket *sock, int level, int optname,
 		v.val = sock_flag(sk, SOCK_SELECT_ERR_QUEUE);
 		break;
 
+#ifdef CONFIG_NET_LL_RX_POLL
+	case SO_LL:
+		v.val = sk->sk_ll_usec;
+		break;
+#endif
+
 	default:
 		return -ENOPROTOOPT;
 	}
@@ -2288,6 +2307,7 @@ void sock_init_data(struct socket *sock, struct sock *sk)
 
 #ifdef CONFIG_NET_LL_RX_POLL
 	sk->sk_napi_id		=	0;
+	sk->sk_ll_usec		=	sysctl_net_ll_poll;
 #endif
 
 	/*
diff --git a/net/socket.c b/net/socket.c
index caaffa1..3eec3f7 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -108,7 +108,6 @@
 
 #ifdef CONFIG_NET_LL_RX_POLL
 unsigned int sysctl_net_ll_poll __read_mostly;
-EXPORT_SYMBOL_GPL(sysctl_net_ll_poll);
 #endif
 
 static int sock_no_open(struct inode *irrelevant, struct file *dontcare);
