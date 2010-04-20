From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] NET: Fix an RCU warning in dev_pick_tx()
Date: Tue, 20 Apr 2010 18:03:34 +0200
Message-ID: <1271779414.7895.35.camel@edumazet-laptop>
References: <20100420102558.31923.91.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Howells <dhowells@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:62695 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753350Ab0DTQDm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Apr 2010 12:03:42 -0400
Received: by bwz19 with SMTP id 19so121876bwz.21
        for <netdev@vger.kernel.org>; Tue, 20 Apr 2010 09:03:40 -0700 (PDT)
In-Reply-To: <20100420102558.31923.91.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 20 avril 2010 =C3=A0 11:25 +0100, David Howells a =C3=A9crit :
> Fix the following RCU warning in dev_pick_tx():
>=20
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D
> [ INFO: suspicious rcu_dereference_check() usage. ]
> ---------------------------------------------------
> net/core/dev.c:1993 invoked rcu_dereference_check() without protectio=
n!
>=20
> other info that might help us debug this:
>=20
>=20
> rcu_scheduler_active =3D 1, debug_locks =3D 0
> 2 locks held by swapper/0:
>  #0:  (&idev->mc_ifc_timer){+.-...}, at: [<ffffffff81039e65>] run_tim=
er_softirq+0x17b/0x278
>  #1:  (rcu_read_lock_bh){.+....}, at: [<ffffffff812ea3eb>] dev_queue_=
xmit+0x14e/0x4dc
>=20
> stack backtrace:
> Pid: 0, comm: swapper Not tainted 2.6.34-rc5-cachefs #4
> Call Trace:
>  <IRQ>  [<ffffffff810516c4>] lockdep_rcu_dereference+0xaa/0xb2
>  [<ffffffff812ea4f6>] dev_queue_xmit+0x259/0x4dc
>  [<ffffffff812ea3eb>] ? dev_queue_xmit+0x14e/0x4dc
>  [<ffffffff81052324>] ? trace_hardirqs_on+0xd/0xf
>  [<ffffffff81035362>] ? local_bh_enable_ip+0xbc/0xc1
>  [<ffffffff812f0954>] neigh_resolve_output+0x24b/0x27c
>  [<ffffffff8134f673>] ip6_output_finish+0x7c/0xb4
>  [<ffffffff81350c34>] ip6_output2+0x256/0x261
>  [<ffffffff81052324>] ? trace_hardirqs_on+0xd/0xf
>  [<ffffffff813517fb>] ip6_output+0xbbc/0xbcb
>  [<ffffffff8135bc5d>] ? fib6_force_start_gc+0x2b/0x2d
>  [<ffffffff81368acb>] mld_sendpack+0x273/0x39d
>  [<ffffffff81368858>] ? mld_sendpack+0x0/0x39d
>  [<ffffffff81052099>] ? mark_held_locks+0x52/0x70
>  [<ffffffff813692fc>] mld_ifc_timer_expire+0x24f/0x288
>  [<ffffffff81039ed6>] run_timer_softirq+0x1ec/0x278
>  [<ffffffff81039e65>] ? run_timer_softirq+0x17b/0x278
>  [<ffffffff813690ad>] ? mld_ifc_timer_expire+0x0/0x288
>  [<ffffffff81035531>] ? __do_softirq+0x69/0x140
>  [<ffffffff8103556a>] __do_softirq+0xa2/0x140
>  [<ffffffff81002e0c>] call_softirq+0x1c/0x28
>  [<ffffffff81004b54>] do_softirq+0x38/0x80
>  [<ffffffff81034f06>] irq_exit+0x45/0x47
>  [<ffffffff810177c3>] smp_apic_timer_interrupt+0x88/0x96
>  [<ffffffff810028d3>] apic_timer_interrupt+0x13/0x20
>  <EOI>  [<ffffffff810488dd>] ? __atomic_notifier_call_chain+0x0/0x86
>  [<ffffffff810096bf>] ? mwait_idle+0x6e/0x78
>  [<ffffffff810096b6>] ? mwait_idle+0x65/0x78
>  [<ffffffff810011cb>] cpu_idle+0x4d/0x83
>  [<ffffffff81380b05>] rest_init+0xb9/0xc0
>  [<ffffffff81380a4c>] ? rest_init+0x0/0xc0
>  [<ffffffff8168dcf0>] start_kernel+0x392/0x39d
>  [<ffffffff8168d2a3>] x86_64_start_reservations+0xb3/0xb7
>  [<ffffffff8168d38b>] x86_64_start_kernel+0xe4/0xeb
>=20
> An rcu_dereference() should be an rcu_dereference_bh().
>=20
> Signed-off-by: David Howells <dhowells@redhat.com>
> ---
>=20

