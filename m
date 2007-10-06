From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH net-2.6.24] net: sparse warning fixes
Date: Fri, 5 Oct 2007 17:14:07 -0700
Message-ID: <20071005171407.19c65258@freepuppy.rosehill>
References: <20071004201036.2665f6cc@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:33473 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756574AbXJFAOV convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Oct 2007 20:14:21 -0400
In-Reply-To: <20071004201036.2665f6cc@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46ix a bunch of sparse warnings. Mostly about 0 used as
NULL pointer, and shadowed variable declarations.

The two noteable changes are:
 * hash size should have been unsigned
 * cls_u32 had a case where error code wasn't been
   propogated properly, so it could return 0 but still
   have an error.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>


---
 include/net/inet_hashtables.h |    2 +-
 include/net/sock.h            |   22 +++++++++++-----------
 net/appletalk/aarp.c          |    2 --
 net/atm/signaling.c           |    2 +-
 net/core/dev.c                |    4 ++--
 net/core/pktgen.c             |   32 +++++++++++++++-----------------
 net/core/scm.c                |    9 ++++++---
 net/ipv4/igmp.c               |    5 ++---
 net/ipv4/inet_lro.c           |    2 +-
 net/ipv4/ip_sockglue.c        |    6 +++---
 net/ipv4/proc.c               |    2 +-
 net/ipv4/route.c              |    4 ++--
 net/ipv4/tcp_input.c          |    2 +-
 net/ipv6/anycast.c            |    2 +-
 net/ipv6/ipv6_sockglue.c      |    2 +-
 net/ipv6/mcast.c              |    4 ++--
 net/ipv6/ndisc.c              |    2 +-
 net/sched/cls_u32.c           |    4 ++--
 net/socket.c                  |    2 +-
 19 files changed, 54 insertions(+), 56 deletions(-)

Some of the warnings:
net/socket.c:1856:32: warning: cast adds address space to expression (<=
asn:1>)
net/socket.c:1932:11: warning: cast adds address space to expression (<=
asn:1>)
net/socket.c:2273:47: warning: incorrect type in argument 4 (different =
address spaces)
net/socket.c:2273:47:    expected char [noderef] <asn:1>*optval
net/socket.c:2273:47:    got char *optval
net/socket.c:2273:55: warning: incorrect type in argument 5 (different =
address spaces)
net/socket.c:2273:55:    expected int [noderef] <asn:1>*optlen
net/socket.c:2273:55:    got int *optlen
net/socket.c:2275:53: warning: incorrect type in argument 4 (different =
address spaces)
net/socket.c:2275:53:    expected char [noderef] <asn:1>*optval
net/socket.c:2275:53:    got char *optval
net/socket.c:2276:10: warning: incorrect type in argument 5 (different =
address spaces)
net/socket.c:2276:10:    expected int [noderef] <asn:1>*optlen
net/socket.c:2276:10:    got int *optlen
net/socket.c:2289:47: warning: incorrect type in argument 4 (different =
address spaces)
net/socket.c:2289:47:    expected char [noderef] <asn:1>*optval
net/socket.c:2289:47:    got char *optval
net/socket.c:2291:53: warning: incorrect type in argument 4 (different =
address spaces)
net/socket.c:2291:53:    expected char [noderef] <asn:1>*optval
net/socket.c:2291:53:    got char *optval
net/appletalk/aarp.c:825:23: warning: symbol 'a' shadows an earlier one
net/appletalk/aarp.c:715:20: originally declared here
include/linux/mm.h:587:9: warning: potentially expensive pointer subtra=
ction
net/atm/signaling.c:233:19: warning: symbol 'vcc' shadows an earlier on=
e
net/atm/signaling.c:216:39: originally declared here
net/atm/mpc.c:101:20: warning: symbol 'mpcs' was not declared. Should i=
t be static?
net/core/sock.c:1349:7: warning: symbol 'rc' shadows an earlier one
net/core/sock.c:1344:6: originally declared here
net/core/sock.c:819:61: warning: incorrect type in argument 3 (differen=
t signedness)
net/core/sock.c:819:61:    expected int *sockaddr_len
net/core/sock.c:819:61:    got unsigned int *<noident>
net/core/iovec.c:45:31: warning: incorrect type in argument 1 (differen=
t address spaces)
net/core/iovec.c:45:31:    expected void [noderef] <asn:1>*uaddr
net/core/iovec.c:45:31:    got void *msg_name
net/core/iovec.c:56:27: warning: incorrect type in argument 2 (differen=
t address spaces)
net/core/iovec.c:56:27:    expected void const [noderef] <asn:1>*from
net/core/iovec.c:56:27:    got struct iovec *msg_iov
net/core/scm.c:170:31: warning: cast adds address space to expression (=
<asn:1>)
net/core/scm.c:193:19: warning: cast removes address space of expressio=
n
net/core/scm.c:193:19: warning: incorrect type in argument 1 (different=
 address spaces)
