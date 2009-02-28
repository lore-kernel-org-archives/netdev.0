From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: Multicast packet loss
Date: Sat, 28 Feb 2009 09:51:11 +0100
Message-ID: <49A8FAFF.7060104@cosmosbay.com>
References: <49838213.90700@cosmosbay.com> <49859847.9010206@cosmosbay.com> <20090202134523.GA13369@hmsreliant.think-freely.org> <498725F4.2010205@cosmosbay.com> <20090202182212.GA17950@hmsreliant.think-freely.org> <loom.20090202T194942-55@post.gmane.org> <498757AA.8010101@cosmosbay.com> <4987610D.6040902@athenacr.com> <4987663D.6080802@cosmosbay.com> <4988803E.2020009@athenacr.com> <20090204012144.GC3650@localhost.localdomain> <49A6CE39.5050200@athenacr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Christoph Lameter <cl@linux-foundation.org>
To: Kenny Chang <kchang@athenacr.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:36361 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751652AbZB1Ivh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Feb 2009 03:51:37 -0500
In-Reply-To: <49A6CE39.5050200@athenacr.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kenny Chang a =E9crit :
> It's been a while since I updated this thread.  We've been running
> through the different suggestions and tabulating their effects, as we=
ll
> as trying out an Intel card.  The short story is that setting affinit=
y
> and MSI works to some extent, and the Intel card doesn't seem to chan=
ge
> things significantly.  The results don't seem consistent enough for u=
s
> to be able to point to a smoking gun.
>=20
> It does look like the 2.6.29-rc4 kernel performs okay with the Intel
> card, but this is not a real-time build and it's not likely to be in =
a
> supported Ubuntu distribution real soon.  We've reached the point whe=
re
> we'd like to look for an expert dedicated to work on this problem for=
 a
> period of time.  The final result being some sort of solution to prod=
uce
> a realtime configuration with a reasonably "aged" kernel (.24~.28) th=
at
> has multicast performance greater than or equal to that of 2.6.15.
>=20
> If anybody is interested in devoting some compensated time to this
> issue, we're offering up a bounty:
> http://www.athenacr.com/bounties/multicast-performance/
>=20
> For completeness, here's the table of our experiment results:
>=20
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D =3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D =3D=3D=3D=3D=3D=3D=3D=
=3D=3D =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D =3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D =3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> Kernel                 flavor             IRQ       affinity   *4x
> mcasttest*  *5x mcasttest* *6x mcasttest*  *Mtools2* [4]_
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D =3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D =3D=3D=3D=3D=3D=3D=3D=
=3D=3D =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D =3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D =3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> Intel
> e1000e                                                               =
                                                 =20
>=20
> -----------------------------------------+---------+----------+------=
---------+--------------+--------------+-----------------
>=20
> 2.6.24.19              rt                |          any       |
> OK              Maybe          X                           =20
> 2.6.24.19              rt                |          CPU0      |
> OK              OK             X                           =20
> 2.6.24.19              generic           |          any       |
> X                                                          =20
> 2.6.24.19              generic           |          CPU0      |
> OK                                                         =20
> 2.6.29-rc3             vanilla-server    |          any       |
> X                                                          =20
> 2.6.29-rc3             vanilla-server    |          CPU0      |
> OK                                                         =20
> 2.6.29-rc4             vanilla-generic   |          any       |
> X                                             OK           =20
> 2.6.29-rc4             vanilla-generic   |          CPU0      | OK =20
>           OK             OK [5]_        OK           =20
> -----------------------------------------+---------+----------+------=
---------+--------------+--------------+-----------------
>=20
> Broadcom
> BNX2                                                                 =
                                              =20