Absolutely right, thanks David

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

This might conflict with following commit in net-next-2.6, where I chos=
e
the rcu_dereference_check() alternative

commit b6c6712a42ca3f9fa7f4a3d7c40e3a9dd1fd9e03
Author: Eric Dumazet <eric.dumazet@gmail.com>
Date:   Thu Apr 8 23:03:29 2010 +0000

    net: sk_dst_cache RCUification
   =20
    With latest CONFIG_PROVE_RCU stuff, I felt more comfortable to make=
 this
    work.
   =20
    sk->sk_dst_cache is currently protected by a rwlock (sk_dst_lock)
   =20
    This rwlock is readlocked for a very small amount of time, and dst
    entries are already freed after RCU grace period. This calls for RC=
U
    again :)
   =20
    This patch converts sk_dst_lock to a spinlock, and use RCU for read=
ers.
   =20
    __sk_dst_get() is supposed to be called with rcu_read_lock() or if
    socket locked by user, so use appropriate rcu_dereference_check()
    condition (rcu_read_lock_held() || sock_owned_by_user(sk))
   =20
    This patch avoids two atomic ops per tx packet on UDP connected soc=
kets,
    for example, and permits sk_dst_lock to be much less dirtied.
   =20
    Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/include/net/dst.h b/include/net/dst.h
index ce078cd..aac5a5f 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -225,21 +225,6 @@ static inline void dst_confirm(struct dst_entry *d=
st)
 		neigh_confirm(dst->neighbour);
 }