net/core/scm.c:193:19:    expected void [noderef] <asn:1>*to
net/core/scm.c:193:19:    got void *<noident>
net/core/scm.c:205:31: warning: cast adds address space to expression (=
<asn:1>)
net/core/scm.c:225:33: warning: cast removes address space of expressio=
n
net/core/scm.c:225:20: warning: cast adds address space to expression (=
<asn:1>)
net/core/dev.c:813:7: warning: incorrect type in argument 1 (different =
signedness)
net/core/dev.c:813:7:    expected unsigned long const *addr
net/core/dev.c:813:7:    got long *[assigned] inuse
net/core/dev.c:1878:29: warning: symbol 'br_fdb_get_hook' was not decla=
red. Should it be static?
net/core/dev.c:1880:6: warning: symbol 'br_fdb_put_hook' was not declar=
ed. Should it be static?
net/core/rtnetlink.c:1073:27: error: bad constant expression
net/core/net-sysfs.c:452:6: warning: symbol 'netdev_unregister_kobject'=
 was not declared. Should it be static?
net/core/net-sysfs.c:461:5: warning: symbol 'netdev_register_kobject' w=
as not declared. Should it be static?
net/core/net-sysfs.c:487:5: warning: symbol 'netdev_kobject_init' was n=
ot declared. Should it be static?
net/core/pktgen.c:1566:15: warning: symbol 'offset' shadows an earlier =
one
net/core/pktgen.c:908:18: originally declared here
net/core/pktgen.c:2749:9: warning: symbol 'tmp' shadows an earlier one
net/core/pktgen.c:2733:9: originally declared here
net/core/pktgen.c:2782:9: warning: symbol 'tmp' shadows an earlier one
net/core/pktgen.c:2733:9: originally declared here
net/core/pktgen.c:953:17: error: bad constant expression
net/ipv4/route.c:596:16: warning: Using plain integer as NULL pointer
net/ipv4/route.c:2980:7: warning: incorrect type in argument 6 (differe=
nt signedness)
net/ipv4/route.c:2980:7:    expected unsigned int *_hash_shift
net/ipv4/route.c:2980:7:    got int static [toplevel] *<noident>
net/ipv4/ip_sockglue.c:662:14: warning: Using plain integer as NULL poi=
nter
net/ipv4/ip_sockglue.c:819:14: warning: Using plain integer as NULL poi=
nter
net/ipv4/ip_sockglue.c:839:14: warning: Using plain integer as NULL poi=
nter
net/ipv4/ip_sockglue.c:1121:19: warning: incorrect type in assignment (=
different address spaces)
net/ipv4/ip_sockglue.c:1121:19:    expected void *msg_control
net/ipv4/ip_sockglue.c:1121:19:    got char [noderef] <asn:1>*optval
net/ipv4/tcp.c:2471:7: warning: incorrect type in argument 6 (different=
 signedness)
net/ipv4/tcp.c:2471:7:    expected unsigned int *_hash_shift
net/ipv4/tcp.c:2471:7:    got int extern [toplevel] *<noident>
net/ipv4/tcp_input.c:2703:37: warning: symbol 'icsk' shadows an earlier=
 one