>=20
> -----------------------------------------+---------+----------+------=
---------+--------------+--------------+-----------------
>=20
> 2.6.24-19              rt                | MSI      any       |
> OK              OK             X                           =20
> 2.6.24-19              rt                | MSI      CPU0      |
> OK              Maybe          X                           =20
> 2.6.24-19              rt                | APIC     any       |
> OK              OK             X                           =20
> 2.6.24-19              rt                | APIC     CPU0      |
> OK              Maybe          X                           =20
> 2.6.24-19-bnx-latest   rt                | APIC     CPU0      |
> OK              X                                          =20
> 2.6.24-19              server            | MSI      any       |
> X                                                          =20
> 2.6.24-19              server            | MSI      CPU0      |
> OK                                                         =20
> 2.6.24-19              generic           | APIC     any       |
> X                                                          =20
> 2.6.24-19              generic           | APIC     CPU0      |
> OK                                                         =20
> 2.6.27-11              generic           | APIC     any       |
> X                                                          =20
> 2.6.27-11              generic           | APIC     CPU0      |
> OK              10% drop                                    =20
> 2.6.28-8               generic           | APIC     any       |
> OK              X                                           =20
> 2.6.28-8               generic           | APIC     CPU0      |
> OK              OK             0.5% drop                    =20
> 2.6.29-rc3             vanilla-server    | MSI      any       |
> X                                                          =20
> 2.6.29-rc3             vanilla-server    | MSI      CPU0      |
> X                                                          =20
> 2.6.29-rc3             vanilla-server    | APIC     any       |
> OK              X                                          =20
> 2.6.29-rc3             vanilla-server    | APIC     CPU0      |
> OK              OK                                         =20
> 2.6.29-rc4             vanilla-generic   | APIC     any       |
> X                                                          =20
> 2.6.29-rc4             vanilla-generic   | APIC     CPU0      |
> OK              3% drop        10% drop       X            =20
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D+=3D=3D=3D=3D=3D=
=3D=3D=3D=3D+=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D+=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D+=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D+=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D+=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D
>=20
> * [4] MTools2 is a test from 29West: http://www.29west.com/docs/TestN=
et/
> * [5] In 5 trials, 1 of the trials dropped 2%, 4 of the trials droppe=
d
> nothing.
>=20
> Kenny
>=20

Hi Kenny

I am investigating how to reduce contention (and schedule() calls) on t=
his workload.

=46ollowing patch already gave me less packet drops (but not yet *perfe=
ct*)
(10% packet loss instead of 30%, if 8 receivers on my 8 cpus machine)


David, this is a preliminary work, not meant for inclusion as is,
comments are welcome.

Thank you

[PATCH] net: sk_forward_alloc becomes an atomic_t

Commit 95766fff6b9a78d11fc2d3812dd035381690b55d
(UDP: Add memory accounting) introduced a regression for high rate UDP =
flows,
because of extra lock_sock() in udp_recvmsg()

In order to reduce need for lock_sock() in UDP receive path, we might n=
eed
to declare sk_forward_alloc as an atomic_t.

