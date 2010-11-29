From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: [PATCH 1/3] net: kill unused macros in head file
Date: Mon, 29 Nov 2010 14:53:32 +0800
Message-ID: <4CF34DEC.6090907@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Network-Maillist <netdev@vger.kernel.org>, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, jmorris@namei.org,
	"yoshfuji@linux-ipv6.org >> YOSHIFUJI Hideaki"
	<yoshfuji@linux-ipv6.org>, Patrick McHardy <kaber@trash.net>,
	Shan Wei <shanwei@cn.fujitsu.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:62664 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751275Ab0K2GzP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Nov 2010 01:55:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These macros have been defined for several years since v2.6.12-rc2=EF=BC=
=88tracing by git=EF=BC=89,
but never be used. So remove them.


Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
---
 include/net/addrconf.h  |    2 --
 include/net/ip6_route.h |    1 -
 include/net/ndisc.h     |    6 ------
 include/net/snmp.h      |    1 -
 include/net/sock.h      |    3 ---
 include/net/tcp.h       |    6 ------
 6 files changed, 0 insertions(+), 19 deletions(-)

diff --git a/include/net/addrconf.h b/include/net/addrconf.h
index a944124..23710aa 100644
--- a/include/net/addrconf.h
+++ b/include/net/addrconf.h
@@ -1,8 +1,6 @@
 #ifndef _ADDRCONF_H
 #define _ADDRCONF_H
=20
-#define RETRANS_TIMER	HZ
-
 #define MAX_RTR_SOLICITATIONS		3
 #define RTR_SOLICITATION_INTERVAL	(4*HZ)
=20
diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
index 278312c..52c0550 100644
--- a/include/net/ip6_route.h
+++ b/include/net/ip6_route.h
@@ -3,7 +3,6 @@
=20
 #define IP6_RT_PRIO_USER	1024
 #define IP6_RT_PRIO_ADDRCONF	256
-#define IP6_RT_PRIO_KERN	512
=20
 struct route_info {
 	__u8			type;
diff --git a/include/net/ndisc.h b/include/net/ndisc.h
index 895997b..f134987 100644
--- a/include/net/ndisc.h
+++ b/include/net/ndisc.h
@@ -39,12 +39,6 @@ enum {
=20
 #define MAX_RTR_SOLICITATION_DELAY	HZ
=20
-#define ND_REACHABLE_TIME		(30*HZ)
-#define ND_RETRANS_TIMER		HZ
-
-#define ND_MIN_RANDOM_FACTOR		(1/2)
-#define ND_MAX_RANDOM_FACTOR		(3/2)
-
 #ifdef __KERNEL__
=20
 #include <linux/compiler.h>
diff --git a/include/net/snmp.h b/include/net/snmp.h
index a0e6180..835c587 100644
--- a/include/net/snmp.h
+++ b/include/net/snmp.h
@@ -60,7 +60,6 @@ struct ipstats_mib {
 };
=20
 /* ICMP */
-#define ICMP_MIB_DUMMY	__ICMP_MIB_MAX
 #define ICMP_MIB_MAX	(__ICMP_MIB_MAX + 1)
=20
 struct icmp_mib {
diff --git a/include/net/sock.h b/include/net/sock.h
index 5557dfb..717cfbf 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -516,9 +516,6 @@ static __inline__ void sk_add_bind_node(struct sock=
 *sk,
 #define sk_nulls_for_each_from(__sk, node) \
 	if (__sk && ({ node =3D &(__sk)->sk_nulls_node; 1; })) \
 		hlist_nulls_for_each_entry_from(__sk, node, sk_nulls_node)
-#define sk_for_each_continue(__sk, node) \
-	if (__sk && ({ node =3D &(__sk)->sk_node; 1; })) \
-		hlist_for_each_entry_continue(__sk, node, sk_node)
 #define sk_for_each_safe(__sk, node, tmp, list) \
 	hlist_for_each_entry_safe(__sk, node, tmp, list, sk_node)
 #define sk_for_each_bound(__sk, node, list) \
diff --git a/include/net/tcp.h b/include/net/tcp.h
index e36c874..ea819cc 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -100,12 +100,6 @@ extern void tcp_time_wait(struct sock *sk, int sta=
te, int timeo);
 #define TCP_SYNACK_RETRIES 5	/* number of times to retry passive openi=
ng a
 				 * connection: ~180sec is RFC minimum	*/
=20
-
-#define TCP_ORPHAN_RETRIES 7	/* number of times to retry on an orphane=
d
-				 * socket. 7 is ~50sec-16min.
-				 */
-
-
 #define TCP_TIMEWAIT_LEN (60*HZ) /* how long to wait to destroy TIME-W=
AIT
 				  * state, about 60 seconds	*/
 #define TCP_FIN_TIMEOUT	TCP_TIMEWAIT_LEN
--=20
1.6.3.3