net/ipv4/tcp_input.c:2578:36: originally declared here
net/ipv4/igmp.c:1698:20: warning: symbol 'in_dev' shadows an earlier on=
e
net/ipv4/igmp.c:1656:43: originally declared here
net/ipv4/igmp.c:2170:22: warning: symbol 'psin' shadows an earlier one
net/ipv4/igmp.c:2135:21: originally declared here
net/ipv4/igmp.c:1802:21: warning: Using plain integer as NULL pointer
net/ipv4/fib_semantics.c:1071:4: warning: symbol 'nh' shadows an earlie=
r one
net/ipv4/fib_semantics.c:1060:17: originally declared here
net/ipv4/fib_semantics.c:1136:3: warning: symbol 'nh' shadows an earlie=
r one
net/ipv4/fib_semantics.c:1115:16: originally declared here
net/ipv4/proc.c:147:4: warning: Using plain integer as NULL pointer
net/ipv4/ipmr.c:957:10: warning: symbol 'ret' shadows an earlier one
net/ipv4/ipmr.c:872:6: originally declared here
net/ipv4/ipmr.c:144:26: warning: incorrect type in assignment (differen=
t address spaces)
net/ipv4/ipmr.c:144:26:    expected void [noderef] <asn:1>*ifru_data
net/ipv4/ipmr.c:144:26:    got void *<noident>
net/ipv4/tcp_htcp.c:185:11: warning: symbol '_x' shadows an earlier one
net/ipv4/tcp_htcp.c:185:11: originally declared here
net/ipv4/esp4.c:174:10: error: bad constant expression
net/ipv4/ipcomp.c:53:63: warning: incorrect type in argument 5 (differe=
nt signedness)
net/ipv4/ipcomp.c:53:63:    expected unsigned int *dlen
net/ipv4/ipcomp.c:53:63:    got int *<noident>
net/ipv4/ipcomp.c:108:61: warning: incorrect type in argument 5 (differ=
ent signedness)
net/ipv4/ipcomp.c:108:61:    expected unsigned int *dlen
net/ipv4/ipcomp.c:108:61:    got int *<noident>
net/ipv4/inet_lro.c:485:10: warning: Using plain integer as NULL pointe=
r
net/ipv4/tcp_yeah.c:224:15: warning: symbol '_x' shadows an earlier one
net/ipv4/tcp_yeah.c:224:15: originally declared here
net/ipv4/tcp_yeah.c:224:15: warning: symbol '_x' shadows an earlier one
net/ipv4/tcp_yeah.c:224:15: originally declared here
net/ipv4/tcp_yeah.c:224:15: warning: symbol '_y' shadows an earlier one
net/ipv4/tcp_yeah.c:224:15: originally declared here
net/ipv6/anycast.c:417:17: warning: Using plain integer as NULL pointer
net/ipv6/addrconf.c:1891:29: warning: cast adds address space to expres=
sion (<asn:1>)
net/ipv6/ipv6_sockglue.c:666:14: warning: Using plain integer as NULL p=
ointer
net/ipv6/ipv6_sockglue.c:875:19: warning: incorrect type in assignment =
(different address spaces)
net/ipv6/ipv6_sockglue.c:875:19:    expected void *msg_control
net/ipv6/ipv6_sockglue.c:875:19:    got char [noderef] <asn:1>*optval
net/ipv6/ndisc.c:259:53: warning: Using plain integer as NULL pointer
net/ipv6/udplite.c:43:14: warning: symbol 'udplitev6_prot' was not decl=
ared. Should it be static?
net/ipv6/udplite.c:77:13: warning: symbol 'udplitev6_init' was not decl=
ared. Should it be static?
net/ipv6/mcast.c:2074:20: warning: symbol 'idev' shadows an earlier one
net/ipv6/mcast.c:2034:44: originally declared here
net/ipv6/mcast.c:1410:13: warning: Using plain integer as NULL pointer
net/ipv6/mcast.c:2147:21: warning: Using plain integer as NULL pointer
net/ipv6/esp6.c:168:10: error: bad constant expression
net/ipv6/ipcomp6.c:94:59: warning: incorrect type in argument 5 (differ=
ent signedness)
net/ipv6/ipcomp6.c:94:59:    expected unsigned int *dlen
net/ipv6/ipcomp6.c:94:59:    got int *<noident>
net/ipv6/ipcomp6.c:150:57: warning: incorrect type in argument 5 (diffe=
rent signedness)
net/ipv6/ipcomp6.c:150:57:    expected unsigned int *dlen
net/ipv6/ipcomp6.c:150:57:    got int *<noident>
net/ipx/af_ipx.c:1553:23: warning: symbol 'uaddr' shadows an earlier on=
e
net/ipx/af_ipx.c:1535:61: originally declared here
net/ipx/af_ipx.c:70:5: warning: symbol 'sysctl_ipx_pprop_broadcasting' =
was not declared. Should it be static?
net/netlabel/netlabel_cipso_v4.c:668:21: warning: incorrect type in arg=
ument 1 (different signedness)
net/netlabel/netlabel_cipso_v4.c:668:21:    expected unsigned int [user=
type] *skip_cnt
net/netlabel/netlabel_cipso_v4.c:668:21:    got int *<noident>
net/sched/cls_u32.c:505:7: warning: symbol 'err' shadows an earlier one
net/sched/cls_u32.c:468:6: originally declared here
net/sched/cls_u32.c:595:27: warning: Using plain integer as NULL pointe=
r


