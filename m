From: kan.liang@intel.com
Subject: [RFC PATCH 20/30] net/netpolicy: introduce per socket netpolicy
Date: Sun, 17 Jul 2016 23:56:14 -0700
Message-ID: <1468824984-65318-21-git-send-email-kan.liang@intel.com>
References: <1468824984-65318-1-git-send-email-kan.liang@intel.com>
Cc: jeffrey.t.kirsher@intel.com, mingo@redhat.com,
	peterz@infradead.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net,
	akpm@linux-foundation.org, keescook@chromium.org,
	viro@zeniv.linux.org.uk, gorcunov@openvz.org,
	john.stultz@linaro.org, aduyck@mirantis.com, ben@decadent.org.uk,
	decot@googlers.com, jesse.brandeburg@intel.com,
	andi@firstfloor.org, Kan Liang <kan.liang@intel.com>
To: davem@davemloft.net, linux-kernel@vger.kernel.org,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1468824984-65318-1-git-send-email-kan.liang@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kan Liang <kan.liang@intel.com>

The network socket is the most basic unit which control the network
traffic. This patch introduces a new socket option SO_NETPOLICY to
set/get net policy for socket. so that the application can set its own
policy on socket to improve the network performance.
Per socket net policy can also be inherited by new socket.

The usage of SO_NETPOLICY socket option is as below.
setsockopt(sockfd,SOL_SOCKET,SO_NETPOLICY,&policy,sizeof(int))
getsockopt(sockfd,SOL_SOCKET,SO_NETPOLICY,&policy,sizeof(int))
The policy set by SO_NETPOLICY socket option must be valid and
compatible with current device policy. Othrewise, it will error out. The
socket policy will be set to NET_POLICY_INVALID.

Signed-off-by: Kan Liang <kan.liang@intel.com>
---
 arch/alpha/include/uapi/asm/socket.h   |  2 ++
 arch/avr32/include/uapi/asm/socket.h   |  2 ++
 arch/frv/include/uapi/asm/socket.h     |  2 ++
 arch/ia64/include/uapi/asm/socket.h    |  2 ++
 arch/m32r/include/uapi/asm/socket.h    |  2 ++
 arch/mips/include/uapi/asm/socket.h    |  2 ++
 arch/mn10300/include/uapi/asm/socket.h |  2 ++
 arch/parisc/include/uapi/asm/socket.h  |  2 ++
 arch/powerpc/include/uapi/asm/socket.h |  2 ++
 arch/s390/include/uapi/asm/socket.h    |  2 ++
 arch/sparc/include/uapi/asm/socket.h   |  2 ++
 arch/xtensa/include/uapi/asm/socket.h  |  2 ++
 include/net/request_sock.h             |  4 +++-
 include/net/sock.h                     |  9 +++++++++
 include/uapi/asm-generic/socket.h      |  2 ++
 net/core/sock.c                        | 28 ++++++++++++++++++++++++++++
 16 files changed, 66 insertions(+), 1 deletion(-)

diff --git a/arch/alpha/include/uapi/asm/socket.h b/arch/alpha/include/uapi/asm/socket.h
index 9e46d6e..06b2ef9 100644
--- a/arch/alpha/include/uapi/asm/socket.h
+++ b/arch/alpha/include/uapi/asm/socket.h
@@ -97,4 +97,6 @@
 
 #define SO_CNX_ADVICE		53
 
+#define SO_NETPOLICY		54
+
 #endif /* _UAPI_ASM_SOCKET_H */
diff --git a/arch/avr32/include/uapi/asm/socket.h b/arch/avr32/include/uapi/asm/socket.h
index 1fd147f..24f85f0 100644
--- a/arch/avr32/include/uapi/asm/socket.h
+++ b/arch/avr32/include/uapi/asm/socket.h
@@ -90,4 +90,6 @@
 
 #define SO_CNX_ADVICE		53
 
+#define SO_NETPOLICY		54
+
 #endif /* _UAPI__ASM_AVR32_SOCKET_H */
diff --git a/arch/frv/include/uapi/asm/socket.h b/arch/frv/include/uapi/asm/socket.h
index afbc98f0..82c8d44 100644
--- a/arch/frv/include/uapi/asm/socket.h
+++ b/arch/frv/include/uapi/asm/socket.h
@@ -90,5 +90,7 @@
 
 #define SO_CNX_ADVICE		53
 
+#define SO_NETPOLICY		54
+
 #endif /* _ASM_SOCKET_H */
 
diff --git a/arch/ia64/include/uapi/asm/socket.h b/arch/ia64/include/uapi/asm/socket.h
index 0018fad..b99c1df 100644
--- a/arch/ia64/include/uapi/asm/socket.h
+++ b/arch/ia64/include/uapi/asm/socket.h
@@ -99,4 +99,6 @@
 
 #define SO_CNX_ADVICE		53
 
