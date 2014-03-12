From: Vivek Goyal <vgoyal@redhat.com>
Subject: [PATCH 2/2] net: Implement SO_PEERCGROUP
Date: Wed, 12 Mar 2014 16:46:03 -0400
Message-ID: <1394657163-7472-3-git-send-email-vgoyal@redhat.com>
References: <1394657163-7472-1-git-send-email-vgoyal@redhat.com>
Cc: ssorce@redhat.com, jkaluza@redhat.com, lpoetter@redhat.com,
	kay@redhat.com, Vivek Goyal <vgoyal@redhat.com>
To: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org,
	netdev@vger.kernel.org, davem@davemloft.net, tj@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394657163-7472-1-git-send-email-vgoyal@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Implement SO_PEERCGROUP along the lines of SO_PEERCRED. This returns the
cgroup of first mounted hierarchy of the task. For the case of client,
it represents the cgroup of client at the time of opening the connection.
After that client cgroup might change.

Signed-off-by: Vivek Goyal <vgoyal@redhat.com>
---
 arch/alpha/include/uapi/asm/socket.h   |  1 +
 arch/avr32/include/uapi/asm/socket.h   |  1 +
 arch/cris/include/uapi/asm/socket.h    |  2 ++
 arch/frv/include/uapi/asm/socket.h     |  1 +
 arch/ia64/include/uapi/asm/socket.h    |  2 ++
 arch/m32r/include/uapi/asm/socket.h    |  1 +
 arch/mips/include/uapi/asm/socket.h    |  1 +
 arch/mn10300/include/uapi/asm/socket.h |  1 +
 arch/parisc/include/uapi/asm/socket.h  |  1 +
 arch/powerpc/include/uapi/asm/socket.h |  1 +
 arch/s390/include/uapi/asm/socket.h    |  1 +
 arch/sparc/include/uapi/asm/socket.h   |  2 ++
 arch/xtensa/include/uapi/asm/socket.h  |  1 +
 include/net/sock.h                     |  1 +
 include/uapi/asm-generic/socket.h      |  2 ++
 net/core/sock.c                        | 19 ++++++++++++++
 net/unix/af_unix.c                     | 48 ++++++++++++++++++++++++++++++++++
 17 files changed, 86 insertions(+)

diff --git a/arch/alpha/include/uapi/asm/socket.h b/arch/alpha/include/uapi/asm/socket.h
index 3de1394..7178353 100644
--- a/arch/alpha/include/uapi/asm/socket.h
+++ b/arch/alpha/include/uapi/asm/socket.h
@@ -87,4 +87,5 @@
 
 #define SO_BPF_EXTENSIONS	48
 
+#define SO_PEERCGROUP		49
 #endif /* _UAPI_ASM_SOCKET_H */
diff --git a/arch/avr32/include/uapi/asm/socket.h b/arch/avr32/include/uapi/asm/socket.h
index 6e6cd15..486212b 100644
--- a/arch/avr32/include/uapi/asm/socket.h
+++ b/arch/avr32/include/uapi/asm/socket.h
@@ -80,4 +80,5 @@
 
 #define SO_BPF_EXTENSIONS	48
 
+#define SO_PEERCGROUP		49
 #endif /* _UAPI__ASM_AVR32_SOCKET_H */
diff --git a/arch/cris/include/uapi/asm/socket.h b/arch/cris/include/uapi/asm/socket.h
index ed94e5e..89a09e3 100644
--- a/arch/cris/include/uapi/asm/socket.h
+++ b/arch/cris/include/uapi/asm/socket.h
@@ -82,6 +82,8 @@
 
 #define SO_BPF_EXTENSIONS	48
 
+#define SO_PEERCGROUP		49
+
 #endif /* _ASM_SOCKET_H */
 
 
diff --git a/arch/frv/include/uapi/asm/socket.h b/arch/frv/include/uapi/asm/socket.h
index ca2c6e6..c4d90bc 100644
--- a/arch/frv/include/uapi/asm/socket.h
+++ b/arch/frv/include/uapi/asm/socket.h
@@ -80,5 +80,6 @@
 
 #define SO_BPF_EXTENSIONS	48
 
+#define SO_PEERCGROUP		49
 #endif /* _ASM_SOCKET_H */
 
diff --git a/arch/ia64/include/uapi/asm/socket.h b/arch/ia64/include/uapi/asm/socket.h
index a1b49ba..62c196d 100644
--- a/arch/ia64/include/uapi/asm/socket.h
+++ b/arch/ia64/include/uapi/asm/socket.h
@@ -89,4 +89,6 @@
 
 #define SO_BPF_EXTENSIONS	48
 