udp_recvmsg() can avoid a lock_sock()/release_sock() pair.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
---
 include/net/sock.h   |   14 +++++++-------
 net/core/sock.c      |   31 +++++++++++++++++++------------
 net/core/stream.c    |    2 +-
 net/ipv4/af_inet.c   |    2 +-
 net/ipv4/inet_diag.c |    2 +-
 net/ipv4/tcp_input.c |    2 +-
 net/ipv4/udp.c       |    2 --
 net/ipv6/udp.c       |    2 --
 net/sched/em_meta.c  |    2 +-
 9 files changed, 31 insertions(+), 28 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 4bb1ff9..c4befb9 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -250,7 +250,7 @@ struct sock {
 	struct sk_buff_head	sk_async_wait_queue;
 #endif
 	int			sk_wmem_queued;
-	int			sk_forward_alloc;
+	atomic_t		sk_forward_alloc;
 	gfp_t			sk_allocation;
 	int			sk_route_caps;
 	int			sk_gso_type;
@@ -823,7 +823,7 @@ static inline int sk_wmem_schedule(struct sock *sk,=
 int size)
 {
 	if (!sk_has_account(sk))
 		return 1;
-	return size <=3D sk->sk_forward_alloc ||
+	return size <=3D atomic_read(&sk->sk_forward_alloc) ||
 		__sk_mem_schedule(sk, size, SK_MEM_SEND);
 }
=20
@@ -831,7 +831,7 @@ static inline int sk_rmem_schedule(struct sock *sk,=
 int size)
 {
 	if (!sk_has_account(sk))
 		return 1;
-	return size <=3D sk->sk_forward_alloc ||
+	return size <=3D atomic_read(&sk->sk_forward_alloc) ||
 		__sk_mem_schedule(sk, size, SK_MEM_RECV);
 }
=20
@@ -839,7 +839,7 @@ static inline void sk_mem_reclaim(struct sock *sk)
 {
 	if (!sk_has_account(sk))
 		return;
-	if (sk->sk_forward_alloc >=3D SK_MEM_QUANTUM)
+	if (atomic_read(&sk->sk_forward_alloc) >=3D SK_MEM_QUANTUM)
 		__sk_mem_reclaim(sk);
 }
=20
@@ -847,7 +847,7 @@ static inline void sk_mem_reclaim_partial(struct so=
ck *sk)
 {
 	if (!sk_has_account(sk))
 		return;
-	if (sk->sk_forward_alloc > SK_MEM_QUANTUM)
+	if (atomic_read(&sk->sk_forward_alloc) > SK_MEM_QUANTUM)
 		__sk_mem_reclaim(sk);
 }
=20
@@ -855,14 +855,14 @@ static inline void sk_mem_charge(struct sock *sk,=
 int size)
 {
 	if (!sk_has_account(sk))
 		return;
-	sk->sk_forward_alloc -=3D size;
+	atomic_sub(size, &sk->sk_forward_alloc);
 }
=20
 static inline void sk_mem_uncharge(struct sock *sk, int size)
 {
 	if (!sk_has_account(sk))
 		return;
-	sk->sk_forward_alloc +=3D size;
+	atomic_add(size, &sk->sk_forward_alloc);
 }
=20
 static inline void sk_wmem_free_skb(struct sock *sk, struct sk_buff *s=
kb)
diff --git a/net/core/sock.c b/net/core/sock.c
index 0620046..8489105 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1081,7 +1081,7 @@ struct sock *sk_clone(const struct sock *sk, cons=
t gfp_t priority)
=20
 		newsk->sk_dst_cache	=3D NULL;
 		newsk->sk_wmem_queued	=3D 0;
-		newsk->sk_forward_alloc =3D 0;
+		atomic_set(&newsk->sk_forward_alloc, 0);
 		newsk->sk_send_head	=3D NULL;
 		newsk->sk_userlocks	=3D sk->sk_userlocks & ~SOCK_BINDPORT_LOCK;
=20
@@ -1479,7 +1479,7 @@ int __sk_mem_schedule(struct sock *sk, int size, =
int kind)
 	int amt =3D sk_mem_pages(size);
 	int allocated;
=20
-	sk->sk_forward_alloc +=3D amt * SK_MEM_QUANTUM;
+	atomic_add(amt * SK_MEM_QUANTUM, &sk->sk_forward_alloc);
 	allocated =3D atomic_add_return(amt, prot->memory_allocated);
=20
 	/* Under limit. */
@@ -1520,7 +1520,7 @@ int __sk_mem_schedule(struct sock *sk, int size, =
int kind)
 		if (prot->sysctl_mem[2] > alloc *
 		    sk_mem_pages(sk->sk_wmem_queued +
 				 atomic_read(&sk->sk_rmem_alloc) +
-				 sk->sk_forward_alloc))
+				 atomic_read(&sk->sk_forward_alloc)))
 			return 1;
 	}
=20
@@ -1537,7 +1537,7 @@ suppress_allocation:
 	}
=20
 	/* Alas. Undo changes. */
-	sk->sk_forward_alloc -=3D amt * SK_MEM_QUANTUM;
+	atomic_sub(amt * SK_MEM_QUANTUM, &sk->sk_forward_alloc);
 	atomic_sub(amt, prot->memory_allocated);
 	return 0;
 }