+#define SO_NETPOLICY		54
+
 #endif /* _ASM_IA64_SOCKET_H */
diff --git a/arch/m32r/include/uapi/asm/socket.h b/arch/m32r/include/uapi/asm/socket.h
index 5fe42fc..71a43ed 100644
--- a/arch/m32r/include/uapi/asm/socket.h
+++ b/arch/m32r/include/uapi/asm/socket.h
@@ -90,4 +90,6 @@
 
 #define SO_CNX_ADVICE		53
 
+#define SO_NETPOLICY		54
+
 #endif /* _ASM_M32R_SOCKET_H */
diff --git a/arch/mips/include/uapi/asm/socket.h b/arch/mips/include/uapi/asm/socket.h
index 2027240a..ce8b9ba 100644
--- a/arch/mips/include/uapi/asm/socket.h
+++ b/arch/mips/include/uapi/asm/socket.h
@@ -108,4 +108,6 @@
 
 #define SO_CNX_ADVICE		53
 
+#define SO_NETPOLICY		54
+
 #endif /* _UAPI_ASM_SOCKET_H */
diff --git a/arch/mn10300/include/uapi/asm/socket.h b/arch/mn10300/include/uapi/asm/socket.h
index 5129f23..c041265 100644
--- a/arch/mn10300/include/uapi/asm/socket.h
+++ b/arch/mn10300/include/uapi/asm/socket.h
@@ -90,4 +90,6 @@
 
 #define SO_CNX_ADVICE		53
 
+#define SO_NETPOLICY		54
+
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/parisc/include/uapi/asm/socket.h b/arch/parisc/include/uapi/asm/socket.h
index 9c935d7..2639dcd 100644
--- a/arch/parisc/include/uapi/asm/socket.h
+++ b/arch/parisc/include/uapi/asm/socket.h
@@ -89,4 +89,6 @@
 
 #define SO_CNX_ADVICE		0x402E
 
+#define SO_NETPOLICY		0x402F
+
 #endif /* _UAPI_ASM_SOCKET_H */
diff --git a/arch/powerpc/include/uapi/asm/socket.h b/arch/powerpc/include/uapi/asm/socket.h
index 1672e33..e04e3b6 100644
--- a/arch/powerpc/include/uapi/asm/socket.h
+++ b/arch/powerpc/include/uapi/asm/socket.h
@@ -97,4 +97,6 @@
 
 #define SO_CNX_ADVICE		53
 
+#define SO_NETPOLICY		54
+
 #endif	/* _ASM_POWERPC_SOCKET_H */
diff --git a/arch/s390/include/uapi/asm/socket.h b/arch/s390/include/uapi/asm/socket.h
index 41b51c2..d43b854 100644
--- a/arch/s390/include/uapi/asm/socket.h
+++ b/arch/s390/include/uapi/asm/socket.h
@@ -96,4 +96,6 @@
 
 #define SO_CNX_ADVICE		53
 
+#define SO_NETPOLICY		54
+
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/sparc/include/uapi/asm/socket.h b/arch/sparc/include/uapi/asm/socket.h
index 31aede3..94a2cdf 100644
--- a/arch/sparc/include/uapi/asm/socket.h
+++ b/arch/sparc/include/uapi/asm/socket.h
@@ -86,6 +86,8 @@
 
 #define SO_CNX_ADVICE		0x0037
 
+#define SO_NETPOLICY		0x0038
+
 /* Security levels - as per NRL IPv6 - don't actually do anything */
 #define SO_SECURITY_AUTHENTICATION		0x5001
 #define SO_SECURITY_ENCRYPTION_TRANSPORT	0x5002
diff --git a/arch/xtensa/include/uapi/asm/socket.h b/arch/xtensa/include/uapi/asm/socket.h
index 81435d9..97f1691 100644
--- a/arch/xtensa/include/uapi/asm/socket.h
+++ b/arch/xtensa/include/uapi/asm/socket.h
@@ -101,4 +101,6 @@
 
 #define SO_CNX_ADVICE		53
 
+#define SO_NETPOLICY		54
+
 #endif	/* _XTENSA_SOCKET_H */
diff --git a/include/net/request_sock.h b/include/net/request_sock.h
index 6ebe13e..1fa2d0e 100644
--- a/include/net/request_sock.h
+++ b/include/net/request_sock.h
@@ -101,7 +101,9 @@ reqsk_alloc(const struct request_sock_ops *ops, struct sock *sk_listener,
 	sk_tx_queue_clear(req_to_sk(req));
 	req->saved_syn = NULL;
 	atomic_set(&req->rsk_refcnt, 0);
-
+#ifdef CONFIG_NETPOLICY
+	memcpy(&req_to_sk(req)->sk_netpolicy, &sk_listener->sk_netpolicy, sizeof(sk_listener->sk_netpolicy));
+#endif
 	return req;
 }
 