+#define SO_PEERCGROUP		49
+
 #endif /* _ASM_IA64_SOCKET_H */
diff --git a/arch/m32r/include/uapi/asm/socket.h b/arch/m32r/include/uapi/asm/socket.h
index 6c9a24b..6e04a7d 100644
--- a/arch/m32r/include/uapi/asm/socket.h
+++ b/arch/m32r/include/uapi/asm/socket.h
@@ -80,4 +80,5 @@
 
 #define SO_BPF_EXTENSIONS	48
 
+#define SO_PEERCGROUP		49
 #endif /* _ASM_M32R_SOCKET_H */
diff --git a/arch/mips/include/uapi/asm/socket.h b/arch/mips/include/uapi/asm/socket.h
index a14baa2..cfbd84b 100644
--- a/arch/mips/include/uapi/asm/socket.h
+++ b/arch/mips/include/uapi/asm/socket.h
@@ -98,4 +98,5 @@
 
 #define SO_BPF_EXTENSIONS	48
 
+#define SO_PEERCGROUP		49
 #endif /* _UAPI_ASM_SOCKET_H */
diff --git a/arch/mn10300/include/uapi/asm/socket.h b/arch/mn10300/include/uapi/asm/socket.h
index 6aa3ce1..73467fe 100644
--- a/arch/mn10300/include/uapi/asm/socket.h
+++ b/arch/mn10300/include/uapi/asm/socket.h
@@ -80,4 +80,5 @@
 
 #define SO_BPF_EXTENSIONS	48
 
+#define SO_PEERCGROUP		49
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/parisc/include/uapi/asm/socket.h b/arch/parisc/include/uapi/asm/socket.h
index fe35cea..24d8913 100644
--- a/arch/parisc/include/uapi/asm/socket.h
+++ b/arch/parisc/include/uapi/asm/socket.h
@@ -79,4 +79,5 @@
 
 #define SO_BPF_EXTENSIONS	0x4029
 
+#define SO_PEERCGROUP           0x402a
 #endif /* _UAPI_ASM_SOCKET_H */
diff --git a/arch/powerpc/include/uapi/asm/socket.h b/arch/powerpc/include/uapi/asm/socket.h
index a9c3e2e..50106be 100644
--- a/arch/powerpc/include/uapi/asm/socket.h
+++ b/arch/powerpc/include/uapi/asm/socket.h
@@ -87,4 +87,5 @@
 
 #define SO_BPF_EXTENSIONS	48
 
+#define SO_PEERCGROUP		49
 #endif	/* _ASM_POWERPC_SOCKET_H */
diff --git a/arch/s390/include/uapi/asm/socket.h b/arch/s390/include/uapi/asm/socket.h
index e031332..4ae2f3c 100644
--- a/arch/s390/include/uapi/asm/socket.h
+++ b/arch/s390/include/uapi/asm/socket.h
@@ -86,4 +86,5 @@
 
 #define SO_BPF_EXTENSIONS	48
 
+#define SO_PEERCGROUP		49
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/sparc/include/uapi/asm/socket.h b/arch/sparc/include/uapi/asm/socket.h
index 54d9608..1056168 100644
--- a/arch/sparc/include/uapi/asm/socket.h
+++ b/arch/sparc/include/uapi/asm/socket.h
@@ -76,6 +76,8 @@
 
 #define SO_BPF_EXTENSIONS	0x0032
 
+#define SO_PEERCGROUP           0x0033
+
 /* Security levels - as per NRL IPv6 - don't actually do anything */
 #define SO_SECURITY_AUTHENTICATION		0x5001
 #define SO_SECURITY_ENCRYPTION_TRANSPORT	0x5002
diff --git a/arch/xtensa/include/uapi/asm/socket.h b/arch/xtensa/include/uapi/asm/socket.h
index 39acec0..947bc6e 100644
--- a/arch/xtensa/include/uapi/asm/socket.h
+++ b/arch/xtensa/include/uapi/asm/socket.h
@@ -91,4 +91,5 @@
 
 #define SO_BPF_EXTENSIONS	48
 
+#define SO_PEERCGROUP		49
 #endif	/* _XTENSA_SOCKET_H */