=20
-static inline void dst_negative_advice(struct dst_entry **dst_p,
-				       struct sock *sk)
-{
-	struct dst_entry * dst =3D *dst_p;
-	if (dst && dst->ops->negative_advice) {
-		*dst_p =3D dst->ops->negative_advice(dst);
-
-		if (dst !=3D *dst_p) {
-			extern void sk_reset_txq(struct sock *sk);
-
-			sk_reset_txq(sk);
-		}
-	}
-}
-
 static inline void dst_link_failure(struct sk_buff *skb)
 {
 	struct dst_entry *dst =3D skb_dst(skb);
diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
index 68f6783..278312c 100644
--- a/include/net/ip6_route.h
+++ b/include/net/ip6_route.h
@@ -152,9 +152,9 @@ static inline void __ip6_dst_store(struct sock *sk,=
 struct dst_entry *dst,
 static inline void ip6_dst_store(struct sock *sk, struct dst_entry *ds=
t,
 				 struct in6_addr *daddr, struct in6_addr *saddr)
 {
-	write_lock(&sk->sk_dst_lock);
+	spin_lock(&sk->sk_dst_lock);
 	__ip6_dst_store(sk, dst, daddr, saddr);
-	write_unlock(&sk->sk_dst_lock);
+	spin_unlock(&sk->sk_dst_lock);
 }
=20
 static inline int ipv6_unicast_destination(struct sk_buff *skb)
diff --git a/include/net/sock.h b/include/net/sock.h
index b4603cd..56df440 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -262,7 +262,7 @@ struct sock {
 #ifdef CONFIG_XFRM
 	struct xfrm_policy	*sk_policy[2];
 #endif
-	rwlock_t		sk_dst_lock;
+	spinlock_t		sk_dst_lock;
 	atomic_t		sk_rmem_alloc;
 	atomic_t		sk_wmem_alloc;
 	atomic_t		sk_omem_alloc;
@@ -1192,7 +1192,8 @@ extern unsigned long sock_i_ino(struct sock *sk);
 static inline struct dst_entry *
 __sk_dst_get(struct sock *sk)
 {
-	return sk->sk_dst_cache;
+	return rcu_dereference_check(sk->sk_dst_cache, rcu_read_lock_held() |=
|
+						       sock_owned_by_user(sk));
 }
=20
 static inline struct dst_entry *
@@ -1200,50 +1201,62 @@ sk_dst_get(struct sock *sk)
 {
 	struct dst_entry *dst;
=20
-	read_lock(&sk->sk_dst_lock);
-	dst =3D sk->sk_dst_cache;
+	rcu_read_lock();
+	dst =3D rcu_dereference(sk->sk_dst_cache);
 	if (dst)
 		dst_hold(dst);
-	read_unlock(&sk->sk_dst_lock);
+	rcu_read_unlock();
 	return dst;
 }
=20
+extern void sk_reset_txq(struct sock *sk);
+
+static inline void dst_negative_advice(struct sock *sk)
+{
+	struct dst_entry *ndst, *dst =3D __sk_dst_get(sk);
+
+	if (dst && dst->ops->negative_advice) {
+		ndst =3D dst->ops->negative_advice(dst);
+
+		if (ndst !=3D dst) {
+			rcu_assign_pointer(sk->sk_dst_cache, ndst);
+			sk_reset_txq(sk);
+		}
+	}
+}
+
 static inline void
 __sk_dst_set(struct sock *sk, struct dst_entry *dst)
 {
 	struct dst_entry *old_dst;
=20
 	sk_tx_queue_clear(sk);
-	old_dst =3D sk->sk_dst_cache;
-	sk->sk_dst_cache =3D dst;
+	old_dst =3D rcu_dereference_check(sk->sk_dst_cache,
+					lockdep_is_held(&sk->sk_dst_lock));
+	rcu_assign_pointer(sk->sk_dst_cache, dst);
 	dst_release(old_dst);
 }
=20
 static inline void
 sk_dst_set(struct sock *sk, struct dst_entry *dst)
 {
-	write_lock(&sk->sk_dst_lock);
+	spin_lock(&sk->sk_dst_lock);
 	__sk_dst_set(sk, dst);
-	write_unlock(&sk->sk_dst_lock);
+	spin_unlock(&sk->sk_dst_lock);
 }
=20
 static inline void
 __sk_dst_reset(struct sock *sk)
 {
-	struct dst_entry *old_dst;
-
-	sk_tx_queue_clear(sk);
-	old_dst =3D sk->sk_dst_cache;
-	sk->sk_dst_cache =3D NULL;
-	dst_release(old_dst);
+	__sk_dst_set(sk, NULL);
 }
=20
 static inline void
 sk_dst_reset(struct sock *sk)
 {
-	write_lock(&sk->sk_dst_lock);
+	spin_lock(&sk->sk_dst_lock);
 	__sk_dst_reset(sk);
-	write_unlock(&sk->sk_dst_lock);
+	spin_unlock(&sk->sk_dst_lock);
 }
=20
 extern struct dst_entry *__sk_dst_check(struct sock *sk, u32 cookie);
diff --git a/net/core/dev.c b/net/core/dev.c
index 0eb79e3..ca4cdef 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2015,7 +2015,7 @@ static struct netdev_queue *dev_pick_tx(struct ne=
t_device *dev,
 			if (dev->real_num_tx_queues > 1)
 				queue_index =3D skb_tx_hash(dev, skb);
=20
-			if (sk && sk->sk_dst_cache)
+			if (sk && rcu_dereference_check(sk->sk_dst_cache, 1))
 				sk_tx_queue_set(sk, queue_index);
 		}
 	}
diff --git a/net/core/sock.c b/net/core/sock.c
index c5812bb..7effa1e 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -364,11 +364,11 @@ EXPORT_SYMBOL(sk_reset_txq);
=20
 struct dst_entry *__sk_dst_check(struct sock *sk, u32 cookie)
 {
-	struct dst_entry *dst =3D sk->sk_dst_cache;
+	struct dst_entry *dst =3D __sk_dst_get(sk);
=20
 	if (dst && dst->obsolete && dst->ops->check(dst, cookie) =3D=3D NULL)=
 {
 		sk_tx_queue_clear(sk);
-		sk->sk_dst_cache =3D NULL;
+		rcu_assign_pointer(sk->sk_dst_cache, NULL);
 		dst_release(dst);
 		return NULL;
 	}
@@ -1157,7 +1157,7 @@ struct sock *sk_clone(const struct sock *sk, cons=
t gfp_t priority)
 		skb_queue_head_init(&newsk->sk_async_wait_queue);
 #endif
=20
-		rwlock_init(&newsk->sk_dst_lock);
+		spin_lock_init(&newsk->sk_dst_lock);
 		rwlock_init(&newsk->sk_callback_lock);
 		lockdep_set_class_and_name(&newsk->sk_callback_lock,
 				af_callback_keys + newsk->sk_family,
@@ -1898,7 +1898,7 @@ void sock_init_data(struct socket *sock, struct s=
ock *sk)
 	} else
 		sk->sk_sleep	=3D	NULL;
=20
-	rwlock_init(&sk->sk_dst_lock);
+	spin_lock_init(&sk->sk_dst_lock);
 	rwlock_init(&sk->sk_callback_lock);
 	lockdep_set_class_and_name(&sk->sk_callback_lock,
 			af_callback_keys + sk->sk_family,
diff --git a/net/dccp/timer.c b/net/dccp/timer.c
index bbfeb5e..1a9aa05 100644
--- a/net/dccp/timer.c
+++ b/net/dccp/timer.c
@@ -38,7 +38,7 @@ static int dccp_write_timeout(struct sock *sk)
=20
 	if (sk->sk_state =3D=3D DCCP_REQUESTING || sk->sk_state =3D=3D DCCP_P=
ARTOPEN) {
 		if (icsk->icsk_retransmits !=3D 0)
-			dst_negative_advice(&sk->sk_dst_cache, sk);
+			dst_negative_advice(sk);
 		retry_until =3D icsk->icsk_syn_retries ?
 			    : sysctl_dccp_request_retries;
 	} else {
@@ -63,7 +63,7 @@ static int dccp_write_timeout(struct sock *sk)
 			   Golden words :-).
 		   */
=20
-			dst_negative_advice(&sk->sk_dst_cache, sk);
+			dst_negative_advice(sk);
 		}
=20
 		retry_until =3D sysctl_dccp_retries2;
diff --git a/net/decnet/af_decnet.c b/net/decnet/af_decnet.c
index 2b494fa..55e3b6b 100644
--- a/net/decnet/af_decnet.c
+++ b/net/decnet/af_decnet.c
@@ -446,7 +446,7 @@ static void dn_destruct(struct sock *sk)
 	skb_queue_purge(&scp->other_xmit_queue);
 	skb_queue_purge(&scp->other_receive_queue);
=20
-	dst_release(xchg(&sk->sk_dst_cache, NULL));
+	dst_release(rcu_dereference_check(sk->sk_dst_cache, 1));
 }
=20
 static int dn_memory_pressure;
@@ -1105,7 +1105,7 @@ static int dn_accept(struct socket *sock, struct =
socket *newsock, int flags)
 	release_sock(sk);
=20
 	dst =3D skb_dst(skb);
-	dst_release(xchg(&newsk->sk_dst_cache, dst));
+	sk_dst_set(newsk, dst);
 	skb_dst_set(skb, NULL);
=20
 	DN_SK(newsk)->state        =3D DN_CR;
@@ -1956,7 +1956,7 @@ static int dn_sendmsg(struct kiocb *iocb, struct =
socket *sock,
 	}
=20
 	if ((flags & MSG_TRYHARD) && sk->sk_dst_cache)
-		dst_negative_advice(&sk->sk_dst_cache, sk);
+		dst_negative_advice(sk);
=20
 	mss =3D scp->segsize_rem;
 	fctype =3D scp->services_rem & NSP_FC_MASK;
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index a0beb32..193dcd6 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -154,7 +154,7 @@ void inet_sock_destruct(struct sock *sk)
 	WARN_ON(sk->sk_forward_alloc);
=20
 	kfree(inet->opt);
-	dst_release(sk->sk_dst_cache);
+	dst_release(rcu_dereference_check(sk->sk_dst_cache, 1));
 	sk_refcnt_debug_dec(sk);
 }
 EXPORT_SYMBOL(inet_sock_destruct);
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 4000b10..ae3ec15 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3710,7 +3710,7 @@ static int tcp_ack(struct sock *sk, struct sk_buf=
f *skb, int flag)
 	}