diff --git a/include/net/sock.h b/include/net/sock.h
index 649d2a8..e4721de 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -70,6 +70,7 @@
 #include <net/checksum.h>
 #include <net/tcp_states.h>
 #include <linux/net_tstamp.h>
+#include <linux/netpolicy.h>
 
 /*
  * This structure really needs to be cleaned up.
@@ -141,6 +142,7 @@ typedef __u64 __bitwise __addrpair;
  *		%SO_OOBINLINE settings, %SO_TIMESTAMPING settings
  *	@skc_incoming_cpu: record/match cpu processing incoming packets
  *	@skc_refcnt: reference count
+ *	@skc_netpolicy: per socket net policy
  *
  *	This is the minimal network layer representation of sockets, the header
  *	for struct sock and struct inet_timewait_sock.
@@ -200,6 +202,10 @@ struct sock_common {
 		struct sock	*skc_listener; /* request_sock */
 		struct inet_timewait_death_row *skc_tw_dr; /* inet_timewait_sock */
 	};
+
+#ifdef CONFIG_NETPOLICY
+	struct netpolicy_reg    skc_netpolicy;
+#endif
 	/*
 	 * fields between dontcopy_begin/dontcopy_end
 	 * are not copied in sock_copy()
@@ -339,6 +345,9 @@ struct sock {
 #define sk_incoming_cpu		__sk_common.skc_incoming_cpu
 #define sk_flags		__sk_common.skc_flags
 #define sk_rxhash		__sk_common.skc_rxhash
+#ifdef CONFIG_NETPOLICY
+#define sk_netpolicy		__sk_common.skc_netpolicy
+#endif
 
 	socket_lock_t		sk_lock;
 	struct sk_buff_head	sk_receive_queue;
diff --git a/include/uapi/asm-generic/socket.h b/include/uapi/asm-generic/socket.h
index 67d632f..d2a5aeb 100644
--- a/include/uapi/asm-generic/socket.h
+++ b/include/uapi/asm-generic/socket.h
@@ -92,4 +92,6 @@
 
 #define SO_CNX_ADVICE		53
 
+#define SO_NETPOLICY		54
+
 #endif /* __ASM_GENERIC_SOCKET_H */
diff --git a/net/core/sock.c b/net/core/sock.c
index 08bf97e..6eaaa08 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1002,6 +1002,12 @@ set_rcvbuf:
 		if (val == 1)
 			dst_negative_advice(sk);
 		break;
+
+#ifdef CONFIG_NETPOLICY
+	case SO_NETPOLICY:
+		ret = netpolicy_register(&sk->sk_netpolicy, val);
+		break;
+#endif
 	default:
 		ret = -ENOPROTOOPT;
 		break;
@@ -1262,6 +1268,11 @@ int sock_getsockopt(struct socket *sock, int level, int optname,
 		v.val = sk->sk_incoming_cpu;
 		break;
 
+#ifdef CONFIG_NETPOLICY
+	case SO_NETPOLICY:
+		v.val = sk->sk_netpolicy.policy;
+		break;
+#endif
 	default:
 		/* We implement the SO_SNDLOWAT etc to not be settable
 		 * (1003.1g 7).
@@ -1423,6 +1434,12 @@ struct sock *sk_alloc(struct net *net, int family, gfp_t priority,
 
 		sock_update_classid(&sk->sk_cgrp_data);
 		sock_update_netprioidx(&sk->sk_cgrp_data);
+
+#ifdef CONFIG_NETPOLICY
+		sk->sk_netpolicy.dev = NULL;
+		sk->sk_netpolicy.ptr = (void *)sk;
+		sk->sk_netpolicy.policy = NET_POLICY_INVALID;
+#endif
 	}
 
 	return sk;
@@ -1460,6 +1477,10 @@ static void __sk_destruct(struct rcu_head *head)
 	put_pid(sk->sk_peer_pid);
 	if (likely(sk->sk_net_refcnt))
 		put_net(sock_net(sk));
+#ifdef CONFIG_NETPOLICY
+	if (is_net_policy_valid(sk->sk_netpolicy.policy))
+		netpolicy_unregister(&sk->sk_netpolicy);
+#endif
 	sk_prot_free(sk->sk_prot_creator, sk);
 }
 
@@ -1596,6 +1617,13 @@ struct sock *sk_clone_lock(const struct sock *sk, const gfp_t priority)
 		if (sock_needs_netstamp(sk) &&
 		    newsk->sk_flags & SK_FLAGS_TIMESTAMP)
 			net_enable_timestamp();
+
+#ifdef CONFIG_NETPOLICY
+		newsk->sk_netpolicy.ptr = (void *)newsk;
+		if (is_net_policy_valid(newsk->sk_netpolicy.policy))
+			netpolicy_register(&newsk->sk_netpolicy, newsk->sk_netpolicy.policy);
+
+#endif
 	}
 out:
 	return newsk;
-- 
2.5.5