diff --git a/include/net/sock.h b/include/net/sock.h
index 5c3f7c3..d594575 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -424,6 +424,7 @@ struct sock {
 	int			(*sk_backlog_rcv)(struct sock *sk,
 						  struct sk_buff *skb);
 	void                    (*sk_destruct)(struct sock *sk);
+	char			*cgroup_path;
 };
 
 #define __sk_user_data(sk) ((*((void __rcu **)&(sk)->sk_user_data)))
diff --git a/include/uapi/asm-generic/socket.h b/include/uapi/asm-generic/socket.h
index ea0796b..e86be5b 100644
--- a/include/uapi/asm-generic/socket.h
+++ b/include/uapi/asm-generic/socket.h
@@ -82,4 +82,6 @@
 
 #define SO_BPF_EXTENSIONS	48
 
+#define SO_PEERCGROUP		49
+
 #endif /* __ASM_GENERIC_SOCKET_H */
diff --git a/net/core/sock.c b/net/core/sock.c
index 5b6a943..0827a3c 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1185,6 +1185,24 @@ int sock_getsockopt(struct socket *sock, int level, int optname,
 		v.val = sk->sk_max_pacing_rate;
 		break;
 
+	case SO_PEERCGROUP:
+	{
+		int cgroup_path_len;
+
+		if (!sk->cgroup_path) {
+			len = 0;
+			goto lenout;
+		}
+
+		cgroup_path_len = strlen(sk->cgroup_path) + 1;
+
+		if (len > cgroup_path_len)
+			len = cgroup_path_len;
+		if (copy_to_user(optval, sk->cgroup_path, len))
+			return -EFAULT;
+		goto lenout;
+	}
+
 	default:
 		return -ENOPROTOOPT;
 	}
@@ -1378,6 +1396,7 @@ static void __sk_free(struct sock *sk)
 		put_cred(sk->sk_peer_cred);
 	put_pid(sk->sk_peer_pid);
 	put_net(sock_net(sk));
+	kfree(sk->cgroup_path);
 	sk_prot_free(sk->sk_prot_creator, sk);
 }
 
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 29fc8be..6921ae6 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -474,6 +474,37 @@ static void copy_peercred(struct sock *sk, struct sock *peersk)
 	sk->sk_peer_cred = get_cred(peersk->sk_peer_cred);
 }
 
+static int alloc_cgroup_path(struct sock *sk)
+{
+#ifdef CONFIG_CGROUPS
+	if (sk->cgroup_path)
+		return 0;
+
+	sk->cgroup_path = kzalloc(PATH_MAX, GFP_KERNEL);
+	if (!sk->cgroup_path)
+		return -ENOMEM;
+
+#endif
+	return 0;
+}
+
+static int init_peercgroup(struct sock *sk)
+{
+	int ret;
+
+	ret = alloc_cgroup_path(sk);
+	if (ret)
+		return ret;
+
+	return task_cgroup_path(current, sk->cgroup_path, PATH_MAX);
+}
+
+static void copy_peercgroup(struct sock *sk, struct sock *peersk)
+{
+	if (sk->cgroup_path)
+		strncpy(sk->cgroup_path, peersk->cgroup_path, PATH_MAX);
+}
+
 static int unix_listen(struct socket *sock, int backlog)
 {
 	int err;
@@ -487,6 +518,12 @@ static int unix_listen(struct socket *sock, int backlog)
 	err = -EINVAL;
 	if (!u->addr)
 		goto out;	/* No listens on an unbound socket */
+
+	err = init_peercgroup(sk);
+	if (err)
+		goto out;
+
+	err = -EINVAL;
 	unix_state_lock(sk);
 	if (sk->sk_state != TCP_CLOSE && sk->sk_state != TCP_LISTEN)
 		goto out_unlock;
@@ -1098,6 +1135,16 @@ static int unix_stream_connect(struct socket *sock, struct sockaddr *uaddr,
 	if (newsk == NULL)
 		goto out;
 
+	err = init_peercgroup(newsk);
+	if (err)
+		goto out;
+
+	err = alloc_cgroup_path(sk);
+	if (err)
+		goto out;
+
+	err = -ENOMEM;
+
 	/* Allocate skb for sending to listening sock */
 	skb = sock_wmalloc(newsk, 1, 0, GFP_KERNEL);
 	if (skb == NULL)
@@ -1203,6 +1250,7 @@ restart:
 
 	/* Set credentials */
 	copy_peercred(sk, other);
+	copy_peercgroup(sk, other);
 
 	sock->state	= SS_CONNECTED;
 	sk->sk_state	= TCP_ESTABLISHED;
-- 
1.8.5.3