=20
 	if ((flag & FLAG_FORWARD_PROGRESS) || !(flag & FLAG_NOT_DUP))
-		dst_confirm(sk->sk_dst_cache);
+		dst_confirm(__sk_dst_get(sk));
=20
 	return 1;
=20
@@ -5833,7 +5833,7 @@ int tcp_rcv_state_process(struct sock *sk, struct=
 sk_buff *skb,
 			if (tp->snd_una =3D=3D tp->write_seq) {
 				tcp_set_state(sk, TCP_FIN_WAIT2);
 				sk->sk_shutdown |=3D SEND_SHUTDOWN;
-				dst_confirm(sk->sk_dst_cache);
+				dst_confirm(__sk_dst_get(sk));
=20
 				if (!sock_flag(sk, SOCK_DEAD))
 					/* Wake up lingering close() */
diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index 8a0ab29..c732be0 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -172,14 +172,14 @@ static int tcp_write_timeout(struct sock *sk)
=20
 	if ((1 << sk->sk_state) & (TCPF_SYN_SENT | TCPF_SYN_RECV)) {
 		if (icsk->icsk_retransmits)
-			dst_negative_advice(&sk->sk_dst_cache, sk);
+			dst_negative_advice(sk);
 		retry_until =3D icsk->icsk_syn_retries ? : sysctl_tcp_syn_retries;
 	} else {
 		if (retransmits_timed_out(sk, sysctl_tcp_retries1)) {
 			/* Black hole detection */
 			tcp_mtu_probing(icsk, sk);
=20
-			dst_negative_advice(&sk->sk_dst_cache, sk);
+			dst_negative_advice(sk);
 		}
=20
 		retry_until =3D sysctl_tcp_retries2;
diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index 33f60fc..1160400 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -114,9 +114,9 @@ struct ipv6_txoptions *ipv6_update_options(struct s=
ock *sk,
 		}
 		opt =3D xchg(&inet6_sk(sk)->opt, opt);
 	} else {
-		write_lock(&sk->sk_dst_lock);
+		spin_lock(&sk->sk_dst_lock);
 		opt =3D xchg(&inet6_sk(sk)->opt, opt);
-		write_unlock(&sk->sk_dst_lock);
+		spin_unlock(&sk->sk_dst_lock);
 	}
 	sk_dst_reset(sk);
=20
@@ -971,14 +971,13 @@ static int do_ipv6_getsockopt(struct sock *sk, in=
t level, int optname,
 	case IPV6_MTU:
 	{
 		struct dst_entry *dst;
+
 		val =3D 0;
-		lock_sock(sk);
-		dst =3D sk_dst_get(sk);
-		if (dst) {
+		rcu_read_lock();
+		dst =3D __sk_dst_get(sk);
+		if (dst)
 			val =3D dst_mtu(dst);
-			dst_release(dst);
-		}
-		release_sock(sk);
+		rcu_read_unlock();
 		if (!val)
 			return -ENOTCONN;
 		break;
@@ -1066,12 +1065,14 @@ static int do_ipv6_getsockopt(struct sock *sk, =
int level, int optname,
 		else
 			val =3D np->mcast_hops;
=20
-		dst =3D sk_dst_get(sk);
-		if (dst) {
-			if (val < 0)
+		if (val < 0) {
+			rcu_read_lock();
+			dst =3D __sk_dst_get(sk);
+			if (dst)
 				val =3D ip6_dst_hoplimit(dst);
-			dst_release(dst);
+			rcu_read_unlock();
 		}
+
 		if (val < 0)
 			val =3D sock_net(sk)->ipv6.devconf_all->hop_limit;
 		break;