@@ -1551,14 +1551,21 @@ EXPORT_SYMBOL(__sk_mem_schedule);
 void __sk_mem_reclaim(struct sock *sk)
 {
 	struct proto *prot =3D sk->sk_prot;
-
-	atomic_sub(sk->sk_forward_alloc >> SK_MEM_QUANTUM_SHIFT,
-		   prot->memory_allocated);
-	sk->sk_forward_alloc &=3D SK_MEM_QUANTUM - 1;
-
-	if (prot->memory_pressure && *prot->memory_pressure &&
-	    (atomic_read(prot->memory_allocated) < prot->sysctl_mem[0]))
-		*prot->memory_pressure =3D 0;
+	int val =3D atomic_read(&sk->sk_forward_alloc);
+
+begin:
+	val =3D atomic_read(&sk->sk_forward_alloc);
+	if (val >=3D SK_MEM_QUANTUM) {
+		if (atomic_cmpxchg(&sk->sk_forward_alloc, val,
+				   val & (SK_MEM_QUANTUM - 1)) !=3D val)
+			goto begin;
+		atomic_sub(val >> SK_MEM_QUANTUM_SHIFT,
+			   prot->memory_allocated);
+
+		if (prot->memory_pressure && *prot->memory_pressure &&
+		    (atomic_read(prot->memory_allocated) < prot->sysctl_mem[0]))
+			*prot->memory_pressure =3D 0;
+	}
 }
=20
 EXPORT_SYMBOL(__sk_mem_reclaim);
diff --git a/net/core/stream.c b/net/core/stream.c
index 8727cea..4d04d28 100644
--- a/net/core/stream.c
+++ b/net/core/stream.c
@@ -198,7 +198,7 @@ void sk_stream_kill_queues(struct sock *sk)
 	sk_mem_reclaim(sk);
=20
 	WARN_ON(sk->sk_wmem_queued);
-	WARN_ON(sk->sk_forward_alloc);
+	WARN_ON(atomic_read(&sk->sk_forward_alloc));
=20
 	/* It is _impossible_ for the backlog to contain anything
 	 * when we get here.  All user references to this socket
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 627be4d..7a1475c 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -152,7 +152,7 @@ void inet_sock_destruct(struct sock *sk)
 	WARN_ON(atomic_read(&sk->sk_rmem_alloc));
 	WARN_ON(atomic_read(&sk->sk_wmem_alloc));
 	WARN_ON(sk->sk_wmem_queued);
-	WARN_ON(sk->sk_forward_alloc);
+	WARN_ON(atomic_read(&sk->sk_forward_alloc));
=20
 	kfree(inet->opt);
 	dst_release(sk->sk_dst_cache);
diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index 588a779..903ad66 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -158,7 +158,7 @@ static int inet_csk_diag_fill(struct sock *sk,
 	if (minfo) {
 		minfo->idiag_rmem =3D atomic_read(&sk->sk_rmem_alloc);
 		minfo->idiag_wmem =3D sk->sk_wmem_queued;
-		minfo->idiag_fmem =3D sk->sk_forward_alloc;
+		minfo->idiag_fmem =3D atomic_read(&sk->sk_forward_alloc);
 		minfo->idiag_tmem =3D atomic_read(&sk->sk_wmem_alloc);
 	}
=20
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index a6961d7..5e08f37 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -5258,7 +5258,7 @@ int tcp_rcv_established(struct sock *sk, struct s=
k_buff *skb,
=20
 				tcp_rcv_rtt_measure_ts(sk, skb);
=20
-				if ((int)skb->truesize > sk->sk_forward_alloc)
+				if ((int)skb->truesize > atomic_read(&sk->sk_forward_alloc))
 					goto step5;
=20
 				NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPHPHITS);
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 4bd178a..dcc246a 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -955,9 +955,7 @@ try_again:
 		err =3D ulen;
=20
 out_free:
-	lock_sock(sk);
 	skb_free_datagram(sk, skb);
-	release_sock(sk);
 out:
 	return err;
=20
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 84b1a29..582b80a 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -257,9 +257,7 @@ try_again:
 		err =3D ulen;
=20
 out_free:
-	lock_sock(sk);
 	skb_free_datagram(sk, skb);
-	release_sock(sk);
 out:
 	return err;
=20
diff --git a/net/sched/em_meta.c b/net/sched/em_meta.c
index 72cf86e..94d90b6 100644
--- a/net/sched/em_meta.c
+++ b/net/sched/em_meta.c
@@ -383,7 +383,7 @@ META_COLLECTOR(int_sk_wmem_queued)
 META_COLLECTOR(int_sk_fwd_alloc)
 {
 	SKIP_NONLOCAL(skb);
-	dst->value =3D skb->sk->sk_forward_alloc;
+	dst->value =3D atomic_read(&skb->sk->sk_forward_alloc);
 }
=20
 META_COLLECTOR(int_sk_sndbuf)