--- a/include/net/inet_hashtables.h	2007-10-05 17:01:25.000000000 -0700
+++ b/include/net/inet_hashtables.h	2007-10-05 17:05:20.000000000 -0700
@@ -107,7 +107,7 @@ struct inet_hashinfo {
 	 */
 	struct inet_bind_hashbucket	*bhash;
=20
-	int				bhash_size;
+	unsigned int			bhash_size;
 	unsigned int			ehash_size;
=20
 	/* All sockets in TCP_LISTEN state will be in here.  This is the only
--- a/include/net/sock.h	2007-10-05 17:01:25.000000000 -0700
+++ b/include/net/sock.h	2007-10-05 17:05:20.000000000 -0700
@@ -485,17 +485,17 @@ static inline void sk_add_backlog(struct
 	skb->next =3D NULL;
 }
=20
-#define sk_wait_event(__sk, __timeo, __condition)		\
-({	int rc;							\
-	release_sock(__sk);					\
-	rc =3D __condition;					\
-	if (!rc) {						\
-		*(__timeo) =3D schedule_timeout(*(__timeo));	\
-	}							\
-	lock_sock(__sk);					\
-	rc =3D __condition;					\
-	rc;							\
-})
+#define sk_wait_event(__sk, __timeo, __condition)			\
+	({	int __rc;						\
+		release_sock(__sk);					\
+		__rc =3D __condition;					\
+		if (!__rc) {						\
+			*(__timeo) =3D schedule_timeout(*(__timeo));	\
+		}							\
+		lock_sock(__sk);					\
+		__rc =3D __condition;					\
+		__rc;							\
+	})
=20
 extern int sk_stream_wait_connect(struct sock *sk, long *timeo_p);
 extern int sk_stream_wait_memory(struct sock *sk, long *timeo_p);
--- a/net/appletalk/aarp.c	2007-10-05 17:01:25.000000000 -0700
+++ b/net/appletalk/aarp.c	2007-10-05 17:05:20.000000000 -0700
@@ -822,8 +822,6 @@ static int aarp_rcv(struct sk_buff *skb,
 				 * address. So as a precaution flush any
 				 * entries we have for this address.
 				 */
-				struct aarp_entry *a;
-
 				a =3D __aarp_find_entry(resolved[sa.s_node %
 							  (AARP_HASH_SIZE - 1)],
 						      skb->dev, &sa);
--- a/net/atm/signaling.c	2007-10-05 17:01:25.000000000 -0700
+++ b/net/atm/signaling.c	2007-10-05 17:05:20.000000000 -0700
@@ -230,7 +230,7 @@ static void sigd_close(struct atm_vcc *v
 		struct hlist_head *head =3D &vcc_hash[i];
=20
 		sk_for_each(s, node, head) {
-			struct atm_vcc *vcc =3D atm_sk(s);
+			vcc =3D atm_sk(s);
=20
 			purge_vcc(vcc);
 		}
--- a/net/core/dev.c	2007-10-05 17:01:25.000000000 -0700
+++ b/net/core/dev.c	2007-10-05 17:05:20.000000000 -0700
@@ -780,7 +780,7 @@ static int __dev_alloc_name(struct net *
 	int i =3D 0;
 	const char *p;
 	const int max_netdevices =3D 8*PAGE_SIZE;
-	long *inuse;
+	unsigned long *inuse;
 	struct net_device *d;
=20
 	p =3D strnchr(name, IFNAMSIZ-1, '%');
@@ -794,7 +794,7 @@ static int __dev_alloc_name(struct net *
 			return -EINVAL;
=20
 		/* Use one page as a bit array of possible slots */
-		inuse =3D (long *) get_zeroed_page(GFP_ATOMIC);
+		inuse =3D (unsigned long *) get_zeroed_page(GFP_ATOMIC);
 		if (!inuse)
 			return -ENOMEM;
=20
--- a/net/core/pktgen.c	2007-10-05 17:01:25.000000000 -0700
+++ b/net/core/pktgen.c	2007-10-05 17:05:20.000000000 -0700
@@ -6,7 +6,7 @@
  *
  * Alexey Kuznetsov  <kuznet@ms2.inr.ac.ru>
  * Ben Greear <greearb@candelatech.com>
- * Jens L=C3=A5=C3=A5s <jens.laas@data.slu.se>
+ * Jens L=C3=A5=C3=A5s <jens.laas@data.slu.se>
  *
  * This program is free software; you can redistribute it and/or
  * modify it under the terms of the GNU General Public License
@@ -1563,15 +1563,17 @@ static ssize_t pktgen_if_write(struct fi
 	}
=20
 	if (!strcmp(name, "mpls")) {
-		unsigned n, offset;
+		unsigned n, cnt;
+
 		len =3D get_labels(&user_buffer[i], pkt_dev);
-		if (len < 0) { return len; }
+		if (len < 0)
+			return len;
 		i +=3D len;
-		offset =3D sprintf(pg_result, "OK: mpls=3D");
+		cnt =3D sprintf(pg_result, "OK: mpls=3D");
 		for (n =3D 0; n < pkt_dev->nr_labels; n++)
-			offset +=3D sprintf(pg_result + offset,
-					  "%08x%s", ntohl(pkt_dev->labels[n]),
-					  n =3D=3D pkt_dev->nr_labels-1 ? "" : ",");
+			cnt +=3D sprintf(pg_result + cnt,
+				       "%08x%s", ntohl(pkt_dev->labels[n]),
+				       n =3D=3D pkt_dev->nr_labels-1 ? "" : ",");
=20
 		if (pkt_dev->nr_labels && pkt_dev->vlan_id !=3D 0xffff) {
 			pkt_dev->vlan_id =3D 0xffff; /* turn off VLAN/SVLAN */
@@ -2731,6 +2733,7 @@ static unsigned int scan_ip6(const char=20
 	unsigned int prefixlen =3D 0;
 	unsigned int suffixlen =3D 0;
 	__be32 tmp;
+	char *pos;
=20
 	for (i =3D 0; i < 16; i++)
 		ip[i] =3D 0;
@@ -2745,12 +2748,9 @@ static unsigned int scan_ip6(const char=20
 			}
 			s++;
 		}
-		{
-			char *tmp;
-			u =3D simple_strtoul(s, &tmp, 16);
-			i =3D tmp - s;
-		}
=20
+		u =3D simple_strtoul(s, &pos, 16);
+		i =3D pos - s;
 		if (!i)
 			return 0;
 		if (prefixlen =3D=3D 12 && s[i] =3D=3D '.') {
@@ -2778,11 +2778,9 @@ static unsigned int scan_ip6(const char=20
 			len++;
 		} else if (suffixlen !=3D 0)
 			break;
-		{
-			char *tmp;
-			u =3D simple_strtol(s, &tmp, 16);
-			i =3D tmp - s;
-		}
+
+		u =3D simple_strtol(s, &pos, 16);
+		i =3D pos - s;
 		if (!i) {
 			if (*s)
 				len--;
--- a/net/core/scm.c	2007-10-05 17:01:25.000000000 -0700
+++ b/net/core/scm.c	2007-10-05 17:05:20.000000000 -0700
@@ -167,7 +167,8 @@ error:
=20
 int put_cmsg(struct msghdr * msg, int level, int type, int len, void *=
data)
 {
-	struct cmsghdr __user *cm =3D (struct cmsghdr __user *)msg->msg_contr=
ol;
+	struct cmsghdr __user *cm
+		=3D (__force struct cmsghdr __user *)msg->msg_control;
 	struct cmsghdr cmhdr;
 	int cmlen =3D CMSG_LEN(len);
 	int err;
@@ -202,7 +203,8 @@ out:
=20
 void scm_detach_fds(struct msghdr *msg, struct scm_cookie *scm)
 {
-	struct cmsghdr __user *cm =3D (struct cmsghdr __user*)msg->msg_contro=
l;
+	struct cmsghdr __user *cm
+		=3D (__force struct cmsghdr __user*)msg->msg_control;
=20
 	int fdmax =3D 0;
 	int fdnum =3D scm->fp->count;
@@ -222,7 +224,8 @@ void scm_detach_fds(struct msghdr *msg,=20
 	if (fdnum < fdmax)
 		fdmax =3D fdnum;
=20
-	for (i=3D0, cmfptr=3D(int __user *)CMSG_DATA(cm); i<fdmax; i++, cmfpt=
r++)
+	for (i=3D0, cmfptr=3D(__force int __user *)CMSG_DATA(cm); i<fdmax;
+	     i++, cmfptr++)
 	{
 		int new_fd;
 		err =3D security_file_receive(fp[i]);
--- a/net/ipv4/igmp.c	2007-10-05 17:01:25.000000000 -0700
+++ b/net/ipv4/igmp.c	2007-10-05 17:05:20.000000000 -0700
@@ -1695,8 +1695,8 @@ static int ip_mc_add_src(struct in_devic
 			(void) ip_mc_del1_src(pmc, sfmode, &psfsrc[i]);
 	} else if (isexclude !=3D (pmc->sfcount[MCAST_EXCLUDE] !=3D 0)) {
 #ifdef CONFIG_IP_MULTICAST
-		struct in_device *in_dev =3D pmc->interface;
 		struct ip_sf_list *psf;
+		in_dev =3D pmc->interface;
 #endif
=20
 		/* filter mode change */
@@ -1799,7 +1799,7 @@ static int ip_mc_leave_src(struct sock *
 {
 	int err;
=20
-	if (iml->sflist =3D=3D 0) {
+	if (iml->sflist =3D=3D NULL) {
 		/* any-source empty exclude case */
 		return ip_mc_del_src(in_dev, &iml->multi.imr_multiaddr.s_addr,
 			iml->sfmode, 0, NULL, 0);
@@ -2167,7 +2167,6 @@ int ip_mc_gsfget(struct sock *sk, struct
 		return -EFAULT;
 	}
 	for (i=3D0; i<copycount; i++) {
-		struct sockaddr_in *psin;
 		struct sockaddr_storage ss;
=20
 		psin =3D (struct sockaddr_in *)&ss;
--- a/net/ipv4/inet_lro.c	2007-10-05 17:01:25.000000000 -0700
+++ b/net/ipv4/inet_lro.c	2007-10-05 17:05:20.000000000 -0700
@@ -482,7 +482,7 @@ static struct sk_buff *__lro_proc_segmen
=20
 		lro_init_desc(lro_desc, skb, iph, tcph, 0, NULL);
 		LRO_INC_STATS(lro_mgr, aggregated);
-		return 0;
+		return NULL;
 	}
=20
 	if (lro_desc->tcp_next_seq !=3D ntohl(tcph->seq))
--- a/net/ipv4/ip_sockglue.c	2007-10-05 17:01:25.000000000 -0700
+++ b/net/ipv4/ip_sockglue.c	2007-10-05 17:05:20.000000000 -0700
@@ -659,7 +659,7 @@ static int do_ip_setsockopt(struct sock=20
 			break;
 		}
 		msf =3D kmalloc(optlen, GFP_KERNEL);
-		if (msf =3D=3D 0) {
+		if (!msf) {
 			err =3D -ENOBUFS;
 			break;
 		}
@@ -816,7 +816,7 @@ static int do_ip_setsockopt(struct sock=20
 			break;
 		}
 		gsf =3D kmalloc(optlen,GFP_KERNEL);
-		if (gsf =3D=3D 0) {
+		if (!gsf) {
 			err =3D -ENOBUFS;
 			break;
 		}
@@ -836,7 +836,7 @@ static int do_ip_setsockopt(struct sock=20
 		}
 		msize =3D IP_MSFILTER_SIZE(gsf->gf_numsrc);
 		msf =3D kmalloc(msize,GFP_KERNEL);
-		if (msf =3D=3D 0) {
+		if (!msf) {
 			err =3D -ENOBUFS;
 			goto mc_msf_out;
 		}
--- a/net/ipv4/proc.c	2007-10-05 17:01:25.000000000 -0700
+++ b/net/ipv4/proc.c	2007-10-05 17:05:20.000000000 -0700
@@ -144,7 +144,7 @@ static struct {
 	{ "TimestampReps", ICMP_TIMESTAMPREPLY },
 	{ "AddrMasks", ICMP_ADDRESS },
 	{ "AddrMaskReps", ICMP_ADDRESSREPLY },
-	{ 0, 0 }
+	{ NULL, 0 }
 };
=20
=20
--- a/net/ipv4/route.c	2007-10-05 17:01:25.000000000 -0700
+++ b/net/ipv4/route.c	2007-10-05 17:05:20.000000000 -0700
@@ -246,7 +246,7 @@ static spinlock_t	*rt_hash_locks;
=20
 static struct rt_hash_bucket 	*rt_hash_table;
 static unsigned			rt_hash_mask;
-static int			rt_hash_log;
+static unsigned int		rt_hash_log;
 static unsigned int		rt_hash_rnd;
=20
 static DEFINE_PER_CPU(struct rt_cache_stat, rt_cache_stat);
@@ -593,7 +593,7 @@ static void rt_check_expire(struct work_
 		i =3D (i + 1) & rt_hash_mask;
 		rthp =3D &rt_hash_table[i].chain;
=20
-		if (*rthp =3D=3D 0)
+		if (*rthp =3D=3D NULL)
 			continue;
 		spin_lock_bh(rt_hash_lock_addr(i));
 		while ((rth =3D *rthp) !=3D NULL) {
--- a/net/ipv4/tcp_input.c	2007-10-05 17:01:25.000000000 -0700
+++ b/net/ipv4/tcp_input.c	2007-10-05 17:05:20.000000000 -0700
@@ -2700,7 +2700,7 @@ static int tcp_clean_rtx_queue(struct so
 	BUG_TRAP((int)tp->lost_out >=3D 0);
 	BUG_TRAP((int)tp->retrans_out >=3D 0);
 	if (!tp->packets_out && tcp_is_sack(tp)) {
-		const struct inet_connection_sock *icsk =3D inet_csk(sk);
+		icsk =3D inet_csk(sk);
 		if (tp->lost_out) {
 			printk(KERN_DEBUG "Leak l=3D%u %d\n",
 			       tp->lost_out, icsk->icsk_ca_state);
--- a/net/ipv6/anycast.c	2007-10-05 17:01:25.000000000 -0700
+++ b/net/ipv6/anycast.c	2007-10-05 17:05:20.000000000 -0700
@@ -414,7 +414,7 @@ static int ipv6_chk_acast_dev(struct net
 				break;
 		read_unlock_bh(&idev->lock);
 		in6_dev_put(idev);
-		return aca !=3D 0;
+		return aca !=3D NULL;
 	}
 	return 0;
 }
--- a/net/ipv6/ipv6_sockglue.c	2007-10-05 17:01:25.000000000 -0700
+++ b/net/ipv6/ipv6_sockglue.c	2007-10-05 17:05:20.000000000 -0700
@@ -663,7 +663,7 @@ done:
 			break;
 		}
 		gsf =3D kmalloc(optlen,GFP_KERNEL);
-		if (gsf =3D=3D 0) {
+		if (!gsf) {
 			retv =3D -ENOBUFS;
 			break;
 		}
--- a/net/ipv6/mcast.c	2007-10-05 17:01:25.000000000 -0700
+++ b/net/ipv6/mcast.c	2007-10-05 17:05:20.000000000 -0700
@@ -1407,7 +1407,7 @@ static struct sk_buff *mld_newpack(struc
 	/* we assume size > sizeof(ra) here */
 	skb =3D sock_alloc_send_skb(sk, size + LL_RESERVED_SPACE(dev), 1, &er=
r);
=20
-	if (skb =3D=3D 0)
+	if (!skb)
 		return NULL;
=20
 	skb_reserve(skb, LL_RESERVED_SPACE(dev));
@@ -2144,7 +2144,7 @@ static int ip6_mc_leave_src(struct sock=20
 	/* callers have the socket lock and a write lock on ipv6_sk_mc_lock,
 	 * so no other readers or writers of iml or its sflist
 	 */
-	if (iml->sflist =3D=3D 0) {
+	if (!iml->sflist) {
 		/* any-source empty exclude case */
 		return ip6_mc_del_src(idev, &iml->addr, iml->sfmode, 0, NULL, 0);
 	}
--- a/net/ipv6/ndisc.c	2007-10-05 17:01:25.000000000 -0700
+++ b/net/ipv6/ndisc.c	2007-10-05 17:05:20.000000000 -0700
@@ -256,7 +256,7 @@ static struct ndisc_options *ndisc_parse
 			break;
 		case ND_OPT_PREFIX_INFO:
 			ndopts->nd_opts_pi_end =3D nd_opt;
-			if (ndopts->nd_opt_array[nd_opt->nd_opt_type] =3D=3D 0)
+			if (!ndopts->nd_opt_array[nd_opt->nd_opt_type])
 				ndopts->nd_opt_array[nd_opt->nd_opt_type] =3D nd_opt;
 			break;
 #ifdef CONFIG_IPV6_ROUTE_INFO
--- a/net/sched/cls_u32.c	2007-10-05 17:01:25.000000000 -0700
+++ b/net/sched/cls_u32.c	2007-10-05 17:05:20.000000000 -0700
@@ -502,7 +502,7 @@ static int u32_set_parms(struct tcf_prot
=20
 #ifdef CONFIG_NET_CLS_IND
 	if (tb[TCA_U32_INDEV-1]) {
-		int err =3D tcf_change_indev(tp, n->indev, tb[TCA_U32_INDEV-1]);
+		err =3D tcf_change_indev(tp, n->indev, tb[TCA_U32_INDEV-1]);
 		if (err < 0)
 			goto errout;
 	}
@@ -592,7 +592,7 @@ static int u32_change(struct tcf_proto *
 	} else
 		handle =3D gen_new_kid(ht, htid);
=20
-	if (tb[TCA_U32_SEL-1] =3D=3D 0 ||
+	if (tb[TCA_U32_SEL-1] =3D=3D NULL ||
 	    RTA_PAYLOAD(tb[TCA_U32_SEL-1]) < sizeof(struct tc_u32_sel))
 		return -EINVAL;
=20
--- a/net/socket.c	2007-10-05 17:01:25.000000000 -0700
+++ b/net/socket.c	2007-10-05 17:05:20.000000000 -0700
@@ -1929,7 +1929,7 @@ asmlinkage long sys_recvmsg(int fd, stru
 	 *      kernel msghdr to use the kernel address space)
 	 */
=20
-	uaddr =3D (void __user *)msg_sys.msg_name;
+	uaddr =3D (__force void __user *)msg_sys.msg_name;
 	uaddr_len =3D COMPAT_NAMELEN(msg);
 	if (MSG_CMSG_COMPAT & flags) {
 		err =3D verify_compat_iovec(&msg_sys, iov, addr, VERIFY_WRITE);
