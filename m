From: Krishna Kumar <kumarkr@us.ibm.com>
Subject: Re: [BK PATCH] Misc IPv6 Updates
Date: Wed, 10 Nov 2004 10:20:40 -0800
Message-ID: <OF8CA84FB0.6990A5CD-ON88256F48.0063D0E6-88256F48.0064C53C@us.ibm.com>
References: <20041110.030026.29809367.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: multipart/related;
	Boundary="0__=07BBE5DBDFF056768f9e8a93df938690918c07BBE5DBDFF05676"
Cc: davem@davemloft.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <20041110.030026.29809367.yoshfuji@linux-ipv6.org>
To: YOSHIFUJI Hideaki /  =?ISO-2022-JP?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--0__=07BBE5DBDFF056768f9e8a93df938690918c07BBE5DBDFF05676
Content-type: multipart/alternative;
	Boundary="1__=07BBE5DBDFF056768f9e8a93df938690918c07BBE5DBDFF05676"

--1__=07BBE5DBDFF056768f9e8a93df938690918c07BBE5DBDFF05676
Content-type: text/plain; charset=ISO-2022-JP
Content-transfer-encoding: quoted-printable






(sorry if my mailer mangles the code)

In :

+static inline int ipv6_addr_equal(const struct in6_addr *a1,
+                                                  const struct in6_add=
r
*a2)
+{
+            return (a1->s6_addr32[0] =3D=3D a2->s6_addr32[0] &&
+                        a1->s6_addr32[1] =3D=3D a2->s6_addr32[1] &&
+                        a1->s6_addr32[2] =3D=3D a2->s6_addr32[2] &&
+                        a1->s6_addr32[3] =3D=3D a2->s6_addr32[3]);
+}
+

Is it faster to do :

+static inline int ipv6_addr_equal(const struct in6_addr *a1,
+                                                  const struct in6_add=
r
*a2)
+{
+            return (a1->s6_addr32[3] =3D=3D a2->s6_addr32[3] &&
+                        a1->s6_addr32[2] =3D=3D a2->s6_addr32[2] &&
+                        a1->s6_addr32[1] =3D=3D a2->s6_addr32[1] &&
+                        a1->s6_addr32[0] =3D=3D a2->s6_addr32[0]);
+}
+

instead ?It should be faster for typical addresses, say 2000:a:b:c::1 a=
nd
2000:a:b:c::2. The device EUI-64 is
normally going to be different for all devices while prefix can be same=

(atleast on a link/local site) completely
or to some prefix len portion.

thanks,

- KK



                                                                       =
    
             YOSHIFUJI Hideaki                                         =
    
             / =1B$B5HF#1QL@=1B(B                                      =
              
             <yoshfuji@linux-i                                         =
 To 
             pv6.org>                  davem@davemloft.net             =
    
             Sent by:                                                  =
 cc 
             netdev-bounce@oss         netdev@oss.sgi.com,             =
    
             .sgi.com                  yoshfuji@linux-ipv6.org         =
    
                                                                   Subj=
ect 
                                       [BK PATCH] Misc IPv6 Updates    =
    
             11/10/2004 12:00                                          =
    
             AM                                                        =
    
                                                                       =
    
                                                                       =
    
                                                                       =
    
                                                                       =
    




Hello.

Here're changeset at:
  bk://bk.skbuff.net:20610/linux-2.6-inet6-misc/

Note:
 1. Bug#3717 will be closed next week, after my returning to Japan.
 2. Since there're some points to retain ipv6_addr_cmp(),
    let's introduce fast ipv6_addr_equal() and use it
    where appropriate. (please double check.)
 3. I'm not so worring about alignment because
    we already have ipv6_addr_any() etc.

If you're unhappy with this, let me re-create changesets.
Thank you.

HEADLINES
---------
ChangeSet@1.2607, 2004-11-09 14:07:14+09:00, yoshfuji@linux-ipv6.org
 [IPV6] Fix unresolved symbol timer_bug_msg.
ChangeSet@1.2608, 2004-11-10 15:50:50+09:00, yoshfuji@linux-ipv6.org
 [IPV6] introduce lightweight IPv6 address comparison function.
ChangeSet@1.2609, 2004-11-10 15:57:15+09:00, yoshfuji@linux-ipv6.org
 [IPV6] Use ipv6_addr_equal() where appropriate.


DIFFSTATS
---------
 include/net/ipv6.h             |    9 +++++++++
 include/net/tcp.h              |   16 +++++++++++-----
 net/ipv4/tcp_timer.c           |    7 ++++++-
 net/ipv6/addrconf.c            |   10 +++++-----
 net/ipv6/anycast.c             |   10 +++++-----
 net/ipv6/datagram.c            |    2 +-
 net/ipv6/ip6_fib.c             |    4 ++--
 net/ipv6/ip6_flowlabel.c       |    2 +-
 net/ipv6/ip6_output.c          |    4 ++--
 net/ipv6/ip6_tunnel.c          |   10 +++++-----
 net/ipv6/mcast.c               |   37
++++++++++++++++++-------------------
 net/ipv6/ndisc.c               |    2 +-
 net/ipv6/netfilter/ip6_queue.c |    4 ++--
 net/ipv6/netfilter/ip6t_rt.c   |    4 ++--
 net/ipv6/raw.c                 |    8 ++++----
 net/ipv6/reassembly.c          |    8 ++++----
 net/ipv6/route.c               |    8 ++++----
 net/ipv6/tcp_ipv6.c            |   16 ++++++++--------
 net/ipv6/udp.c                 |   12 ++++++------
 net/ipv6/xfrm6_policy.c        |    6 +++---
 net/ipv6/xfrm6_state.c         |    6 +++---
 net/sctp/ipv6.c                |    2 +-
 22 files changed, 103 insertions(+), 84 deletions(-)


CHANGESETS
----------
ChangeSet@1.2607, 2004-11-09 14:07:14+09:00, yoshfuji@linux-ipv6.org
 [IPV6] Fix unresolved symbol timer_bug_msg.

 Closed: Bug#3717 (by John Goerzen <goerzen@complete.org>)
 Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

diff -Nru a/include/net/tcp.h b/include/net/tcp.h
--- a/include/net/tcp.h        2004-11-10 16:44:58 +09:00
+++ b/include/net/tcp.h        2004-11-10 16:44:58 +09:00
@@ -965,7 +965,9 @@
 extern unsigned int tcp_sync_mss(struct sock *sk, u32 pmtu);
 extern unsigned int tcp_current_mss(struct sock *sk, int large);

-extern const char timer_bug_msg[];
+#ifdef TCP_DEBUG
+extern const char tcp_timer_bug_msg[];
+#endif

 /* tcp_diag.c */
 extern void tcp_get_info(struct sock *, struct tcp_info *);
@@ -998,7 +1000,9 @@
 #endif
                         break;
             default:
-                        printk(timer_bug_msg);
+#ifdef TCP_DEBUG
+                        printk(tcp_timer_bug_msg);
+#endif
                         return;
             };

@@ -1033,7 +1037,9 @@
                         break;

             default:
-                        printk(timer_bug_msg);
+#ifdef TCP_DEBUG
+                        printk(tcp_timer_bug_msg);
+#endif
             };
 }

diff -Nru a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
--- a/net/ipv4/tcp_timer.c           2004-11-10 16:44:58 +09:00
+++ b/net/ipv4/tcp_timer.c           2004-11-10 16:44:58 +09:00
@@ -36,7 +36,9 @@
 static void tcp_delack_timer(unsigned long);
 static void tcp_keepalive_timer (unsigned long data);

-const char timer_bug_msg[] =3D KERN_DEBUG "tcpbug: unknown timer value=
\n";
+#ifdef TCP_DEBUG
+const char tcp_timer_bug_msg[] =3D KERN_DEBUG "tcpbug: unknown timer
value\n";
+#endif

 /*
  * Using different timers for retransmit, delayed acks and probes
@@ -651,3 +653,6 @@
 EXPORT_SYMBOL(tcp_delete_keepalive_timer);
 EXPORT_SYMBOL(tcp_init_xmit_timers);
 EXPORT_SYMBOL(tcp_reset_keepalive_timer);
+#ifdef TCP_DEBUG
+EXPORT_SYMBOL(tcp_timer_bug_msg);
+#endif

ChangeSet@1.2608, 2004-11-10 15:50:50+09:00, yoshfuji@linux-ipv6.org
 [IPV6] introduce lightweight IPv6 address comparison function.

 It is not optimal to use ipv6_addr_cmp() for simple address
 comparison, which checks if two addresses are equal.
 Based on idea from Dave Craig <dwcraig@qualcomm.com>.

 Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

diff -Nru a/include/net/ipv6.h b/include/net/ipv6.h
--- a/include/net/ipv6.h             2004-11-10 16:45:02 +09:00
+++ b/include/net/ipv6.h             2004-11-10 16:45:02 +09:00
@@ -296,6 +296,15 @@
 }
 #endif

+static inline int ipv6_addr_equal(const struct in6_addr *a1,
+                                                  const struct in6_add=
r
*a2)
+{
+            return (a1->s6_addr32[0] =3D=3D a2->s6_addr32[0] &&
+                        a1->s6_addr32[1] =3D=3D a2->s6_addr32[1] &&
+                        a1->s6_addr32[2] =3D=3D a2->s6_addr32[2] &&
+                        a1->s6_addr32[3] =3D=3D a2->s6_addr32[3]);
+}
+
 static inline int ipv6_addr_any(const struct in6_addr *a)
 {
             return ((a->s6_addr32[0] | a->s6_addr32[1] |

ChangeSet@1.2609, 2004-11-10 15:57:15+09:00, yoshfuji@linux-ipv6.org
 [IPV6] Use ipv6_addr_equal() where appropriate.

 Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

diff -Nru a/include/net/tcp.h b/include/net/tcp.h
--- a/include/net/tcp.h        2004-11-10 16:45:07 +09:00
+++ b/include/net/tcp.h        2004-11-10 16:45:07 +09:00
@@ -361,8 +361,8 @@
 #define TCP_IPV6_MATCH(__sk, __saddr, __daddr, __ports, __dif)
\
             (((*((__u32 *)&(inet_sk(__sk)->dport)))=3D=3D (__ports))
 && \
              ((__sk)->sk_family                       =3D=3D AF_INET6)=

             && \
-             !ipv6_addr_cmp(&inet6_sk(__sk)->daddr, (__saddr))        =
  &&
\
-             !ipv6_addr_cmp(&inet6_sk(__sk)->rcv_saddr, (__daddr))
 && \
+             ipv6_addr_equal(&inet6_sk(__sk)->daddr, (__saddr))       =
  &&
\
+             ipv6_addr_equal(&inet6_sk(__sk)->rcv_saddr, (__daddr))
 && \
              (!((__sk)->sk_bound_dev_if) || ((__sk)->sk_bound_dev_if =3D=
=3D
(__dif))))

 /* These can have wildcards, don't try too hard. */
diff -Nru a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
--- a/net/ipv6/addrconf.c            2004-11-10 16:45:07 +09:00
+++ b/net/ipv6/addrconf.c            2004-11-10 16:45:07 +09:00
@@ -921,7 +921,7 @@

             read_lock_bh(&addrconf_hash_lock);
             for(ifp =3D inet6_addr_lst[hash]; ifp; ifp=3Difp->lst_next=
) {
-                        if (ipv6_addr_cmp(&ifp->addr, addr) =3D=3D 0 &=
&
+                        if (ipv6_addr_equal(&ifp->addr, addr) &&
                             !(ifp->flags&IFA_F_TENTATIVE)) {
                                     if (dev =3D=3D NULL || ifp->idev->=
dev =3D=3D
dev ||
                                         !(ifp->scope&(IFA_LINK|IFA_HOS=
T)
|| strict))
@@ -940,7 +940,7 @@

             read_lock_bh(&addrconf_hash_lock);
             for(ifp =3D inet6_addr_lst[hash]; ifp; ifp=3Difp->lst_next=
) {
-                        if (ipv6_addr_cmp(&ifp->addr, addr) =3D=3D 0) =
{
+                        if (ipv6_addr_equal(&ifp->addr, addr)) {
                                     if (dev =3D=3D NULL || ifp->idev->=
dev =3D=3D
dev)
                                                 break;
                         }
@@ -956,7 +956,7 @@

             read_lock_bh(&addrconf_hash_lock);
             for(ifp =3D inet6_addr_lst[hash]; ifp; ifp=3Difp->lst_next=
) {
-                        if (ipv6_addr_cmp(&ifp->addr, addr) =3D=3D 0) =
{
+                        if (ipv6_addr_equal(&ifp->addr, addr)) {
                                     if (dev =3D=3D NULL || ifp->idev->=
dev =3D=3D
dev ||
                                         !(ifp->scope&(IFA_LINK|IFA_HOS=
T)
|| strict)) {
                                                 in6_ifa_hold(ifp);
@@ -992,7 +992,7 @@
                         return 1;

             if (sk2_rcv_saddr6 &&
-                !ipv6_addr_cmp(sk_rcv_saddr6, sk2_rcv_saddr6))
+                ipv6_addr_equal(sk_rcv_saddr6, sk2_rcv_saddr6))
                         return 1;

             if (addr_type =3D=3D IPV6_ADDR_MAPPED &&
@@ -1630,7 +1630,7 @@
             read_lock_bh(&idev->lock);
             for (ifp =3D idev->addr_list; ifp; ifp=3Difp->if_next) {
                         if (ifp->prefix_len =3D=3D plen &&
-                            (!memcmp(pfx, &ifp->addr, sizeof(struct
in6_addr)))) {
+                            ipv6_addr_equal(pfx, &ifp->addr)) {
                                     in6_ifa_hold(ifp);
                                     read_unlock_bh(&idev->lock);

diff -Nru a/net/ipv6/anycast.c b/net/ipv6/anycast.c
--- a/net/ipv6/anycast.c             2004-11-10 16:45:07 +09:00
+++ b/net/ipv6/anycast.c             2004-11-10 16:45:07 +09:00
@@ -205,7 +205,7 @@
             prev_pac =3D NULL;
             for (pac =3D np->ipv6_ac_list; pac; pac =3D pac->acl_next)=
 {
                         if ((ifindex =3D=3D 0 || pac->acl_ifindex =3D=3D=
 ifindex)
&&
-                             ipv6_addr_cmp(&pac->acl_addr, addr) =3D=3D=
 0)
+                             ipv6_addr_equal(&pac->acl_addr, addr))
                                     break;
                         prev_pac =3D pac;
             }
@@ -278,7 +278,7 @@
             for (pac=3Dnp->ipv6_ac_list; pac; pac=3Dpac->acl_next) {
                         if (ifindex && pac->acl_ifindex !=3D ifindex)
                                     continue;
-                        found =3D ipv6_addr_cmp(&pac->acl_addr, addr) =
=3D=3D 0;
+                        found =3D ipv6_addr_equal(&pac->acl_addr, addr=
);
                         if (found)
                                     break;
             }
@@ -320,7 +320,7 @@
             }

             for (aca =3D idev->ac_list; aca; aca =3D aca->aca_next) {
-                        if (ipv6_addr_cmp(&aca->aca_addr, addr) =3D=3D=
 0) {
+                        if (ipv6_addr_equal(&aca->aca_addr, addr)) {
                                     aca->aca_users++;
                                     err =3D 0;
                                     goto out;
@@ -384,7 +384,7 @@
             write_lock_bh(&idev->lock);
             prev_aca =3D NULL;
             for (aca =3D idev->ac_list; aca; aca =3D aca->aca_next) {
-                        if (ipv6_addr_cmp(&aca->aca_addr, addr) =3D=3D=
 0)
+                        if (ipv6_addr_equal(&aca->aca_addr, addr))
                                     break;
                         prev_aca =3D aca;
             }
@@ -436,7 +436,7 @@
             if (idev) {
                         read_lock_bh(&idev->lock);
                         for (aca =3D idev->ac_list; aca; aca =3D
aca->aca_next)
-                                    if (ipv6_addr_cmp(&aca->aca_addr,
addr) =3D=3D 0)
+                                    if (ipv6_addr_equal(&aca->aca_addr=
,
addr))
                                                 break;
                         read_unlock_bh(&idev->lock);
                         in6_dev_put(idev);
diff -Nru a/net/ipv6/datagram.c b/net/ipv6/datagram.c
--- a/net/ipv6/datagram.c            2004-11-10 16:45:07 +09:00
+++ b/net/ipv6/datagram.c            2004-11-10 16:45:07 +09:00
@@ -190,7 +190,7 @@
             }

             ip6_dst_store(sk, dst,
-                              !ipv6_addr_cmp(&fl.fl6_dst, &np->daddr) =
?
+                              ipv6_addr_equal(&fl.fl6_dst, &np->daddr)=
 ?
                               &np->daddr : NULL);

             sk->sk_state =3D TCP_ESTABLISHED;
diff -Nru a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
--- a/net/ipv6/ip6_fib.c             2004-11-10 16:45:07 +09:00
+++ b/net/ipv6/ip6_fib.c             2004-11-10 16:45:07 +09:00
@@ -451,8 +451,8 @@

                                     if (iter->rt6i_dev =3D=3D rt->rt6i=
_dev &&
                                         iter->rt6i_idev =3D=3D rt->rt6=
i_idev
&&
-                                        ipv6_addr_cmp(&iter->rt6i_gate=
way,
-
&rt->rt6i_gateway) =3D=3D 0) {
+
ipv6_addr_equal(&iter->rt6i_gateway,
+
&rt->rt6i_gateway)) {
                                                 if
(!(iter->rt6i_flags&RTF_EXPIRES))
                                                             return
-EEXIST;
                                                 iter->rt6i_expires =3D=

rt->rt6i_expires;
diff -Nru a/net/ipv6/ip6_flowlabel.c b/net/ipv6/ip6_flowlabel.c
--- a/net/ipv6/ip6_flowlabel.c             2004-11-10 16:45:07 +09:00
+++ b/net/ipv6/ip6_flowlabel.c             2004-11-10 16:45:07 +09:00
@@ -500,7 +500,7 @@
                                                             goto relea=
se;

                                                 err =3D -EINVAL;
-                                                if
(ipv6_addr_cmp(&fl1->dst, &fl->dst) ||
+                                                if
(!ipv6_addr_equal(&fl1->dst, &fl->dst) ||
                                                     ipv6_opt_cmp(fl1->=
opt,
fl->opt))
                                                             goto relea=
se;

diff -Nru a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
--- a/net/ipv6/ip6_output.c          2004-11-10 16:45:07 +09:00
+++ b/net/ipv6/ip6_output.c          2004-11-10 16:45:07 +09:00
@@ -768,9 +768,9 @@
                                                  */

                                     if (((rt->rt6i_dst.plen !=3D 128 |=
|
-                                          ipv6_addr_cmp(&fl->fl6_dst,
&rt->rt6i_dst.addr))
+                                          !ipv6_addr_equal(&fl->fl6_ds=
t,
&rt->rt6i_dst.addr))
                                          && (np->daddr_cache =3D=3D NU=
LL ||
-
ipv6_addr_cmp(&fl->fl6_dst, np->daddr_cache)))
+
!ipv6_addr_equal(&fl->fl6_dst, np->daddr_cache)))
                                         || (fl->oif && fl->oif !=3D
(*dst)->dev->ifindex)) {
                                                 *dst =3D NULL;
                                     } else
diff -Nru a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
--- a/net/ipv6/ip6_tunnel.c          2004-11-10 16:45:07 +09:00
+++ b/net/ipv6/ip6_tunnel.c          2004-11-10 16:45:07 +09:00
@@ -133,8 +133,8 @@
             struct ip6_tnl *t;

             for (t =3D tnls_r_l[h0 ^ h1]; t; t =3D t->next) {
-                        if (!ipv6_addr_cmp(local, &t->parms.laddr) &&
-                            !ipv6_addr_cmp(remote, &t->parms.raddr) &&=

+                        if (ipv6_addr_equal(local, &t->parms.laddr) &&=

+                            ipv6_addr_equal(remote, &t->parms.raddr) &=
&
                             (t->dev->flags & IFF_UP))
                                     return t;
             }
@@ -284,8 +284,8 @@
                         return -EINVAL;

             for (t =3D *ip6ip6_bucket(p); t; t =3D t->next) {
-                        if (!ipv6_addr_cmp(local, &t->parms.laddr) &&
-                            !ipv6_addr_cmp(remote, &t->parms.raddr)) {=

+                        if (ipv6_addr_equal(local, &t->parms.laddr) &&=

+                            ipv6_addr_equal(remote, &t->parms.raddr)) =
{
                                     *pt =3D t;
                                     return (create ? -EEXIST : 0);
                         }
@@ -602,7 +602,7 @@
 static inline int
 ip6ip6_tnl_addr_conflict(struct ip6_tnl *t, struct ipv6hdr *hdr)
 {
-            return !ipv6_addr_cmp(&t->parms.raddr, &hdr->saddr);
+            return ipv6_addr_equal(&t->parms.raddr, &hdr->saddr);
 }

 /**
diff -Nru a/net/ipv6/mcast.c b/net/ipv6/mcast.c
--- a/net/ipv6/mcast.c         2004-11-10 16:45:07 +09:00
+++ b/net/ipv6/mcast.c         2004-11-10 16:45:07 +09:00
@@ -247,7 +247,7 @@
             write_lock_bh(&ipv6_sk_mc_lock);
             for (lnk =3D &np->ipv6_mc_list; (mc_lst =3D *lnk) !=3DNULL=
 ; lnk =3D
&mc_lst->next) {
                         if ((ifindex =3D=3D 0 || mc_lst->ifindex =3D=3D=
 ifindex)
&&
-                            ipv6_addr_cmp(&mc_lst->addr, addr) =3D=3D =
0) {
+                            ipv6_addr_equal(&mc_lst->addr, addr)) {
                                     struct net_device *dev;

                                     *lnk =3D mc_lst->next;
@@ -369,7 +369,7 @@
             for (pmc=3Dinet6->ipv6_mc_list; pmc; pmc=3Dpmc->next) {
                         if (pgsr->gsr_interface && pmc->ifindex !=3D
pgsr->gsr_interface)
                                     continue;
-                        if (ipv6_addr_cmp(&pmc->addr, group) =3D=3D 0)=

+                        if (ipv6_addr_equal(&pmc->addr, group))
                                     break;
             }
             if (!pmc)                     /* must have a prior join */=

@@ -485,7 +485,7 @@
             for (pmc=3Dinet6->ipv6_mc_list; pmc; pmc=3Dpmc->next) {
                         if (pmc->ifindex !=3D gsf->gf_interface)
                                     continue;
-                        if (ipv6_addr_cmp(&pmc->addr, group) =3D=3D 0)=

+                        if (ipv6_addr_equal(&pmc->addr, group))
                                     break;
             }
             if (!pmc)                     /* must have a prior join */=

@@ -556,7 +556,7 @@
             for (pmc=3Dinet6->ipv6_mc_list; pmc; pmc=3Dpmc->next) {
                         if (pmc->ifindex !=3D gsf->gf_interface)
                                     continue;
-                        if (ipv6_addr_cmp(group, &pmc->addr) =3D=3D 0)=

+                        if (ipv6_addr_equal(group, &pmc->addr))
                                     break;
             }
             if (!pmc)                     /* must have a prior join */=

@@ -603,7 +603,7 @@

             read_lock(&ipv6_sk_mc_lock);
             for (mc =3D np->ipv6_mc_list; mc; mc =3D mc->next) {
-                        if (ipv6_addr_cmp(&mc->addr, mc_addr) =3D=3D 0=
)
+                        if (ipv6_addr_equal(&mc->addr, mc_addr))
                                     break;
             }
             if (!mc) {
@@ -617,7 +617,7 @@
                         int i;

                         for (i=3D0; i<psl->sl_count; i++) {
-                                    if (ipv6_addr_cmp(&psl->sl_addr[i]=
,
src_addr) =3D=3D 0)
+                                    if (ipv6_addr_equal(&psl->sl_addr[=
i],
src_addr))
                                                 break;
                         }
                         if (mc->sfmode =3D=3D MCAST_INCLUDE && i >=3D
psl->sl_count)
@@ -740,7 +740,7 @@
             write_lock_bh(&idev->mc_lock);
             pmc_prev =3D NULL;
             for (pmc=3Didev->mc_tomb; pmc; pmc=3Dpmc->next) {
-                        if (ipv6_addr_cmp(&pmc->mca_addr, pmca) =3D=3D=
 0)
+                        if (ipv6_addr_equal(&pmc->mca_addr, pmca))
                                     break;
                         pmc_prev =3D pmc;
             }
@@ -816,7 +816,7 @@
             }

             for (mc =3D idev->mc_list; mc; mc =3D mc->next) {
-                        if (ipv6_addr_cmp(&mc->mca_addr, addr) =3D=3D =
0) {
+                        if (ipv6_addr_equal(&mc->mca_addr, addr)) {
                                     mc->mca_users++;
                                     write_unlock_bh(&idev->lock);
                                     ip6_mc_add_src(idev, &mc->mca_addr=
,
MCAST_EXCLUDE, 0,
@@ -878,7 +878,7 @@

             write_lock_bh(&idev->lock);
             for (map =3D &idev->mc_list; (ma=3D*map) !=3D NULL; map =3D=
 &ma->next)
{
-                        if (ipv6_addr_cmp(&ma->mca_addr, addr) =3D=3D =
0) {
+                        if (ipv6_addr_equal(&ma->mca_addr, addr)) {
                                     if (--ma->mca_users =3D=3D 0) {
                                                 *map =3D ma->next;

write_unlock_bh(&idev->lock);
@@ -953,7 +953,7 @@
             if (idev) {
                         read_lock_bh(&idev->lock);
                         for (mc =3D idev->mc_list; mc; mc=3Dmc->next) =
{
-                                    if (ipv6_addr_cmp(&mc->mca_addr,
group) =3D=3D 0)
+                                    if (ipv6_addr_equal(&mc->mca_addr,=

group))
                                                 break;
                         }
                         if (mc) {
@@ -962,8 +962,7 @@


spin_lock_bh(&mc->mca_lock);
                                                 for
(psf=3Dmc->mca_sources;psf;psf=3Dpsf->sf_next) {
-                                                            if
(ipv6_addr_cmp(&psf->sf_addr,
-                                                                src_ad=
dr)
=3D=3D 0)
+                                                            if
(ipv6_addr_equal(&psf->sf_addr, src_addr))

break;
                                                 }
                                                 if (psf)
@@ -1040,7 +1039,7 @@
                         if (scount =3D=3D nsrcs)
                                     break;
                         for (i=3D0; i<nsrcs; i++)
-                                    if (ipv6_addr_cmp(&srcs[i],
&psf->sf_addr) =3D=3D 0) {
+                                    if (ipv6_addr_equal(&srcs[i],
&psf->sf_addr)) {
                                                 psf->sf_gsresp =3D 1;
                                                 scount++;
                                                 break;
@@ -1135,7 +1134,7 @@
             } else {
                         for (ma =3D idev->mc_list; ma; ma=3Dma->next) =
{
                                     if (group_type !=3D IPV6_ADDR_ANY =
&&
-                                        ipv6_addr_cmp(group,
&ma->mca_addr) !=3D 0)
+                                        !ipv6_addr_equal(group,
&ma->mca_addr))
                                                 continue;
                                     spin_lock_bh(&ma->mca_lock);
                                     if (ma->mca_flags & MAF_TIMER_RUNN=
ING)
{
@@ -1200,7 +1199,7 @@

             read_lock_bh(&idev->lock);
             for (ma =3D idev->mc_list; ma; ma=3Dma->next) {
-                        if (ipv6_addr_cmp(&ma->mca_addr, addrp) =3D=3D=
 0) {
+                        if (ipv6_addr_equal(&ma->mca_addr, addrp)) {
                                     spin_lock(&ma->mca_lock);
                                     if (del_timer(&ma->mca_timer))

atomic_dec(&ma->mca_refcnt);
@@ -1695,7 +1694,7 @@

             psf_prev =3D NULL;
             for (psf=3Dpmc->mca_sources; psf; psf=3Dpsf->sf_next) {
-                        if (ipv6_addr_cmp(&psf->sf_addr, psfsrc) =3D=3D=
 0)
+                        if (ipv6_addr_equal(&psf->sf_addr, psfsrc))
                                     break;
                         psf_prev =3D psf;
             }
@@ -1735,7 +1734,7 @@
                         return -ENODEV;
             read_lock_bh(&idev->lock);
             for (pmc=3Didev->mc_list; pmc; pmc=3Dpmc->next) {
-                        if (ipv6_addr_cmp(pmca, &pmc->mca_addr) =3D=3D=
 0)
+                        if (ipv6_addr_equal(pmca, &pmc->mca_addr))
                                     break;
             }
             if (!pmc) {
@@ -1790,7 +1789,7 @@

             psf_prev =3D NULL;
             for (psf=3Dpmc->mca_sources; psf; psf=3Dpsf->sf_next) {
-                        if (ipv6_addr_cmp(&psf->sf_addr, psfsrc) =3D=3D=
 0)
+                        if (ipv6_addr_equal(&psf->sf_addr, psfsrc))
                                     break;
                         psf_prev =3D psf;
             }
@@ -1859,7 +1858,7 @@
                         return -ENODEV;
             read_lock_bh(&idev->lock);
             for (pmc=3Didev->mc_list; pmc; pmc=3Dpmc->next) {
-                        if (ipv6_addr_cmp(pmca, &pmc->mca_addr) =3D=3D=
 0)
+                        if (ipv6_addr_equal(pmca, &pmc->mca_addr))
                                     break;
             }
             if (!pmc) {
diff -Nru a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
--- a/net/ipv6/ndisc.c         2004-11-10 16:45:07 +09:00
+++ b/net/ipv6/ndisc.c         2004-11-10 16:45:07 +09:00
@@ -1219,7 +1219,7 @@
                         return;
             }

-            if (ipv6_addr_cmp(dest, target) =3D=3D 0) {
+            if (ipv6_addr_equal(dest, target)) {
                         on_link =3D 1;
             } else if (!(ipv6_addr_type(target) & IPV6_ADDR_LINKLOCAL)=
) {
                         ND_PRINTK2(KERN_WARNING
diff -Nru a/net/ipv6/netfilter/ip6_queue.c b/net/ipv6/netfilter/ip6_que=
ue.c
--- a/net/ipv6/netfilter/ip6_queue.c             2004-11-10 16:45:07 +0=
9:00
+++ b/net/ipv6/netfilter/ip6_queue.c             2004-11-10 16:45:07 +0=
9:00
@@ -376,8 +376,8 @@
              */
             if (e->info->hook =3D=3D NF_IP_LOCAL_OUT) {
                         struct ipv6hdr *iph =3D e->skb->nh.ipv6h;
-                        if (ipv6_addr_cmp(&iph->daddr, &e->rt_info.dad=
dr)
||
-                            ipv6_addr_cmp(&iph->saddr, &e->rt_info.sad=
dr))
+                        if (!ipv6_addr_equal(&iph->daddr,
&e->rt_info.daddr) ||
+                            !ipv6_addr_equal(&iph->saddr,
&e->rt_info.saddr))
                                     return ip6_route_me_harder(e->skb)=
;
             }
             return 0;
diff -Nru a/net/ipv6/netfilter/ip6t_rt.c b/net/ipv6/netfilter/ip6t_rt.c=

--- a/net/ipv6/netfilter/ip6t_rt.c         2004-11-10 16:45:07 +09:00
+++ b/net/ipv6/netfilter/ip6t_rt.c         2004-11-10 16:45:07 +09:00
@@ -209,7 +209,7 @@

                                                 BUG_ON(ap =3D=3D NULL)=
;

-                                                if (!ipv6_addr_cmp(ap,=

&rtinfo->addrs[i])) {
+                                                if (ipv6_addr_equal(ap=
,
&rtinfo->addrs[i])) {
                                                             DEBUGP("i=3D=
%d
temp=3D%d;\n",i,temp);
                                                             i++;
                                                 }
@@ -236,7 +236,7 @@

       &_addr);
                                                 BUG_ON(ap =3D=3D NULL)=
;

-                                                if (ipv6_addr_cmp(ap,
&rtinfo->addrs[temp]))
+                                                if (!ipv6_addr_equal(a=
p,
&rtinfo->addrs[temp]))
                                                             break;
                                     }
                                     DEBUGP("temp=3D%d #%d\n", temp,
rtinfo->addrnr);
diff -Nru a/net/ipv6/raw.c b/net/ipv6/raw.c
--- a/net/ipv6/raw.c           2004-11-10 16:45:07 +09:00
+++ b/net/ipv6/raw.c           2004-11-10 16:45:07 +09:00
@@ -90,11 +90,11 @@
                                     struct ipv6_pinfo *np =3D inet6_sk=
(sk);

                                     if (!ipv6_addr_any(&np->daddr) &&
-                                        ipv6_addr_cmp(&np->daddr,
rmt_addr))
+                                        !ipv6_addr_equal(&np->daddr,
rmt_addr))
                                                 continue;

                                     if (!ipv6_addr_any(&np->rcv_saddr)=
) {
-                                                if
(!ipv6_addr_cmp(&np->rcv_saddr, loc_addr))
+                                                if
(ipv6_addr_equal(&np->rcv_saddr, loc_addr))
                                                             goto found=
;
                                                 if (is_multicast &&
                                                     inet6_mc_check(sk,=

loc_addr, rmt_addr))
@@ -668,7 +668,7 @@
                          * sk->sk_dst_cache.
                          */
                         if (sk->sk_state =3D=3D TCP_ESTABLISHED &&
-                            !ipv6_addr_cmp(daddr, &np->daddr))
+                            ipv6_addr_equal(daddr, &np->daddr))
                                     daddr =3D &np->daddr;

                         if (addr_len >=3D sizeof(struct sockaddr_in6) =
&&
@@ -775,7 +775,7 @@
             }
 done:
             ip6_dst_store(sk, dst,
-                              !ipv6_addr_cmp(&fl.fl6_dst, &np->daddr) =
?
+                              ipv6_addr_equal(&fl.fl6_dst, &np->daddr)=
 ?
                               &np->daddr : NULL);
             if (err > 0)
                         err =3D np->recverr ? net_xmit_errno(err) : 0;=

diff -Nru a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
--- a/net/ipv6/reassembly.c          2004-11-10 16:45:07 +09:00
+++ b/net/ipv6/reassembly.c          2004-11-10 16:45:07 +09:00
@@ -342,8 +342,8 @@
 #ifdef CONFIG_SMP
             for (fq =3D ip6_frag_hash[hash]; fq; fq =3D fq->next) {
                         if (fq->id =3D=3D fq_in->id &&
-                            !ipv6_addr_cmp(&fq_in->saddr, &fq->saddr) =
&&
-                            !ipv6_addr_cmp(&fq_in->daddr, &fq->daddr))=
 {
+                            ipv6_addr_equal(&fq_in->saddr, &fq->saddr)=
 &&
+                            ipv6_addr_equal(&fq_in->daddr, &fq->daddr)=
) {
                                     atomic_inc(&fq->refcnt);
                                     write_unlock(&ip6_frag_lock);
                                     fq_in->last_in |=3D COMPLETE;
@@ -406,8 +406,8 @@
             read_lock(&ip6_frag_lock);
             for(fq =3D ip6_frag_hash[hash]; fq; fq =3D fq->next) {
                         if (fq->id =3D=3D id &&
-                            !ipv6_addr_cmp(src, &fq->saddr) &&
-                            !ipv6_addr_cmp(dst, &fq->daddr)) {
+                            ipv6_addr_equal(src, &fq->saddr) &&
+                            ipv6_addr_equal(dst, &fq->daddr)) {
                                     atomic_inc(&fq->refcnt);
                                     read_unlock(&ip6_frag_lock);
                                     return fq;
diff -Nru a/net/ipv6/route.c b/net/ipv6/route.c
--- a/net/ipv6/route.c         2004-11-10 16:45:07 +09:00
+++ b/net/ipv6/route.c         2004-11-10 16:45:07 +09:00
@@ -1006,7 +1006,7 @@
                                          rt->rt6i_dev->ifindex !=3D
rtmsg->rtmsg_ifindex))
                                                 continue;
                                     if (rtmsg->rtmsg_flags&RTF_GATEWAY=
 &&
-
ipv6_addr_cmp(&rtmsg->rtmsg_gateway, &rt->rt6i_gateway))
+=

!ipv6_addr_equal(&rtmsg->rtmsg_gateway, &rt->rt6i_gateway))
                                                 continue;
                                     if (rtmsg->rtmsg_metric &&
                                         rtmsg->rtmsg_metric !=3D
rt->rt6i_metric)
@@ -1057,13 +1057,13 @@
              *          is a bit fuzzy and one might need to check all=

default
              *          routers.
              */
-            if (ipv6_addr_cmp(saddr, &rt->rt6i_gateway)) {
+            if (!ipv6_addr_equal(saddr, &rt->rt6i_gateway)) {
                         if (rt->rt6i_flags & RTF_DEFAULT) {
                                     struct rt6_info *rt1;

                                     read_lock(&rt6_lock);
                                     for (rt1 =3D ip6_routing_table.lea=
f;
rt1; rt1 =3D rt1->u.next) {
-                                                if (!ipv6_addr_cmp(sad=
dr,
&rt1->rt6i_gateway)) {
+                                                if (ipv6_addr_equal(sa=
ddr,
&rt1->rt6i_gateway)) {

dst_hold(&rt1->u.dst);

dst_release(&rt->u.dst);

read_unlock(&rt6_lock);
@@ -1262,7 +1262,7 @@
             write_lock_bh(&rt6_lock);
             for (rt =3D fn->leaf; rt; rt=3Drt->u.next) {
                         if (dev =3D=3D rt->rt6i_dev &&
-                            ipv6_addr_cmp(&rt->rt6i_gateway, addr) =3D=
=3D 0)
+                            ipv6_addr_equal(&rt->rt6i_gateway, addr))
                                     break;
             }
             if (rt)
diff -Nru a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
--- a/net/ipv6/tcp_ipv6.c            2004-11-10 16:45:07 +09:00
+++ b/net/ipv6/tcp_ipv6.c            2004-11-10 16:45:07 +09:00
@@ -262,7 +262,7 @@

                                     score =3D 1;
                                     if (!ipv6_addr_any(&np->rcv_saddr)=
) {
-                                                if
(ipv6_addr_cmp(&np->rcv_saddr, daddr))
+                                                if
(!ipv6_addr_equal(&np->rcv_saddr, daddr))
                                                             continue;
                                                 score++;
                                     }
@@ -321,8 +321,8 @@

                         if(*((__u32 *)&(tw->tw_dport))            =3D=3D=
 ports
       &&
                            sk->sk_family                    =3D=3D PF_=
INET6) {
-                                    if(!ipv6_addr_cmp(&tw->tw_v6_daddr=
,
saddr)             &&
-
!ipv6_addr_cmp(&tw->tw_v6_rcv_saddr, daddr)            &&
+                                    if(ipv6_addr_equal(&tw->tw_v6_dadd=
r,
saddr)             &&
+
ipv6_addr_equal(&tw->tw_v6_rcv_saddr, daddr)           &&
                                        (!sk->sk_bound_dev_if ||
sk->sk_bound_dev_if =3D=3D dif))
                                                 goto hit;
                         }
@@ -406,8 +406,8 @@
                  prev =3D &req->dl_next) {
                         if (req->rmt_port =3D=3D rport &&
                             req->class->family =3D=3D AF_INET6 &&
-                            !ipv6_addr_cmp(&req->af.v6_req.rmt_addr,
raddr) &&
-                            !ipv6_addr_cmp(&req->af.v6_req.loc_addr,
laddr) &&
+                            ipv6_addr_equal(&req->af.v6_req.rmt_addr,
raddr) &&
+                            ipv6_addr_equal(&req->af.v6_req.loc_addr,
laddr) &&
                             (!req->af.v6_req.iif || req->af.v6_req.iif=
 =3D=3D
iif)) {
                                     BUG_TRAP(req->sk =3D=3D NULL);
                                     *prevp =3D prev;
@@ -463,8 +463,8 @@

                         if(*((__u32 *)&(tw->tw_dport))            =3D=3D=
 ports
       &&
                            sk2->sk_family                         =3D=3D=

PF_INET6           &&
-                           !ipv6_addr_cmp(&tw->tw_v6_daddr, saddr)
 &&
-                           !ipv6_addr_cmp(&tw->tw_v6_rcv_saddr, daddr)=

 &&
+                           ipv6_addr_equal(&tw->tw_v6_daddr, saddr)
 &&
+                           ipv6_addr_equal(&tw->tw_v6_rcv_saddr, daddr=
)
       &&
                            sk2->sk_bound_dev_if =3D=3D sk->sk_bound_de=
v_if) {
                                     struct tcp_opt *tp =3D tcp_sk(sk);=


@@ -610,7 +610,7 @@
             }

             if (tp->ts_recent_stamp &&
-                ipv6_addr_cmp(&np->daddr, &usin->sin6_addr)) {
+                !ipv6_addr_equal(&np->daddr, &usin->sin6_addr)) {
                         tp->ts_recent =3D 0;
                         tp->ts_recent_stamp =3D 0;
                         tp->write_seq =3D 0;
diff -Nru a/net/ipv6/udp.c b/net/ipv6/udp.c
--- a/net/ipv6/udp.c           2004-11-10 16:45:07 +09:00
+++ b/net/ipv6/udp.c           2004-11-10 16:45:07 +09:00
@@ -171,12 +171,12 @@
                                                 score++;
                                     }
                                     if (!ipv6_addr_any(&np->rcv_saddr)=
) {
-                                                if
(ipv6_addr_cmp(&np->rcv_saddr, daddr))
+                                                if
(!ipv6_addr_equal(&np->rcv_saddr, daddr))
                                                             continue;
                                                 score++;
                                     }
                                     if (!ipv6_addr_any(&np->daddr)) {
-                                                if
(ipv6_addr_cmp(&np->daddr, saddr))
+                                                if
(!ipv6_addr_equal(&np->daddr, saddr))
                                                             continue;
                                                 score++;
                                     }
@@ -395,14 +395,14 @@
                                                             continue;
                                     }
                                     if (!ipv6_addr_any(&np->daddr) &&
-                                        ipv6_addr_cmp(&np->daddr,
rmt_addr))
+                                        !ipv6_addr_equal(&np->daddr,
rmt_addr))
                                                 continue;

                                     if (s->sk_bound_dev_if &&
s->sk_bound_dev_if !=3D dif)
                                                 continue;

                                     if (!ipv6_addr_any(&np->rcv_saddr)=
) {
-                                                if
(!ipv6_addr_cmp(&np->rcv_saddr, loc_addr))
+                                                if
(ipv6_addr_equal(&np->rcv_saddr, loc_addr))
                                                             return s;
                                                 continue;
                                     }
@@ -732,7 +732,7 @@
                          * sk->sk_dst_cache.
                          */
                         if (sk->sk_state =3D=3D TCP_ESTABLISHED &&
-                            !ipv6_addr_cmp(daddr, &np->daddr))
+                            ipv6_addr_equal(daddr, &np->daddr))
                                     daddr =3D &np->daddr;

                         if (addr_len >=3D sizeof(struct sockaddr_in6) =
&&
@@ -840,7 +840,7 @@

             if (dst)
                         ip6_dst_store(sk, dst,
-                                          !ipv6_addr_cmp(&fl->fl6_dst,=

&np->daddr) ?
+                                          ipv6_addr_equal(&fl->fl6_dst=
,
&np->daddr) ?
                                           &np->daddr : NULL);
             if (err > 0)
                         err =3D np->recverr ? net_xmit_errno(err) : 0;=

diff -Nru a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
--- a/net/ipv6/xfrm6_policy.c        2004-11-10 16:45:07 +09:00
+++ b/net/ipv6/xfrm6_policy.c        2004-11-10 16:45:07 +09:00
@@ -68,8 +68,8 @@
                         ipv6_addr_prefix(&fl_src_prefix,
                                                  &fl->fl6_src,

xdst->u.rt6.rt6i_src.plen);
-                        if (!ipv6_addr_cmp(&xdst->u.rt6.rt6i_dst.addr,=

&fl_dst_prefix) &&
-                            !ipv6_addr_cmp(&xdst->u.rt6.rt6i_src.addr,=

&fl_src_prefix) &&
+                        if (ipv6_addr_equal(&xdst->u.rt6.rt6i_dst.addr=
,
&fl_dst_prefix) &&
+                            ipv6_addr_equal(&xdst->u.rt6.rt6i_src.addr=
,
&fl_src_prefix) &&
                             __xfrm6_bundle_ok(xdst, fl)) {
                                     dst_clone(dst);
                                     break;
@@ -123,7 +123,7 @@
                         trailer_len +=3D xfrm[i]->props.trailer_len;
             }

-            if (ipv6_addr_cmp(remote, &fl->fl6_dst)) {
+            if (!ipv6_addr_equal(remote, &fl->fl6_dst)) {
                         struct flowi fl_tunnel;

                         memset(&fl_tunnel, 0, sizeof(fl_tunnel));
diff -Nru a/net/ipv6/xfrm6_state.c b/net/ipv6/xfrm6_state.c
--- a/net/ipv6/xfrm6_state.c         2004-11-10 16:45:07 +09:00
+++ b/net/ipv6/xfrm6_state.c         2004-11-10 16:45:07 +09:00
@@ -55,7 +55,7 @@
             list_for_each_entry(x, xfrm6_state_afinfo.state_byspi+h,
byspi) {
                         if (x->props.family =3D=3D AF_INET6 &&
                             spi =3D=3D x->id.spi &&
-                            !ipv6_addr_cmp((struct in6_addr *)daddr,
(struct in6_addr *)x->id.daddr.a6) &&
+                            ipv6_addr_equal((struct in6_addr *)daddr,
(struct in6_addr *)x->id.daddr.a6) &&
                             proto =3D=3D x->id.proto) {
                                     xfrm_state_hold(x);
                                     return x;
@@ -76,10 +76,10 @@

             list_for_each_entry(x, xfrm6_state_afinfo.state_bydst+h,
bydst) {
                         if (x->props.family =3D=3D AF_INET6 &&
-                            !ipv6_addr_cmp((struct in6_addr *)daddr,
(struct in6_addr *)x->id.daddr.a6) &&
+                            ipv6_addr_equal((struct in6_addr *)daddr,
(struct in6_addr *)x->id.daddr.a6) &&
                             mode =3D=3D x->props.mode &&
                             proto =3D=3D x->id.proto &&
-                            !ipv6_addr_cmp((struct in6_addr *)saddr,
(struct in6_addr *)x->props.saddr.a6) &&
+                            ipv6_addr_equal((struct in6_addr *)saddr,
(struct in6_addr *)x->props.saddr.a6) &&
                             reqid =3D=3D x->props.reqid &&
                             x->km.state =3D=3D XFRM_STATE_ACQ &&
                             !x->id.spi) {
diff -Nru a/net/sctp/ipv6.c b/net/sctp/ipv6.c
--- a/net/sctp/ipv6.c          2004-11-10 16:45:07 +09:00
+++ b/net/sctp/ipv6.c          2004-11-10 16:45:07 +09:00
@@ -461,7 +461,7 @@
                         }
                         return 0;
             }
-            if (ipv6_addr_cmp(&addr1->v6.sin6_addr, &addr2->v6.sin6_ad=
dr))
+            if (!ipv6_addr_equal(&addr1->v6.sin6_addr,
&addr2->v6.sin6_addr))
                         return 0;
             /* If this is a linklocal address, compare the scope_id. *=
/
             if (ipv6_addr_type(&addr1->v6.sin6_addr) &
IPV6_ADDR_LINKLOCAL) {

--
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA

=

--1__=07BBE5DBDFF056768f9e8a93df938690918c07BBE5DBDFF05676
Content-type: text/html; charset=ISO-2022-JP
Content-Disposition: inline
Content-transfer-encoding: quoted-printable

<html><body>
<p>(sorry if my mailer mangles the code)<br>
<br>
In :<br>
<br>
<tt>+static inline int ipv6_addr_equal(const struct in6_addr *a1,<br>
+		 		 		 		 &nbsp; const struct in6_addr *a2)<br>
+{<br>
+		 return (a1-&gt;s6_addr32[0] =3D=3D a2-&gt;s6_addr32[0] &amp;&amp;<b=
r>
+		 		 a1-&gt;s6_addr32[1] =3D=3D a2-&gt;s6_addr32[1] &amp;&amp;<br>
+		 		 a1-&gt;s6_addr32[2] =3D=3D a2-&gt;s6_addr32[2] &amp;&amp;<br>
+		 		 a1-&gt;s6_addr32[3] =3D=3D a2-&gt;s6_addr32[3]);<br>
+}<br>
+</tt><br>
<br>
Is it faster to do :<br>
<br>
<tt>+static inline int ipv6_addr_equal(const struct in6_addr *a1,<br>
+		 		 		 		 &nbsp; const struct in6_addr *a2)<br>
+{<br>
+		 return (a1-&gt;s6_addr32[3] =3D=3D a2-&gt;s6_addr32[3] &amp;&amp;<b=
r>
+		 		 a1-&gt;s6_addr32[2] =3D=3D a2-&gt;s6_addr32[2] &amp;&amp;<br>
+		 		 a1-&gt;s6_addr32[1] =3D=3D a2-&gt;s6_addr32[1] &amp;&amp;<br>
+		 		 a1-&gt;s6_addr32[0] =3D=3D a2-&gt;s6_addr32[0]);<br>
+}<br>
+</tt><br>
<br>
instead ?It should be faster for typical addresses, say 2000:a:b:c::1 a=
nd 2000:a:b:c::2. The device EUI-64 is<br>
normally going to be different for all devices while prefix can be same=
 (atleast on a link/local site) completely<br>
or to some prefix len portion.<br>
<br>
thanks,<br>
<br>
- KK<br>
<br>
<img src=3D"cid:20__=3D07BBE5DBDFF056768f9e8a93df938@us.ibm.com" width=3D=
"16" height=3D"16" alt=3D"Inactive hide details for YOSHIFUJI Hideaki /=
 =1B$B5HF#1QL@=1B(B &lt;yoshfuji@linux-ipv6.org&gt;">YOSHIFUJI Hideaki =
/ =1B$B5HF#1QL@=1B(B &lt;yoshfuji@linux-ipv6.org&gt;<br>
<br>
<br>

<table width=3D"100%" border=3D"0" cellspacing=3D"0" cellpadding=3D"0">=

<tr valign=3D"top"><td style=3D"background-image:url(cid:30__=3D07BBE5D=
BDFF056768f9e8a93df938@us.ibm.com); background-repeat: no-repeat; " wid=
th=3D"40%">
<ul>
<ul>
<ul>
<ul><b><font size=3D"2">YOSHIFUJI Hideaki / =1B$B5HF#1QL@=1B(B &lt;yosh=
fuji@linux-ipv6.org&gt;</font></b><font size=3D"2"> </font><br>
<font size=3D"2">Sent by: netdev-bounce@oss.sgi.com</font>
<p><font size=3D"2">11/10/2004 12:00 AM</font></ul>
</ul>
</ul>
</ul>
</td><td width=3D"60%">
<table width=3D"100%" border=3D"0" cellspacing=3D"0" cellpadding=3D"0">=

<tr valign=3D"top"><td width=3D"1%" valign=3D"middle"><img src=3D"cid:4=
0__=3D07BBE5DBDFF056768f9e8a93df938@us.ibm.com" border=3D"0" height=3D"=
1" width=3D"58" alt=3D""><br>
<div align=3D"right"><font size=3D"2">To</font></div></td><td width=3D"=
100%"><img src=3D"cid:40__=3D07BBE5DBDFF056768f9e8a93df938@us.ibm.com" =
border=3D"0" height=3D"1" width=3D"1" alt=3D""><br>
<font size=3D"2">davem@davemloft.net</font></td></tr>

<tr valign=3D"top"><td width=3D"1%" valign=3D"middle"><img src=3D"cid:4=
0__=3D07BBE5DBDFF056768f9e8a93df938@us.ibm.com" border=3D"0" height=3D"=
1" width=3D"58" alt=3D""><br>
<div align=3D"right"><font size=3D"2">cc</font></div></td><td width=3D"=
100%"><img src=3D"cid:40__=3D07BBE5DBDFF056768f9e8a93df938@us.ibm.com" =
border=3D"0" height=3D"1" width=3D"1" alt=3D""><br>
<font size=3D"2">netdev@oss.sgi.com, yoshfuji@linux-ipv6.org</font></td=
></tr>

<tr valign=3D"top"><td width=3D"1%" valign=3D"middle"><img src=3D"cid:4=
0__=3D07BBE5DBDFF056768f9e8a93df938@us.ibm.com" border=3D"0" height=3D"=
1" width=3D"58" alt=3D""><br>
<div align=3D"right"><font size=3D"2">Subject</font></div></td><td widt=
h=3D"100%"><img src=3D"cid:40__=3D07BBE5DBDFF056768f9e8a93df938@us.ibm.=
com" border=3D"0" height=3D"1" width=3D"1" alt=3D""><br>
<font size=3D"2">[BK PATCH] Misc IPv6 Updates</font></td></tr>
</table>

<table border=3D"0" cellspacing=3D"0" cellpadding=3D"0">
<tr valign=3D"top"><td width=3D"58"><img src=3D"cid:40__=3D07BBE5DBDFF0=
56768f9e8a93df938@us.ibm.com" border=3D"0" height=3D"1" width=3D"1" alt=
=3D""></td><td width=3D"336"><img src=3D"cid:40__=3D07BBE5DBDFF056768f9=
e8a93df938@us.ibm.com" border=3D"0" height=3D"1" width=3D"1" alt=3D""><=
/td></tr>
</table>
</td></tr>
</table>
<br>
<tt>Hello.<br>
<br>
Here're changeset at:<br>
 &nbsp;bk://bk.skbuff.net:20610/linux-2.6-inet6-misc/<br>
<br>
Note:<br>
 1. Bug#3717 will be closed next week, after my returning to Japan.<br>=

 2. Since there're some points to retain ipv6_addr_cmp(),<br>
 &nbsp; &nbsp;let's introduce fast ipv6_addr_equal() and use it<br>
 &nbsp; &nbsp;where appropriate. (please double check.)<br>
 3. I'm not so worring about alignment because<br>
 &nbsp; &nbsp;we already have ipv6_addr_any() etc.<br>
<br>
If you're unhappy with this, let me re-create changesets.<br>
Thank you.<br>
<br>
HEADLINES<br>
---------<br>
ChangeSet@1.2607, 2004-11-09 14:07:14+09:00, yoshfuji@linux-ipv6.org<br=
>
 [IPV6] Fix unresolved symbol timer_bug_msg.<br>
ChangeSet@1.2608, 2004-11-10 15:50:50+09:00, yoshfuji@linux-ipv6.org<br=
>
 [IPV6] introduce lightweight IPv6 address comparison function.<br>
ChangeSet@1.2609, 2004-11-10 15:57:15+09:00, yoshfuji@linux-ipv6.org<br=
>
 [IPV6] Use ipv6_addr_equal() where appropriate.<br>
<br>
<br>
DIFFSTATS<br>
---------<br>
 include/net/ipv6.h &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; | &nbsp; =
&nbsp;9 +++++++++<br>
 include/net/tcp.h &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;| &n=
bsp; 16 +++++++++++-----<br>
 net/ipv4/tcp_timer.c &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; | &nbsp; &nbsp=
;7 ++++++-<br>
 net/ipv6/addrconf.c &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;| &nbsp; =
10 +++++-----<br>
 net/ipv6/anycast.c &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; | &nbsp; =
10 +++++-----<br>
 net/ipv6/datagram.c &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;| &nbsp; =
&nbsp;2 +-<br>
 net/ipv6/ip6_fib.c &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; | &nbsp; =
&nbsp;4 ++--<br>
 net/ipv6/ip6_flowlabel.c &nbsp; &nbsp; &nbsp; | &nbsp; &nbsp;2 +-<br>
 net/ipv6/ip6_output.c &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;| &nbsp; &nbsp=
;4 ++--<br>
 net/ipv6/ip6_tunnel.c &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;| &nbsp; 10 ++=
+++-----<br>
 net/ipv6/mcast.c &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; | &n=
bsp; 37 ++++++++++++++++++-------------------<br>
 net/ipv6/ndisc.c &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; | &n=
bsp; &nbsp;2 +-<br>
 net/ipv6/netfilter/ip6_queue.c | &nbsp; &nbsp;4 ++--<br>
 net/ipv6/netfilter/ip6t_rt.c &nbsp; | &nbsp; &nbsp;4 ++--<br>
 net/ipv6/raw.c &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;=
 | &nbsp; &nbsp;8 ++++----<br>
 net/ipv6/reassembly.c &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;| &nbsp; &nbsp=
;8 ++++----<br>
 net/ipv6/route.c &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; | &n=
bsp; &nbsp;8 ++++----<br>
 net/ipv6/tcp_ipv6.c &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;| &nbsp; =
16 ++++++++--------<br>
 net/ipv6/udp.c &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;=
 | &nbsp; 12 ++++++------<br>
 net/ipv6/xfrm6_policy.c &nbsp; &nbsp; &nbsp; &nbsp;| &nbsp; &nbsp;6 ++=
+---<br>
 net/ipv6/xfrm6_state.c &nbsp; &nbsp; &nbsp; &nbsp; | &nbsp; &nbsp;6 ++=
+---<br>
 net/sctp/ipv6.c &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp=
;| &nbsp; &nbsp;2 +-<br>
 22 files changed, 103 insertions(+), 84 deletions(-)<br>
<br>
<br>
CHANGESETS<br>
----------<br>
ChangeSet@1.2607, 2004-11-09 14:07:14+09:00, yoshfuji@linux-ipv6.org<br=
>
 [IPV6] Fix unresolved symbol timer_bug_msg.<br>
 <br>
 Closed: Bug#3717 (by John Goerzen &lt;goerzen@complete.org&gt;)<br>
 Signed-off-by: Hideaki YOSHIFUJI &lt;yoshfuji@linux-ipv6.org&gt;<br>
<br>
diff -Nru a/include/net/tcp.h b/include/net/tcp.h<br>
--- a/include/net/tcp.h		 2004-11-10 16:44:58 +09:00<br>
+++ b/include/net/tcp.h		 2004-11-10 16:44:58 +09:00<br>
@@ -965,7 +965,9 @@<br>
 extern unsigned int tcp_sync_mss(struct sock *sk, u32 pmtu);<br>
 extern unsigned int tcp_current_mss(struct sock *sk, int large);<br>
 <br>
-extern const char timer_bug_msg[];<br>
+#ifdef TCP_DEBUG<br>
+extern const char tcp_timer_bug_msg[];<br>
+#endif<br>
 <br>
 /* tcp_diag.c */<br>
 extern void tcp_get_info(struct sock *, struct tcp_info *);<br>
@@ -998,7 +1000,9 @@<br>
 #endif<br>
 		 		 break;<br>
 		 default:<br>
-		 		 printk(timer_bug_msg);<br>
+#ifdef TCP_DEBUG<br>
+		 		 printk(tcp_timer_bug_msg);<br>
+#endif<br>
 		 		 return;<br>
 		 };<br>
 <br>
@@ -1033,7 +1037,9 @@<br>
 		 		 break;<br>
 <br>
 		 default:<br>
-		 		 printk(timer_bug_msg);<br>
+#ifdef TCP_DEBUG<br>
+		 		 printk(tcp_timer_bug_msg);<br>
+#endif<br>
 		 };<br>
 }<br>
 <br>
diff -Nru a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c<br>
--- a/net/ipv4/tcp_timer.c		 2004-11-10 16:44:58 +09:00<br>
+++ b/net/ipv4/tcp_timer.c		 2004-11-10 16:44:58 +09:00<br>
@@ -36,7 +36,9 @@<br>
 static void tcp_delack_timer(unsigned long);<br>
 static void tcp_keepalive_timer (unsigned long data);<br>
 <br>
-const char timer_bug_msg[] =3D KERN_DEBUG &quot;tcpbug: unknown timer =
value\n&quot;;<br>
+#ifdef TCP_DEBUG<br>
+const char tcp_timer_bug_msg[] =3D KERN_DEBUG &quot;tcpbug: unknown ti=
mer value\n&quot;;<br>
+#endif<br>
 <br>
 /*<br>
 &nbsp;* Using different timers for retransmit, delayed acks and probes=
<br>
@@ -651,3 +653,6 @@<br>
 EXPORT_SYMBOL(tcp_delete_keepalive_timer);<br>
 EXPORT_SYMBOL(tcp_init_xmit_timers);<br>
 EXPORT_SYMBOL(tcp_reset_keepalive_timer);<br>
+#ifdef TCP_DEBUG<br>
+EXPORT_SYMBOL(tcp_timer_bug_msg);<br>
+#endif<br>
<br>
ChangeSet@1.2608, 2004-11-10 15:50:50+09:00, yoshfuji@linux-ipv6.org<br=
>
 [IPV6] introduce lightweight IPv6 address comparison function.<br>
 <br>
 It is not optimal to use ipv6_addr_cmp() for simple address<br>
 comparison, which checks if two addresses are equal.<br>
 Based on idea from Dave Craig &lt;dwcraig@qualcomm.com&gt;.<br>
 <br>
 Signed-off-by: Hideaki YOSHIFUJI &lt;yoshfuji@linux-ipv6.org&gt;<br>
<br>
diff -Nru a/include/net/ipv6.h b/include/net/ipv6.h<br>
--- a/include/net/ipv6.h		 2004-11-10 16:45:02 +09:00<br>
+++ b/include/net/ipv6.h		 2004-11-10 16:45:02 +09:00<br>
@@ -296,6 +296,15 @@<br>
 }<br>
 #endif<br>
 <br>
+static inline int ipv6_addr_equal(const struct in6_addr *a1,<br>
+		 		 		 		 &nbsp; const struct in6_addr *a2)<br>
+{<br>
+		 return (a1-&gt;s6_addr32[0] =3D=3D a2-&gt;s6_addr32[0] &amp;&amp;<b=
r>
+		 		 a1-&gt;s6_addr32[1] =3D=3D a2-&gt;s6_addr32[1] &amp;&amp;<br>
+		 		 a1-&gt;s6_addr32[2] =3D=3D a2-&gt;s6_addr32[2] &amp;&amp;<br>
+		 		 a1-&gt;s6_addr32[3] =3D=3D a2-&gt;s6_addr32[3]);<br>
+}<br>
+<br>
 static inline int ipv6_addr_any(const struct in6_addr *a)<br>
 {<br>
 		 return ((a-&gt;s6_addr32[0] | a-&gt;s6_addr32[1] | <br>
<br>
ChangeSet@1.2609, 2004-11-10 15:57:15+09:00, yoshfuji@linux-ipv6.org<br=
>
 [IPV6] Use ipv6_addr_equal() where appropriate.<br>
 <br>
 Signed-off-by: Hideaki YOSHIFUJI &lt;yoshfuji@linux-ipv6.org&gt;<br>
<br>
diff -Nru a/include/net/tcp.h b/include/net/tcp.h<br>
--- a/include/net/tcp.h		 2004-11-10 16:45:07 +09:00<br>
+++ b/include/net/tcp.h		 2004-11-10 16:45:07 +09:00<br>
@@ -361,8 +361,8 @@<br>
 #define TCP_IPV6_MATCH(__sk, __saddr, __daddr, __ports, __dif)		 &nbsp=
; &nbsp;\<br>
 		 (((*((__u32 *)&amp;(inet_sk(__sk)-&gt;dport)))=3D=3D (__ports)) &nb=
sp; 		 &amp;&amp; \<br>
 		 &nbsp;((__sk)-&gt;sk_family		 		 =3D=3D AF_INET6)		 		 &amp;&amp; \=
<br>
-		 &nbsp;!ipv6_addr_cmp(&amp;inet6_sk(__sk)-&gt;daddr, (__saddr))		 &a=
mp;&amp; \<br>
-		 &nbsp;!ipv6_addr_cmp(&amp;inet6_sk(__sk)-&gt;rcv_saddr, (__daddr))	=
	 &amp;&amp; \<br>
+		 &nbsp;ipv6_addr_equal(&amp;inet6_sk(__sk)-&gt;daddr, (__saddr))		 &=
amp;&amp; \<br>
+		 &nbsp;ipv6_addr_equal(&amp;inet6_sk(__sk)-&gt;rcv_saddr, (__daddr))=
		 &amp;&amp; \<br>
 		 &nbsp;(!((__sk)-&gt;sk_bound_dev_if) || ((__sk)-&gt;sk_bound_dev_if=
 =3D=3D (__dif))))<br>
 <br>
 /* These can have wildcards, don't try too hard. */<br>
diff -Nru a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c<br>
--- a/net/ipv6/addrconf.c		 2004-11-10 16:45:07 +09:00<br>
+++ b/net/ipv6/addrconf.c		 2004-11-10 16:45:07 +09:00<br>
@@ -921,7 +921,7 @@<br>
 <br>
 		 read_lock_bh(&amp;addrconf_hash_lock);<br>
 		 for(ifp =3D inet6_addr_lst[hash]; ifp; ifp=3Difp-&gt;lst_next) {<br=
>
-		 		 if (ipv6_addr_cmp(&amp;ifp-&gt;addr, addr) =3D=3D 0 &amp;&amp;<b=
r>
+		 		 if (ipv6_addr_equal(&amp;ifp-&gt;addr, addr) &amp;&amp;<br>
 		 		 &nbsp; &nbsp; !(ifp-&gt;flags&amp;IFA_F_TENTATIVE)) {<br>
 		 		 		 if (dev =3D=3D NULL || ifp-&gt;idev-&gt;dev =3D=3D dev ||<br>=

 		 		 		 &nbsp; &nbsp; !(ifp-&gt;scope&amp;(IFA_LINK|IFA_HOST) || stri=
ct))<br>
@@ -940,7 +940,7 @@<br>
 <br>
 		 read_lock_bh(&amp;addrconf_hash_lock);<br>
 		 for(ifp =3D inet6_addr_lst[hash]; ifp; ifp=3Difp-&gt;lst_next) {<br=
>
-		 		 if (ipv6_addr_cmp(&amp;ifp-&gt;addr, addr) =3D=3D 0) {<br>
+		 		 if (ipv6_addr_equal(&amp;ifp-&gt;addr, addr)) {<br>
 		 		 		 if (dev =3D=3D NULL || ifp-&gt;idev-&gt;dev =3D=3D dev)<br>
 		 		 		 		 break;<br>
 		 		 }<br>
@@ -956,7 +956,7 @@<br>
 <br>
 		 read_lock_bh(&amp;addrconf_hash_lock);<br>
 		 for(ifp =3D inet6_addr_lst[hash]; ifp; ifp=3Difp-&gt;lst_next) {<br=
>
-		 		 if (ipv6_addr_cmp(&amp;ifp-&gt;addr, addr) =3D=3D 0) {<br>
+		 		 if (ipv6_addr_equal(&amp;ifp-&gt;addr, addr)) {<br>
 		 		 		 if (dev =3D=3D NULL || ifp-&gt;idev-&gt;dev =3D=3D dev ||<br>=

 		 		 		 &nbsp; &nbsp; !(ifp-&gt;scope&amp;(IFA_LINK|IFA_HOST) || stri=
ct)) {<br>
 		 		 		 		 in6_ifa_hold(ifp);<br>
@@ -992,7 +992,7 @@<br>
 		 		 return 1;<br>
 <br>
 		 if (sk2_rcv_saddr6 &amp;&amp;<br>
-		 &nbsp; &nbsp; !ipv6_addr_cmp(sk_rcv_saddr6, sk2_rcv_saddr6))<br>
+		 &nbsp; &nbsp; ipv6_addr_equal(sk_rcv_saddr6, sk2_rcv_saddr6))<br>
 		 		 return 1;<br>
 <br>
 		 if (addr_type =3D=3D IPV6_ADDR_MAPPED &amp;&amp;<br>
@@ -1630,7 +1630,7 @@<br>
 		 read_lock_bh(&amp;idev-&gt;lock);<br>
 		 for (ifp =3D idev-&gt;addr_list; ifp; ifp=3Difp-&gt;if_next) {<br>
 		 		 if (ifp-&gt;prefix_len =3D=3D plen &amp;&amp;<br>
-		 		 &nbsp; &nbsp; (!memcmp(pfx, &amp;ifp-&gt;addr, sizeof(struct in6=
_addr)))) {<br>
+		 		 &nbsp; &nbsp; ipv6_addr_equal(pfx, &amp;ifp-&gt;addr)) {<br>
 		 		 		 in6_ifa_hold(ifp);<br>
 		 		 		 read_unlock_bh(&amp;idev-&gt;lock);<br>
 		 		 		 <br>
diff -Nru a/net/ipv6/anycast.c b/net/ipv6/anycast.c<br>
--- a/net/ipv6/anycast.c		 2004-11-10 16:45:07 +09:00<br>
+++ b/net/ipv6/anycast.c		 2004-11-10 16:45:07 +09:00<br>
@@ -205,7 +205,7 @@<br>
 		 prev_pac =3D NULL;<br>
 		 for (pac =3D np-&gt;ipv6_ac_list; pac; pac =3D pac-&gt;acl_next) {<=
br>
 		 		 if ((ifindex =3D=3D 0 || pac-&gt;acl_ifindex =3D=3D ifindex) &am=
p;&amp;<br>
-		 		 &nbsp; &nbsp; &nbsp;ipv6_addr_cmp(&amp;pac-&gt;acl_addr, addr) =3D=
=3D 0)<br>
+		 		 &nbsp; &nbsp; &nbsp;ipv6_addr_equal(&amp;pac-&gt;acl_addr, addr)=
)<br>
 		 		 		 break;<br>
 		 		 prev_pac =3D pac;<br>
 		 }<br>
@@ -278,7 +278,7 @@<br>
 		 for (pac=3Dnp-&gt;ipv6_ac_list; pac; pac=3Dpac-&gt;acl_next) {<br>
 		 		 if (ifindex &amp;&amp; pac-&gt;acl_ifindex !=3D ifindex)<br>
 		 		 		 continue;<br>
-		 		 found =3D ipv6_addr_cmp(&amp;pac-&gt;acl_addr, addr) =3D=3D 0;<b=
r>
+		 		 found =3D ipv6_addr_equal(&amp;pac-&gt;acl_addr, addr);<br>
 		 		 if (found)<br>
 		 		 		 break;<br>
 		 }<br>
@@ -320,7 +320,7 @@<br>
 		 }<br>
 <br>
 		 for (aca =3D idev-&gt;ac_list; aca; aca =3D aca-&gt;aca_next) {<br>=

-		 		 if (ipv6_addr_cmp(&amp;aca-&gt;aca_addr, addr) =3D=3D 0) {<br>
+		 		 if (ipv6_addr_equal(&amp;aca-&gt;aca_addr, addr)) {<br>
 		 		 		 aca-&gt;aca_users++;<br>
 		 		 		 err =3D 0;<br>
 		 		 		 goto out;<br>
@@ -384,7 +384,7 @@<br>
 		 write_lock_bh(&amp;idev-&gt;lock);<br>
 		 prev_aca =3D NULL;<br>
 		 for (aca =3D idev-&gt;ac_list; aca; aca =3D aca-&gt;aca_next) {<br>=

-		 		 if (ipv6_addr_cmp(&amp;aca-&gt;aca_addr, addr) =3D=3D 0)<br>
+		 		 if (ipv6_addr_equal(&amp;aca-&gt;aca_addr, addr))<br>
 		 		 		 break;<br>
 		 		 prev_aca =3D aca;<br>
 		 }<br>
@@ -436,7 +436,7 @@<br>
 		 if (idev) {<br>
 		 		 read_lock_bh(&amp;idev-&gt;lock);<br>
 		 		 for (aca =3D idev-&gt;ac_list; aca; aca =3D aca-&gt;aca_next)<br=
>
-		 		 		 if (ipv6_addr_cmp(&amp;aca-&gt;aca_addr, addr) =3D=3D 0)<br>
+		 		 		 if (ipv6_addr_equal(&amp;aca-&gt;aca_addr, addr))<br>
 		 		 		 		 break;<br>
 		 		 read_unlock_bh(&amp;idev-&gt;lock);<br>
 		 		 in6_dev_put(idev);<br>
diff -Nru a/net/ipv6/datagram.c b/net/ipv6/datagram.c<br>
--- a/net/ipv6/datagram.c		 2004-11-10 16:45:07 +09:00<br>
+++ b/net/ipv6/datagram.c		 2004-11-10 16:45:07 +09:00<br>
@@ -190,7 +190,7 @@<br>
 		 }<br>
 <br>
 		 ip6_dst_store(sk, dst,<br>
-		 		 &nbsp; &nbsp; &nbsp; !ipv6_addr_cmp(&amp;fl.fl6_dst, &amp;np-&gt=
;daddr) ?<br>
+		 		 &nbsp; &nbsp; &nbsp; ipv6_addr_equal(&amp;fl.fl6_dst, &amp;np-&g=
t;daddr) ?<br>
 		 		 &nbsp; &nbsp; &nbsp; &amp;np-&gt;daddr : NULL);<br>
 <br>
 		 sk-&gt;sk_state =3D TCP_ESTABLISHED;<br>
diff -Nru a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c<br>
--- a/net/ipv6/ip6_fib.c		 2004-11-10 16:45:07 +09:00<br>
+++ b/net/ipv6/ip6_fib.c		 2004-11-10 16:45:07 +09:00<br>
@@ -451,8 +451,8 @@<br>
 <br>
 		 		 		 if (iter-&gt;rt6i_dev =3D=3D rt-&gt;rt6i_dev &amp;&amp;<br>
 		 		 		 &nbsp; &nbsp; iter-&gt;rt6i_idev =3D=3D rt-&gt;rt6i_idev &amp=
;&amp;<br>
-		 		 		 &nbsp; &nbsp; ipv6_addr_cmp(&amp;iter-&gt;rt6i_gateway,<br>
-		 		 		 		 		 &nbsp; &nbsp;&amp;rt-&gt;rt6i_gateway) =3D=3D 0) {<br>
+		 		 		 &nbsp; &nbsp; ipv6_addr_equal(&amp;iter-&gt;rt6i_gateway,<br>=

+		 		 		 		 		 &nbsp; &nbsp; &amp;rt-&gt;rt6i_gateway)) {<br>
 		 		 		 		 if (!(iter-&gt;rt6i_flags&amp;RTF_EXPIRES))<br>
 		 		 		 		 		 return -EEXIST;<br>
 		 		 		 		 iter-&gt;rt6i_expires =3D rt-&gt;rt6i_expires;<br>
diff -Nru a/net/ipv6/ip6_flowlabel.c b/net/ipv6/ip6_flowlabel.c<br>
--- a/net/ipv6/ip6_flowlabel.c		 2004-11-10 16:45:07 +09:00<br>
+++ b/net/ipv6/ip6_flowlabel.c		 2004-11-10 16:45:07 +09:00<br>
@@ -500,7 +500,7 @@<br>
 		 		 		 		 		 goto release;<br>
 <br>
 		 		 		 		 err =3D -EINVAL;<br>
-		 		 		 		 if (ipv6_addr_cmp(&amp;fl1-&gt;dst, &amp;fl-&gt;dst) ||<br=
>
+		 		 		 		 if (!ipv6_addr_equal(&amp;fl1-&gt;dst, &amp;fl-&gt;dst) ||=
<br>
 		 		 		 		 &nbsp; &nbsp; ipv6_opt_cmp(fl1-&gt;opt, fl-&gt;opt))<br>
 		 		 		 		 		 goto release;<br>
 <br>
diff -Nru a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c<br>
--- a/net/ipv6/ip6_output.c		 2004-11-10 16:45:07 +09:00<br>
+++ b/net/ipv6/ip6_output.c		 2004-11-10 16:45:07 +09:00<br>
@@ -768,9 +768,9 @@<br>
 		 		 		 		 &nbsp;*/<br>
 		 <br>
 		 		 		 if (((rt-&gt;rt6i_dst.plen !=3D 128 ||<br>
-		 		 		 &nbsp; &nbsp; &nbsp; ipv6_addr_cmp(&amp;fl-&gt;fl6_dst, &amp;=
rt-&gt;rt6i_dst.addr))<br>
+		 		 		 &nbsp; &nbsp; &nbsp; !ipv6_addr_equal(&amp;fl-&gt;fl6_dst, &a=
mp;rt-&gt;rt6i_dst.addr))<br>
 		 		 		 &nbsp; &nbsp; &nbsp;&amp;&amp; (np-&gt;daddr_cache =3D=3D NUL=
L ||<br>
-		 		 		 		 &nbsp;ipv6_addr_cmp(&amp;fl-&gt;fl6_dst, np-&gt;daddr_cach=
e)))<br>
+		 		 		 		 &nbsp;!ipv6_addr_equal(&amp;fl-&gt;fl6_dst, np-&gt;daddr_c=
ache)))<br>
 		 		 		 &nbsp; &nbsp; || (fl-&gt;oif &amp;&amp; fl-&gt;oif !=3D (*dst=
)-&gt;dev-&gt;ifindex)) {<br>
 		 		 		 		 *dst =3D NULL;<br>
 		 		 		 } else<br>
diff -Nru a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c<br>
--- a/net/ipv6/ip6_tunnel.c		 2004-11-10 16:45:07 +09:00<br>
+++ b/net/ipv6/ip6_tunnel.c		 2004-11-10 16:45:07 +09:00<br>
@@ -133,8 +133,8 @@<br>
 		 struct ip6_tnl *t;<br>
 <br>
 		 for (t =3D tnls_r_l[h0 ^ h1]; t; t =3D t-&gt;next) {<br>
-		 		 if (!ipv6_addr_cmp(local, &amp;t-&gt;parms.laddr) &amp;&amp;<br>=

-		 		 &nbsp; &nbsp; !ipv6_addr_cmp(remote, &amp;t-&gt;parms.raddr) &am=
p;&amp;<br>
+		 		 if (ipv6_addr_equal(local, &amp;t-&gt;parms.laddr) &amp;&amp;<br=
>
+		 		 &nbsp; &nbsp; ipv6_addr_equal(remote, &amp;t-&gt;parms.raddr) &a=
mp;&amp;<br>
 		 		 &nbsp; &nbsp; (t-&gt;dev-&gt;flags &amp; IFF_UP))<br>
 		 		 		 return t;<br>
 		 }<br>
@@ -284,8 +284,8 @@<br>
 		 		 return -EINVAL;<br>
 <br>
 		 for (t =3D *ip6ip6_bucket(p); t; t =3D t-&gt;next) {<br>
-		 		 if (!ipv6_addr_cmp(local, &amp;t-&gt;parms.laddr) &amp;&amp;<br>=

-		 		 &nbsp; &nbsp; !ipv6_addr_cmp(remote, &amp;t-&gt;parms.raddr)) {<=
br>
+		 		 if (ipv6_addr_equal(local, &amp;t-&gt;parms.laddr) &amp;&amp;<br=
>
+		 		 &nbsp; &nbsp; ipv6_addr_equal(remote, &amp;t-&gt;parms.raddr)) {=
<br>
 		 		 		 *pt =3D t;<br>
 		 		 		 return (create ? -EEXIST : 0);<br>
 		 		 }<br>
@@ -602,7 +602,7 @@<br>
 static inline int<br>
 ip6ip6_tnl_addr_conflict(struct ip6_tnl *t, struct ipv6hdr *hdr)<br>
 {<br>
-		 return !ipv6_addr_cmp(&amp;t-&gt;parms.raddr, &amp;hdr-&gt;saddr);<=
br>
+		 return ipv6_addr_equal(&amp;t-&gt;parms.raddr, &amp;hdr-&gt;saddr);=
<br>
 }<br>
 <br>
 /**<br>
diff -Nru a/net/ipv6/mcast.c b/net/ipv6/mcast.c<br>
--- a/net/ipv6/mcast.c		 2004-11-10 16:45:07 +09:00<br>
+++ b/net/ipv6/mcast.c		 2004-11-10 16:45:07 +09:00<br>
@@ -247,7 +247,7 @@<br>
 		 write_lock_bh(&amp;ipv6_sk_mc_lock);<br>
 		 for (lnk =3D &amp;np-&gt;ipv6_mc_list; (mc_lst =3D *lnk) !=3DNULL ;=
 lnk =3D &amp;mc_lst-&gt;next) {<br>
 		 		 if ((ifindex =3D=3D 0 || mc_lst-&gt;ifindex =3D=3D ifindex) &amp=
;&amp;<br>
-		 		 &nbsp; &nbsp; ipv6_addr_cmp(&amp;mc_lst-&gt;addr, addr) =3D=3D 0=
) {<br>
+		 		 &nbsp; &nbsp; ipv6_addr_equal(&amp;mc_lst-&gt;addr, addr)) {<br>=

 		 		 		 struct net_device *dev;<br>
 <br>
 		 		 		 *lnk =3D mc_lst-&gt;next;<br>
@@ -369,7 +369,7 @@<br>
 		 for (pmc=3Dinet6-&gt;ipv6_mc_list; pmc; pmc=3Dpmc-&gt;next) {<br>
 		 		 if (pgsr-&gt;gsr_interface &amp;&amp; pmc-&gt;ifindex !=3D pgsr-=
&gt;gsr_interface)<br>
 		 		 		 continue;<br>
-		 		 if (ipv6_addr_cmp(&amp;pmc-&gt;addr, group) =3D=3D 0)<br>
+		 		 if (ipv6_addr_equal(&amp;pmc-&gt;addr, group))<br>
 		 		 		 break;<br>
 		 }<br>
 		 if (!pmc)		 		 /* must have a prior join */<br>
@@ -485,7 +485,7 @@<br>
 		 for (pmc=3Dinet6-&gt;ipv6_mc_list; pmc; pmc=3Dpmc-&gt;next) {<br>
 		 		 if (pmc-&gt;ifindex !=3D gsf-&gt;gf_interface)<br>
 		 		 		 continue;<br>
-		 		 if (ipv6_addr_cmp(&amp;pmc-&gt;addr, group) =3D=3D 0)<br>
+		 		 if (ipv6_addr_equal(&amp;pmc-&gt;addr, group))<br>
 		 		 		 break;<br>
 		 }<br>
 		 if (!pmc)		 		 /* must have a prior join */<br>
@@ -556,7 +556,7 @@<br>
 		 for (pmc=3Dinet6-&gt;ipv6_mc_list; pmc; pmc=3Dpmc-&gt;next) {<br>
 		 		 if (pmc-&gt;ifindex !=3D gsf-&gt;gf_interface)<br>
 		 		 		 continue;<br>
-		 		 if (ipv6_addr_cmp(group, &amp;pmc-&gt;addr) =3D=3D 0)<br>
+		 		 if (ipv6_addr_equal(group, &amp;pmc-&gt;addr))<br>
 		 		 		 break;<br>
 		 }<br>
 		 if (!pmc)		 		 /* must have a prior join */<br>
@@ -603,7 +603,7 @@<br>
 <br>
 		 read_lock(&amp;ipv6_sk_mc_lock);<br>
 		 for (mc =3D np-&gt;ipv6_mc_list; mc; mc =3D mc-&gt;next) {<br>
-		 		 if (ipv6_addr_cmp(&amp;mc-&gt;addr, mc_addr) =3D=3D 0)<br>
+		 		 if (ipv6_addr_equal(&amp;mc-&gt;addr, mc_addr))<br>
 		 		 		 break;<br>
 		 }<br>
 		 if (!mc) {<br>
@@ -617,7 +617,7 @@<br>
 		 		 int i;<br>
 <br>
 		 		 for (i=3D0; i&lt;psl-&gt;sl_count; i++) {<br>
-		 		 		 if (ipv6_addr_cmp(&amp;psl-&gt;sl_addr[i], src_addr) =3D=3D 0=
)<br>
+		 		 		 if (ipv6_addr_equal(&amp;psl-&gt;sl_addr[i], src_addr))<br>
 		 		 		 		 break;<br>
 		 		 }<br>
 		 		 if (mc-&gt;sfmode =3D=3D MCAST_INCLUDE &amp;&amp; i &gt;=3D psl-=
&gt;sl_count)<br>
@@ -740,7 +740,7 @@<br>
 		 write_lock_bh(&amp;idev-&gt;mc_lock);<br>
 		 pmc_prev =3D NULL;<br>
 		 for (pmc=3Didev-&gt;mc_tomb; pmc; pmc=3Dpmc-&gt;next) {<br>
-		 		 if (ipv6_addr_cmp(&amp;pmc-&gt;mca_addr, pmca) =3D=3D 0)<br>
+		 		 if (ipv6_addr_equal(&amp;pmc-&gt;mca_addr, pmca))<br>
 		 		 		 break;<br>
 		 		 pmc_prev =3D pmc;<br>
 		 }<br>
@@ -816,7 +816,7 @@<br>
 		 }<br>
 <br>
 		 for (mc =3D idev-&gt;mc_list; mc; mc =3D mc-&gt;next) {<br>
-		 		 if (ipv6_addr_cmp(&amp;mc-&gt;mca_addr, addr) =3D=3D 0) {<br>
+		 		 if (ipv6_addr_equal(&amp;mc-&gt;mca_addr, addr)) {<br>
 		 		 		 mc-&gt;mca_users++;<br>
 		 		 		 write_unlock_bh(&amp;idev-&gt;lock);<br>
 		 		 		 ip6_mc_add_src(idev, &amp;mc-&gt;mca_addr, MCAST_EXCLUDE, 0,<=
br>
@@ -878,7 +878,7 @@<br>
 <br>
 		 write_lock_bh(&amp;idev-&gt;lock);<br>
 		 for (map =3D &amp;idev-&gt;mc_list; (ma=3D*map) !=3D NULL; map =3D =
&amp;ma-&gt;next) {<br>
-		 		 if (ipv6_addr_cmp(&amp;ma-&gt;mca_addr, addr) =3D=3D 0) {<br>
+		 		 if (ipv6_addr_equal(&amp;ma-&gt;mca_addr, addr)) {<br>
 		 		 		 if (--ma-&gt;mca_users =3D=3D 0) {<br>
 		 		 		 		 *map =3D ma-&gt;next;<br>
 		 		 		 		 write_unlock_bh(&amp;idev-&gt;lock);<br>
@@ -953,7 +953,7 @@<br>
 		 if (idev) {<br>
 		 		 read_lock_bh(&amp;idev-&gt;lock);<br>
 		 		 for (mc =3D idev-&gt;mc_list; mc; mc=3Dmc-&gt;next) {<br>
-		 		 		 if (ipv6_addr_cmp(&amp;mc-&gt;mca_addr, group) =3D=3D 0)<br>
+		 		 		 if (ipv6_addr_equal(&amp;mc-&gt;mca_addr, group))<br>
 		 		 		 		 break;<br>
 		 		 }<br>
 		 		 if (mc) {<br>
@@ -962,8 +962,7 @@<br>
 <br>
 		 		 		 		 spin_lock_bh(&amp;mc-&gt;mca_lock);<br>
 		 		 		 		 for (psf=3Dmc-&gt;mca_sources;psf;psf=3Dpsf-&gt;sf_next) {=
<br>
-		 		 		 		 		 if (ipv6_addr_cmp(&amp;psf-&gt;sf_addr,<br>
-		 		 		 		 		 &nbsp; &nbsp; src_addr) =3D=3D 0)<br>
+		 		 		 		 		 if (ipv6_addr_equal(&amp;psf-&gt;sf_addr, src_addr))<br=
>
 		 		 		 		 		 		 break;<br>
 		 		 		 		 }<br>
 		 		 		 		 if (psf)<br>
@@ -1040,7 +1039,7 @@<br>
 		 		 if (scount =3D=3D nsrcs)<br>
 		 		 		 break;<br>
 		 		 for (i=3D0; i&lt;nsrcs; i++)<br>
-		 		 		 if (ipv6_addr_cmp(&amp;srcs[i], &amp;psf-&gt;sf_addr) =3D=3D =
0) {<br>
+		 		 		 if (ipv6_addr_equal(&amp;srcs[i], &amp;psf-&gt;sf_addr)) {<br=
>
 		 		 		 		 psf-&gt;sf_gsresp =3D 1;<br>
 		 		 		 		 scount++;<br>
 		 		 		 		 break;<br>
@@ -1135,7 +1134,7 @@<br>
 		 } else {<br>
 		 		 for (ma =3D idev-&gt;mc_list; ma; ma=3Dma-&gt;next) {<br>
 		 		 		 if (group_type !=3D IPV6_ADDR_ANY &amp;&amp;<br>
-		 		 		 &nbsp; &nbsp; ipv6_addr_cmp(group, &amp;ma-&gt;mca_addr) !=3D=
 0)<br>
+		 		 		 &nbsp; &nbsp; !ipv6_addr_equal(group, &amp;ma-&gt;mca_addr))<=
br>
 		 		 		 		 continue;<br>
 		 		 		 spin_lock_bh(&amp;ma-&gt;mca_lock);<br>
 		 		 		 if (ma-&gt;mca_flags &amp; MAF_TIMER_RUNNING) {<br>
@@ -1200,7 +1199,7 @@<br>
 <br>
 		 read_lock_bh(&amp;idev-&gt;lock);<br>
 		 for (ma =3D idev-&gt;mc_list; ma; ma=3Dma-&gt;next) {<br>
-		 		 if (ipv6_addr_cmp(&amp;ma-&gt;mca_addr, addrp) =3D=3D 0) {<br>
+		 		 if (ipv6_addr_equal(&amp;ma-&gt;mca_addr, addrp)) {<br>
 		 		 		 spin_lock(&amp;ma-&gt;mca_lock);<br>
 		 		 		 if (del_timer(&amp;ma-&gt;mca_timer))<br>
 		 		 		 		 atomic_dec(&amp;ma-&gt;mca_refcnt);<br>
@@ -1695,7 +1694,7 @@<br>
 <br>
 		 psf_prev =3D NULL;<br>
 		 for (psf=3Dpmc-&gt;mca_sources; psf; psf=3Dpsf-&gt;sf_next) {<br>
-		 		 if (ipv6_addr_cmp(&amp;psf-&gt;sf_addr, psfsrc) =3D=3D 0)<br>
+		 		 if (ipv6_addr_equal(&amp;psf-&gt;sf_addr, psfsrc))<br>
 		 		 		 break;<br>
 		 		 psf_prev =3D psf;<br>
 		 }<br>
@@ -1735,7 +1734,7 @@<br>
 		 		 return -ENODEV;<br>
 		 read_lock_bh(&amp;idev-&gt;lock);<br>
 		 for (pmc=3Didev-&gt;mc_list; pmc; pmc=3Dpmc-&gt;next) {<br>
-		 		 if (ipv6_addr_cmp(pmca, &amp;pmc-&gt;mca_addr) =3D=3D 0)<br>
+		 		 if (ipv6_addr_equal(pmca, &amp;pmc-&gt;mca_addr))<br>
 		 		 		 break;<br>
 		 }<br>
 		 if (!pmc) {<br>
@@ -1790,7 +1789,7 @@<br>
 <br>
 		 psf_prev =3D NULL;<br>
 		 for (psf=3Dpmc-&gt;mca_sources; psf; psf=3Dpsf-&gt;sf_next) {<br>
-		 		 if (ipv6_addr_cmp(&amp;psf-&gt;sf_addr, psfsrc) =3D=3D 0)<br>
+		 		 if (ipv6_addr_equal(&amp;psf-&gt;sf_addr, psfsrc))<br>
 		 		 		 break;<br>
 		 		 psf_prev =3D psf;<br>
 		 }<br>
@@ -1859,7 +1858,7 @@<br>
 		 		 return -ENODEV;<br>
 		 read_lock_bh(&amp;idev-&gt;lock);<br>
 		 for (pmc=3Didev-&gt;mc_list; pmc; pmc=3Dpmc-&gt;next) {<br>
-		 		 if (ipv6_addr_cmp(pmca, &amp;pmc-&gt;mca_addr) =3D=3D 0)<br>
+		 		 if (ipv6_addr_equal(pmca, &amp;pmc-&gt;mca_addr))<br>
 		 		 		 break;<br>
 		 }<br>
 		 if (!pmc) {<br>
diff -Nru a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c<br>
--- a/net/ipv6/ndisc.c		 2004-11-10 16:45:07 +09:00<br>
+++ b/net/ipv6/ndisc.c		 2004-11-10 16:45:07 +09:00<br>
@@ -1219,7 +1219,7 @@<br>
 		 		 return;<br>
 		 }<br>
 <br>
-		 if (ipv6_addr_cmp(dest, target) =3D=3D 0) {<br>
+		 if (ipv6_addr_equal(dest, target)) {<br>
 		 		 on_link =3D 1;<br>
 		 } else if (!(ipv6_addr_type(target) &amp; IPV6_ADDR_LINKLOCAL)) {<b=
r>
 		 		 ND_PRINTK2(KERN_WARNING <br>
diff -Nru a/net/ipv6/netfilter/ip6_queue.c b/net/ipv6/netfilter/ip6_que=
ue.c<br>
--- a/net/ipv6/netfilter/ip6_queue.c		 2004-11-10 16:45:07 +09:00<br>
+++ b/net/ipv6/netfilter/ip6_queue.c		 2004-11-10 16:45:07 +09:00<br>
@@ -376,8 +376,8 @@<br>
 		 &nbsp;*/<br>
 		 if (e-&gt;info-&gt;hook =3D=3D NF_IP_LOCAL_OUT) {<br>
 		 		 struct ipv6hdr *iph =3D e-&gt;skb-&gt;nh.ipv6h;<br>
-		 		 if (ipv6_addr_cmp(&amp;iph-&gt;daddr, &amp;e-&gt;rt_info.daddr) =
||<br>
-		 		 &nbsp; &nbsp; ipv6_addr_cmp(&amp;iph-&gt;saddr, &amp;e-&gt;rt_in=
fo.saddr))<br>
+		 		 if (!ipv6_addr_equal(&amp;iph-&gt;daddr, &amp;e-&gt;rt_info.dadd=
r) ||<br>
+		 		 &nbsp; &nbsp; !ipv6_addr_equal(&amp;iph-&gt;saddr, &amp;e-&gt;rt=
_info.saddr))<br>
 		 		 		 return ip6_route_me_harder(e-&gt;skb);<br>
 		 }<br>
 		 return 0;<br>
diff -Nru a/net/ipv6/netfilter/ip6t_rt.c b/net/ipv6/netfilter/ip6t_rt.c=
<br>
--- a/net/ipv6/netfilter/ip6t_rt.c		 2004-11-10 16:45:07 +09:00<br>
+++ b/net/ipv6/netfilter/ip6t_rt.c		 2004-11-10 16:45:07 +09:00<br>
@@ -209,7 +209,7 @@<br>
 <br>
 		 		 		 		 BUG_ON(ap =3D=3D NULL);<br>
 <br>
-		 		 		 		 if (!ipv6_addr_cmp(ap, &amp;rtinfo-&gt;addrs[i])) {<br>
+		 		 		 		 if (ipv6_addr_equal(ap, &amp;rtinfo-&gt;addrs[i])) {<br>
 		 		 		 		 		 DEBUGP(&quot;i=3D%d temp=3D%d;\n&quot;,i,temp);<br>
 		 		 		 		 		 i++;<br>
 		 		 		 		 }<br>
@@ -236,7 +236,7 @@<br>
 		 		 		 		 		 		 		 &amp;_addr);<br>
 		 		 		 		 BUG_ON(ap =3D=3D NULL);<br>
 <br>
-		 		 		 		 if (ipv6_addr_cmp(ap, &amp;rtinfo-&gt;addrs[temp]))<br>
+		 		 		 		 if (!ipv6_addr_equal(ap, &amp;rtinfo-&gt;addrs[temp]))<br>=

 		 		 		 		 		 break;<br>
 		 		 		 }<br>
 		 		 		 DEBUGP(&quot;temp=3D%d #%d\n&quot;, temp, rtinfo-&gt;addrnr);=
<br>
diff -Nru a/net/ipv6/raw.c b/net/ipv6/raw.c<br>
--- a/net/ipv6/raw.c		 2004-11-10 16:45:07 +09:00<br>
+++ b/net/ipv6/raw.c		 2004-11-10 16:45:07 +09:00<br>
@@ -90,11 +90,11 @@<br>
 		 		 		 struct ipv6_pinfo *np =3D inet6_sk(sk);<br>
 <br>
 		 		 		 if (!ipv6_addr_any(&amp;np-&gt;daddr) &amp;&amp;<br>
-		 		 		 &nbsp; &nbsp; ipv6_addr_cmp(&amp;np-&gt;daddr, rmt_addr))<br>=

+		 		 		 &nbsp; &nbsp; !ipv6_addr_equal(&amp;np-&gt;daddr, rmt_addr))<=
br>
 		 		 		 		 continue;<br>
 <br>
 		 		 		 if (!ipv6_addr_any(&amp;np-&gt;rcv_saddr)) {<br>
-		 		 		 		 if (!ipv6_addr_cmp(&amp;np-&gt;rcv_saddr, loc_addr))<br>
+		 		 		 		 if (ipv6_addr_equal(&amp;np-&gt;rcv_saddr, loc_addr))<br>
 		 		 		 		 		 goto found;<br>
 		 		 		 		 if (is_multicast &amp;&amp;<br>
 		 		 		 		 &nbsp; &nbsp; inet6_mc_check(sk, loc_addr, rmt_addr))<br>
@@ -668,7 +668,7 @@<br>
 		 		 &nbsp;* sk-&gt;sk_dst_cache.<br>
 		 		 &nbsp;*/<br>
 		 		 if (sk-&gt;sk_state =3D=3D TCP_ESTABLISHED &amp;&amp;<br>
-		 		 &nbsp; &nbsp; !ipv6_addr_cmp(daddr, &amp;np-&gt;daddr))<br>
+		 		 &nbsp; &nbsp; ipv6_addr_equal(daddr, &amp;np-&gt;daddr))<br>
 		 		 		 daddr =3D &amp;np-&gt;daddr;<br>
 <br>
 		 		 if (addr_len &gt;=3D sizeof(struct sockaddr_in6) &amp;&amp;<br>
@@ -775,7 +775,7 @@<br>
 		 }<br>
 done:<br>
 		 ip6_dst_store(sk, dst,<br>
-		 		 &nbsp; &nbsp; &nbsp; !ipv6_addr_cmp(&amp;fl.fl6_dst, &amp;np-&gt=
;daddr) ?<br>
+		 		 &nbsp; &nbsp; &nbsp; ipv6_addr_equal(&amp;fl.fl6_dst, &amp;np-&g=
t;daddr) ?<br>
 		 		 &nbsp; &nbsp; &nbsp; &amp;np-&gt;daddr : NULL);<br>
 		 if (err &gt; 0)<br>
 		 		 err =3D np-&gt;recverr ? net_xmit_errno(err) : 0;<br>
diff -Nru a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c<br>
--- a/net/ipv6/reassembly.c		 2004-11-10 16:45:07 +09:00</tt><br>
<tt>+++ b/net/ipv6/reassembly.c		 2004-11-10 16:45:07 +09:00<br>
@@ -342,8 +342,8 @@<br>
 #ifdef CONFIG_SMP<br>
 		 for (fq =3D ip6_frag_hash[hash]; fq; fq =3D fq-&gt;next) {<br>
 		 		 if (fq-&gt;id =3D=3D fq_in-&gt;id &amp;&amp; <br>
-		 		 &nbsp; &nbsp; !ipv6_addr_cmp(&amp;fq_in-&gt;saddr, &amp;fq-&gt;s=
addr) &amp;&amp;<br>
-		 		 &nbsp; &nbsp; !ipv6_addr_cmp(&amp;fq_in-&gt;daddr, &amp;fq-&gt;d=
addr)) {<br>
+		 		 &nbsp; &nbsp; ipv6_addr_equal(&amp;fq_in-&gt;saddr, &amp;fq-&gt;=
saddr) &amp;&amp;<br>
+		 		 &nbsp; &nbsp; ipv6_addr_equal(&amp;fq_in-&gt;daddr, &amp;fq-&gt;=
daddr)) {<br>
 		 		 		 atomic_inc(&amp;fq-&gt;refcnt);<br>
 		 		 		 write_unlock(&amp;ip6_frag_lock);<br>
 		 		 		 fq_in-&gt;last_in |=3D COMPLETE;<br>
@@ -406,8 +406,8 @@<br>
 		 read_lock(&amp;ip6_frag_lock);<br>
 		 for(fq =3D ip6_frag_hash[hash]; fq; fq =3D fq-&gt;next) {<br>
 		 		 if (fq-&gt;id =3D=3D id &amp;&amp; <br>
-		 		 &nbsp; &nbsp; !ipv6_addr_cmp(src, &amp;fq-&gt;saddr) &amp;&amp;<=
br>
-		 		 &nbsp; &nbsp; !ipv6_addr_cmp(dst, &amp;fq-&gt;daddr)) {<br>
+		 		 &nbsp; &nbsp; ipv6_addr_equal(src, &amp;fq-&gt;saddr) &amp;&amp;=
<br>
+		 		 &nbsp; &nbsp; ipv6_addr_equal(dst, &amp;fq-&gt;daddr)) {<br>
 		 		 		 atomic_inc(&amp;fq-&gt;refcnt);<br>
 		 		 		 read_unlock(&amp;ip6_frag_lock);<br>
 		 		 		 return fq;<br>
diff -Nru a/net/ipv6/route.c b/net/ipv6/route.c<br>
--- a/net/ipv6/route.c		 2004-11-10 16:45:07 +09:00<br>
+++ b/net/ipv6/route.c		 2004-11-10 16:45:07 +09:00<br>
@@ -1006,7 +1006,7 @@<br>
 		 		 		 &nbsp; &nbsp; &nbsp;rt-&gt;rt6i_dev-&gt;ifindex !=3D rtmsg-&g=
t;rtmsg_ifindex))<br>
 		 		 		 		 continue;<br>
 		 		 		 if (rtmsg-&gt;rtmsg_flags&amp;RTF_GATEWAY &amp;&amp;<br>
-		 		 		 &nbsp; &nbsp; ipv6_addr_cmp(&amp;rtmsg-&gt;rtmsg_gateway, &am=
p;rt-&gt;rt6i_gateway))<br>
+		 		 		 &nbsp; &nbsp; !ipv6_addr_equal(&amp;rtmsg-&gt;rtmsg_gateway, =
&amp;rt-&gt;rt6i_gateway))<br>
 		 		 		 		 continue;<br>
 		 		 		 if (rtmsg-&gt;rtmsg_metric &amp;&amp;<br>
 		 		 		 &nbsp; &nbsp; rtmsg-&gt;rtmsg_metric !=3D rt-&gt;rt6i_metric)=
<br>
@@ -1057,13 +1057,13 @@<br>
 		 &nbsp;*		 is a bit fuzzy and one might need to check all default<br=
>
 		 &nbsp;*		 routers.<br>
 		 &nbsp;*/<br>
-		 if (ipv6_addr_cmp(saddr, &amp;rt-&gt;rt6i_gateway)) {<br>
+		 if (!ipv6_addr_equal(saddr, &amp;rt-&gt;rt6i_gateway)) {<br>
 		 		 if (rt-&gt;rt6i_flags &amp; RTF_DEFAULT) {<br>
 		 		 		 struct rt6_info *rt1;<br>
 <br>
 		 		 		 read_lock(&amp;rt6_lock);<br>
 		 		 		 for (rt1 =3D ip6_routing_table.leaf; rt1; rt1 =3D rt1-&gt;u.n=
ext) {<br>
-		 		 		 		 if (!ipv6_addr_cmp(saddr, &amp;rt1-&gt;rt6i_gateway)) {<br=
>
+		 		 		 		 if (ipv6_addr_equal(saddr, &amp;rt1-&gt;rt6i_gateway)) {<b=
r>
 		 		 		 		 		 dst_hold(&amp;rt1-&gt;u.dst);<br>
 		 		 		 		 		 dst_release(&amp;rt-&gt;u.dst);<br>
 		 		 		 		 		 read_unlock(&amp;rt6_lock);<br>
@@ -1262,7 +1262,7 @@<br>
 		 write_lock_bh(&amp;rt6_lock);<br>
 		 for (rt =3D fn-&gt;leaf; rt; rt=3Drt-&gt;u.next) {<br>
 		 		 if (dev =3D=3D rt-&gt;rt6i_dev &amp;&amp;<br>
-		 		 &nbsp; &nbsp; ipv6_addr_cmp(&amp;rt-&gt;rt6i_gateway, addr) =3D=3D=
 0)<br>
+		 		 &nbsp; &nbsp; ipv6_addr_equal(&amp;rt-&gt;rt6i_gateway, addr))<b=
r>
 		 		 		 break;<br>
 		 }<br>
 		 if (rt)<br>
diff -Nru a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c<br>
--- a/net/ipv6/tcp_ipv6.c		 2004-11-10 16:45:07 +09:00<br>
+++ b/net/ipv6/tcp_ipv6.c		 2004-11-10 16:45:07 +09:00<br>
@@ -262,7 +262,7 @@<br>
 		 		 		 <br>
 		 		 		 score =3D 1;<br>
 		 		 		 if (!ipv6_addr_any(&amp;np-&gt;rcv_saddr)) {<br>
-		 		 		 		 if (ipv6_addr_cmp(&amp;np-&gt;rcv_saddr, daddr))<br>
+		 		 		 		 if (!ipv6_addr_equal(&amp;np-&gt;rcv_saddr, daddr))<br>
 		 		 		 		 		 continue;<br>
 		 		 		 		 score++;<br>
 		 		 		 }<br>
@@ -321,8 +321,8 @@<br>
 <br>
 		 		 if(*((__u32 *)&amp;(tw-&gt;tw_dport))		 =3D=3D ports		 &amp;&amp=
;<br>
 		 		 &nbsp; &nbsp;sk-&gt;sk_family		 		 =3D=3D PF_INET6) {<br>
-		 		 		 if(!ipv6_addr_cmp(&amp;tw-&gt;tw_v6_daddr, saddr)		 &amp;&amp=
;<br>
-		 		 		 &nbsp; &nbsp;!ipv6_addr_cmp(&amp;tw-&gt;tw_v6_rcv_saddr, dadd=
r)		 &amp;&amp;<br>
+		 		 		 if(ipv6_addr_equal(&amp;tw-&gt;tw_v6_daddr, saddr)		 &amp;&am=
p;<br>
+		 		 		 &nbsp; &nbsp;ipv6_addr_equal(&amp;tw-&gt;tw_v6_rcv_saddr, dad=
dr)		 &amp;&amp;<br>
 		 		 		 &nbsp; &nbsp;(!sk-&gt;sk_bound_dev_if || sk-&gt;sk_bound_dev_=
if =3D=3D dif))<br>
 		 		 		 		 goto hit;<br>
 		 		 }<br>
@@ -406,8 +406,8 @@<br>
 		 &nbsp; &nbsp; &nbsp;prev =3D &amp;req-&gt;dl_next) {<br>
 		 		 if (req-&gt;rmt_port =3D=3D rport &amp;&amp;<br>
 		 		 &nbsp; &nbsp; req-&gt;class-&gt;family =3D=3D AF_INET6 &amp;&amp=
;<br>
-		 		 &nbsp; &nbsp; !ipv6_addr_cmp(&amp;req-&gt;af.v6_req.rmt_addr, ra=
ddr) &amp;&amp;<br>
-		 		 &nbsp; &nbsp; !ipv6_addr_cmp(&amp;req-&gt;af.v6_req.loc_addr, la=
ddr) &amp;&amp;<br>
+		 		 &nbsp; &nbsp; ipv6_addr_equal(&amp;req-&gt;af.v6_req.rmt_addr, r=
addr) &amp;&amp;<br>
+		 		 &nbsp; &nbsp; ipv6_addr_equal(&amp;req-&gt;af.v6_req.loc_addr, l=
addr) &amp;&amp;<br>
 		 		 &nbsp; &nbsp; (!req-&gt;af.v6_req.iif || req-&gt;af.v6_req.iif =3D=
=3D iif)) {<br>
 		 		 		 BUG_TRAP(req-&gt;sk =3D=3D NULL);<br>
 		 		 		 *prevp =3D prev;<br>
@@ -463,8 +463,8 @@<br>
 <br>
 		 		 if(*((__u32 *)&amp;(tw-&gt;tw_dport))		 =3D=3D ports		 &amp;&amp=
;<br>
 		 		 &nbsp; &nbsp;sk2-&gt;sk_family		 		 =3D=3D PF_INET6		 &amp;&amp;=
<br>
-		 		 &nbsp; &nbsp;!ipv6_addr_cmp(&amp;tw-&gt;tw_v6_daddr, saddr)		 &a=
mp;&amp;<br>
-		 		 &nbsp; &nbsp;!ipv6_addr_cmp(&amp;tw-&gt;tw_v6_rcv_saddr, daddr)	=
	 &amp;&amp;<br>
+		 		 &nbsp; &nbsp;ipv6_addr_equal(&amp;tw-&gt;tw_v6_daddr, saddr)		 &=
amp;&amp;<br>
+		 		 &nbsp; &nbsp;ipv6_addr_equal(&amp;tw-&gt;tw_v6_rcv_saddr, daddr)=
		 &amp;&amp;<br>
 		 		 &nbsp; &nbsp;sk2-&gt;sk_bound_dev_if =3D=3D sk-&gt;sk_bound_dev_=
if) {<br>
 		 		 		 struct tcp_opt *tp =3D tcp_sk(sk);<br>
 <br>
@@ -610,7 +610,7 @@<br>
 		 }<br>
 <br>
 		 if (tp-&gt;ts_recent_stamp &amp;&amp;<br>
-		 &nbsp; &nbsp; ipv6_addr_cmp(&amp;np-&gt;daddr, &amp;usin-&gt;sin6_a=
ddr)) {<br>
+		 &nbsp; &nbsp; !ipv6_addr_equal(&amp;np-&gt;daddr, &amp;usin-&gt;sin=
6_addr)) {<br>
 		 		 tp-&gt;ts_recent =3D 0;<br>
 		 		 tp-&gt;ts_recent_stamp =3D 0;<br>
 		 		 tp-&gt;write_seq =3D 0;<br>
diff -Nru a/net/ipv6/udp.c b/net/ipv6/udp.c<br>
--- a/net/ipv6/udp.c		 2004-11-10 16:45:07 +09:00<br>
+++ b/net/ipv6/udp.c		 2004-11-10 16:45:07 +09:00<br>
@@ -171,12 +171,12 @@<br>
 		 		 		 		 score++;<br>
 		 		 		 }<br>
 		 		 		 if (!ipv6_addr_any(&amp;np-&gt;rcv_saddr)) {<br>
-		 		 		 		 if (ipv6_addr_cmp(&amp;np-&gt;rcv_saddr, daddr))<br>
+		 		 		 		 if (!ipv6_addr_equal(&amp;np-&gt;rcv_saddr, daddr))<br>
 		 		 		 		 		 continue;<br>
 		 		 		 		 score++;<br>
 		 		 		 }<br>
 		 		 		 if (!ipv6_addr_any(&amp;np-&gt;daddr)) {<br>
-		 		 		 		 if (ipv6_addr_cmp(&amp;np-&gt;daddr, saddr))<br>
+		 		 		 		 if (!ipv6_addr_equal(&amp;np-&gt;daddr, saddr))<br>
 		 		 		 		 		 continue;<br>
 		 		 		 		 score++;<br>
 		 		 		 }<br>
@@ -395,14 +395,14 @@<br>
 		 		 		 		 		 continue;<br>
 		 		 		 }<br>
 		 		 		 if (!ipv6_addr_any(&amp;np-&gt;daddr) &amp;&amp;<br>
-		 		 		 &nbsp; &nbsp; ipv6_addr_cmp(&amp;np-&gt;daddr, rmt_addr))<br>=

+		 		 		 &nbsp; &nbsp; !ipv6_addr_equal(&amp;np-&gt;daddr, rmt_addr))<=
br>
 		 		 		 		 continue;<br>
 <br>
 		 		 		 if (s-&gt;sk_bound_dev_if &amp;&amp; s-&gt;sk_bound_dev_if !=3D=
 dif)<br>
 		 		 		 		 continue;<br>
 <br>
 		 		 		 if (!ipv6_addr_any(&amp;np-&gt;rcv_saddr)) {<br>
-		 		 		 		 if (!ipv6_addr_cmp(&amp;np-&gt;rcv_saddr, loc_addr))<br>
+		 		 		 		 if (ipv6_addr_equal(&amp;np-&gt;rcv_saddr, loc_addr))<br>
 		 		 		 		 		 return s;<br>
 		 		 		 		 continue;<br>
 		 		 		 }<br>
@@ -732,7 +732,7 @@<br>
 		 		 &nbsp;* sk-&gt;sk_dst_cache.<br>
 		 		 &nbsp;*/<br>
 		 		 if (sk-&gt;sk_state =3D=3D TCP_ESTABLISHED &amp;&amp;<br>
-		 		 &nbsp; &nbsp; !ipv6_addr_cmp(daddr, &amp;np-&gt;daddr))<br>
+		 		 &nbsp; &nbsp; ipv6_addr_equal(daddr, &amp;np-&gt;daddr))<br>
 		 		 		 daddr =3D &amp;np-&gt;daddr;<br>
 <br>
 		 		 if (addr_len &gt;=3D sizeof(struct sockaddr_in6) &amp;&amp;<br>
@@ -840,7 +840,7 @@<br>
 <br>
 		 if (dst)<br>
 		 		 ip6_dst_store(sk, dst,<br>
-		 		 		 &nbsp; &nbsp; &nbsp; !ipv6_addr_cmp(&amp;fl-&gt;fl6_dst, &amp=
;np-&gt;daddr) ?<br>
+		 		 		 &nbsp; &nbsp; &nbsp; ipv6_addr_equal(&amp;fl-&gt;fl6_dst, &am=
p;np-&gt;daddr) ?<br>
 		 		 		 &nbsp; &nbsp; &nbsp; &amp;np-&gt;daddr : NULL);<br>
 		 if (err &gt; 0)<br>
 		 		 err =3D np-&gt;recverr ? net_xmit_errno(err) : 0;<br>
diff -Nru a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c<br>
--- a/net/ipv6/xfrm6_policy.c		 2004-11-10 16:45:07 +09:00<br>
+++ b/net/ipv6/xfrm6_policy.c		 2004-11-10 16:45:07 +09:00<br>
@@ -68,8 +68,8 @@<br>
 		 		 ipv6_addr_prefix(&amp;fl_src_prefix,<br>
 		 		 		 		 &nbsp;&amp;fl-&gt;fl6_src,<br>
 		 		 		 		 &nbsp;xdst-&gt;u.rt6.rt6i_src.plen);<br>
-		 		 if (!ipv6_addr_cmp(&amp;xdst-&gt;u.rt6.rt6i_dst.addr, &amp;fl_ds=
t_prefix) &amp;&amp;<br>
-		 		 &nbsp; &nbsp; !ipv6_addr_cmp(&amp;xdst-&gt;u.rt6.rt6i_src.addr, =
&amp;fl_src_prefix) &amp;&amp;<br>
+		 		 if (ipv6_addr_equal(&amp;xdst-&gt;u.rt6.rt6i_dst.addr, &amp;fl_d=
st_prefix) &amp;&amp;<br>
+		 		 &nbsp; &nbsp; ipv6_addr_equal(&amp;xdst-&gt;u.rt6.rt6i_src.addr,=
 &amp;fl_src_prefix) &amp;&amp;<br>
 		 		 &nbsp; &nbsp; __xfrm6_bundle_ok(xdst, fl)) {<br>
 		 		 		 dst_clone(dst);<br>
 		 		 		 break;<br>
@@ -123,7 +123,7 @@<br>
 		 		 trailer_len +=3D xfrm[i]-&gt;props.trailer_len;<br>
 		 }<br>
 <br>
-		 if (ipv6_addr_cmp(remote, &amp;fl-&gt;fl6_dst)) {<br>
+		 if (!ipv6_addr_equal(remote, &amp;fl-&gt;fl6_dst)) {<br>
 		 		 struct flowi fl_tunnel;<br>
 <br>
 		 		 memset(&amp;fl_tunnel, 0, sizeof(fl_tunnel));<br>
diff -Nru a/net/ipv6/xfrm6_state.c b/net/ipv6/xfrm6_state.c<br>
--- a/net/ipv6/xfrm6_state.c		 2004-11-10 16:45:07 +09:00<br>
+++ b/net/ipv6/xfrm6_state.c		 2004-11-10 16:45:07 +09:00<br>
@@ -55,7 +55,7 @@<br>
 		 list_for_each_entry(x, xfrm6_state_afinfo.state_byspi+h, byspi) {<b=
r>
 		 		 if (x-&gt;props.family =3D=3D AF_INET6 &amp;&amp;<br>
 		 		 &nbsp; &nbsp; spi =3D=3D x-&gt;id.spi &amp;&amp;<br>
-		 		 &nbsp; &nbsp; !ipv6_addr_cmp((struct in6_addr *)daddr, (struct i=
n6_addr *)x-&gt;id.daddr.a6) &amp;&amp;<br>
+		 		 &nbsp; &nbsp; ipv6_addr_equal((struct in6_addr *)daddr, (struct =
in6_addr *)x-&gt;id.daddr.a6) &amp;&amp;<br>
 		 		 &nbsp; &nbsp; proto =3D=3D x-&gt;id.proto) {<br>
 		 		 		 xfrm_state_hold(x);<br>
 		 		 		 return x;<br>
@@ -76,10 +76,10 @@<br>
 <br>
 		 list_for_each_entry(x, xfrm6_state_afinfo.state_bydst+h, bydst) {<b=
r>
 		 		 if (x-&gt;props.family =3D=3D AF_INET6 &amp;&amp;<br>
-		 		 &nbsp; &nbsp; !ipv6_addr_cmp((struct in6_addr *)daddr, (struct i=
n6_addr *)x-&gt;id.daddr.a6) &amp;&amp;<br>
+		 		 &nbsp; &nbsp; ipv6_addr_equal((struct in6_addr *)daddr, (struct =
in6_addr *)x-&gt;id.daddr.a6) &amp;&amp;<br>
 		 		 &nbsp; &nbsp; mode =3D=3D x-&gt;props.mode &amp;&amp;<br>
 		 		 &nbsp; &nbsp; proto =3D=3D x-&gt;id.proto &amp;&amp;<br>
-		 		 &nbsp; &nbsp; !ipv6_addr_cmp((struct in6_addr *)saddr, (struct i=
n6_addr *)x-&gt;props.saddr.a6) &amp;&amp;<br>
+		 		 &nbsp; &nbsp; ipv6_addr_equal((struct in6_addr *)saddr, (struct =
in6_addr *)x-&gt;props.saddr.a6) &amp;&amp;<br>
 		 		 &nbsp; &nbsp; reqid =3D=3D x-&gt;props.reqid &amp;&amp;<br>
 		 		 &nbsp; &nbsp; x-&gt;km.state =3D=3D XFRM_STATE_ACQ &amp;&amp;<br=
>
 		 		 &nbsp; &nbsp; !x-&gt;id.spi) {<br>
diff -Nru a/net/sctp/ipv6.c b/net/sctp/ipv6.c<br>
--- a/net/sctp/ipv6.c		 2004-11-10 16:45:07 +09:00<br>
+++ b/net/sctp/ipv6.c		 2004-11-10 16:45:07 +09:00<br>
@@ -461,7 +461,7 @@<br>
 		 		 }<br>
 		 		 return 0;<br>
 		 }<br>
-		 if (ipv6_addr_cmp(&amp;addr1-&gt;v6.sin6_addr, &amp;addr2-&gt;v6.si=
n6_addr))<br>
+		 if (!ipv6_addr_equal(&amp;addr1-&gt;v6.sin6_addr, &amp;addr2-&gt;v6=
.sin6_addr))<br>
 		 		 return 0;<br>
 		 /* If this is a linklocal address, compare the scope_id. */<br>
 		 if (ipv6_addr_type(&amp;addr1-&gt;v6.sin6_addr) &amp; IPV6_ADDR_LIN=
KLOCAL) {<br>
<br>
-- <br>
Hideaki YOSHIFUJI @ USAGI Project &lt;yoshfuji@linux-ipv6.org&gt;<br>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF &nbsp;80D8 4807 F894 E062 0EEA<br>
<br>
</tt><br>
</body></html>=


--1__=07BBE5DBDFF056768f9e8a93df938690918c07BBE5DBDFF05676--


--0__=07BBE5DBDFF056768f9e8a93df938690918c07BBE5DBDFF05676
Content-type: image/gif;
	name="graycol.gif"
Content-Disposition: inline; filename="graycol.gif"
Content-ID: <20__=07BBE5DBDFF056768f9e8a93df938@us.ibm.com>
Content-transfer-encoding: base64

R0lGODlhEAAQAKECAMzMzAAAAP///wAAACH5BAEAAAIALAAAAAAQABAAAAIXlI+py+0PopwxUbpu
ZRfKZ2zgSJbmSRYAIf4fT3B0aW1pemVkIGJ5IFVsZWFkIFNtYXJ0U2F2ZXIhAAA7

--0__=07BBE5DBDFF056768f9e8a93df938690918c07BBE5DBDFF05676
Content-type: image/gif;
	name="pic31705.gif"
Content-Disposition: inline; filename="pic31705.gif"
Content-ID: <30__=07BBE5DBDFF056768f9e8a93df938@us.ibm.com>
Content-transfer-encoding: base64

R0lGODlhWABDALP/AAAAAK04Qf79/o+Gm7WuwlNObwoJFCsoSMDAwGFsmIuezf///wAAAAAAAAAA
AAAAACH5BAEAAAgALAAAAABYAEMAQAT/EMlJq704682770RiFMRinqggEUNSHIchG0BCfHhOjAuh
EDeUqTASLCbBhQrhG7xis2j0lssNDopE4jfIJhDaggI8YB1sZeZgLVA9YVCpnGagVjV171aRVrYR
RghXcAGFhoUETwYxcXNyADJ3GlcSKGAwLwllVC1vjIUHBWsFilKQdI8GA5IcpApeJQt8L09lmgkH
LZikoU5wjqcyAMMFrJIDPAKvCFletKSev1HBw8KrxtjZ2tvc3d5VyKtCKW3jfz4uMKmq3xu4N0nK
BVoJQmx2LGVOmrqNjjJf2hHAQo/eDwJGTKhQMcgQEEAnEjFS98+RnW3smGkZU6ncCWav/4wYOnAI
TihRL/4FEwbp28BXMMcoscQCVxlepL4IGDSCyJyVQOu0o7CjmLN50OZlqWmyFy5/6yBBuji0AxFR
M00oQAqNIstqI6qKHUsWRAEAvagsmfUEAImyxgbmUpJk3IklNUtJOUAVLoUr1+wqDGTE4zk+T6FG
uQb3SizBCwatiiUgCBN8vrz+zFjVyQ8FWkOlg4NQiZMB5QS8QO3mpOaKnL0Z2EKvNMSILEThKhCg
zMKPVxYJh23qm9KNW7pArPynMqZDiErsTMqI+LRi3QAgkFUbXpuFKhSYZALd0O5RKa2z9EYKBbpb
qxIKsjUPRgD7I2XYV6wyrOw92ykExP8NW4URhknC5dKGE4v4NENQj2jXjmfNgOZDaXb5glRmXQ33
YEWQYNcZFnrYcIQLNzyTFDQNkXIff0ExVlY4srziQk43inZgL4rwxxINMvpFFAz1KOODHiu+4aEw
NEjFl5B3JIKWKF3k6I9bfUGp5ZZcdunll5IA4cuHvQQJ5gcsoCWOOUwgltIwAKRxJgbIkJAQZEq0
2YliZnpZZ4BH3CnYOXldOUOfQoYDqF1LFHbXCrO8xmRsfoXDXJ6ChjCAH3QlhJcT6VWE6FCkfCco
CgrMFsROrIEX3o2whVjWDjoJccN3LdggSGXLCdLEgHr1lyU3O3QxhgohNKXJCWv8JQr/PDdaqd6w
2rj1inLiGeiCJoDspAoQlYE6QWLSECehcWIYxIQES6zhbn1iImTHEQyqJ4eIxJJoUBc+3CbBuwZE
V5cJPPkIjFDdeEabQbd6WgICTxiiz0f5dBKquXF6k4senwEhYGnKEFJeGrxUZy8dB8gmAXI/sPvH
ESfCwVt5hTgYiqQqtdRNHQIU1PJ33ZqmzgE90OwLaoJcnMop1WiMmgkPHQRIrwgFuNV90A3doNKT
mrKIN07AnGcI9BQjhCBN4RfA1qIZnMqorJCogKfGQnxSCDilTVIA0yl5ciTovgLuBDKFUDE9aQcw
9SA+rjSNf9/M1gxrj6VwDTS0IUSElMzBfsj0NFXR2kwsV1A5IF1grLgLL/r1R40BZEnuBWgmQEyb
jqRwSAt6bqMCOFkvKFN2GPPkUzIm/SCF8z8pVzpbjVnMsy0vOr1hw3SaSRUhpY09v0z0J1FnwzPl
fmh+xl4WtR0zGu24I4KbMQm3lnVu2oNWxI9W/lcyzA+mCKF4DBikxb/+UWtOGRiFP8qEwAayIgIA
Ow==

--0__=07BBE5DBDFF056768f9e8a93df938690918c07BBE5DBDFF05676
Content-type: image/gif;
	name="ecblank.gif"
Content-Disposition: inline; filename="ecblank.gif"
Content-ID: <40__=07BBE5DBDFF056768f9e8a93df938@us.ibm.com>
Content-transfer-encoding: base64

R0lGODlhEAABAIAAAAAAAP///yH5BAEAAAEALAAAAAAQAAEAAAIEjI8ZBQA7

--0__=07BBE5DBDFF056768f9e8a93df938690918c07BBE5DBDFF05676--
