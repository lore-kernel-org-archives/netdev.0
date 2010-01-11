From: Torsten Schmidt <torsten.schmidt@s2006.tu-chemnitz.de>
Subject: Re: Still using IPTOS_TOS() in kernel? Really???
Date: Mon, 11 Jan 2010 15:16:49 +0100
Message-ID: <201001111516.49558.schmto@hrz.tu-chemnitz.de>
References: <4B298118.2000608@redfish-solutions.com> <201001051635.59914.schmto@hrz.tu-chemnitz.de> <4B4382EE.4080706@redfish-solutions.com>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_RLzSLz1GD9+AymC"
To: "Philip A. Prindeville" <philipp_subx@redfish-solutions.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from jessica.hrz.tu-chemnitz.de ([134.109.132.47]:42308 "EHLO
	jessica.hrz.tu-chemnitz.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751247Ab0AKOQw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2010 09:16:52 -0500
In-Reply-To: <4B4382EE.4080706@redfish-solutions.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Boundary-00=_RLzSLz1GD9+AymC
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit

Hi Philip,

this patch series adds IP DiffServ OUT counters and 
renames /proc/net/ipdscp to /proc/net/ip_dscp to stay 
compatible.

See:
--- 
ipv4: prepare DSCP statistic for IN/OUT counters
ipv4: add DSCP OUT statistic   
ipv4: change DSCP proc file name
---

Torsten

--Boundary-00=_RLzSLz1GD9+AymC
Content-Type: text/x-patch;
  charset="utf-8";
  name="0001-ipv4-prepare-DSCP-statistic-for-IN-OUT-counters.patch"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
	filename="0001-ipv4-prepare-DSCP-statistic-for-IN-OUT-counters.patch"

=46rom 1e34debd128e09f22ffc00b4cb7cc5f1de52e2ff Mon Sep 17 00:00:00 2001
=46rom: Torsten Schmidt <schmto@hrz.tu-chemnitz.de>
Date: Tue, 5 Jan 2010 09:34:02 +0100
Subject: [PATCH 1/3] ipv4: prepare DSCP statistic for IN/OUT counters

some renames and cleanups.

Signed-off-by: Torsten Schmidt <schmto@hrz.tu-chemnitz.de>
=2D--
 include/net/ipdscp.h    |   52 +++++++++++++++++++++----------------------=
=2D--
 include/net/netns/mib.h |    2 +-
 net/ipv4/ip_input.c     |    2 +-
 net/ipv4/ipdscp.c       |    8 +++---
 4 files changed, 30 insertions(+), 34 deletions(-)

diff --git a/include/net/ipdscp.h b/include/net/ipdscp.h
index 14cc8a6..4236704 100644
=2D-- a/include/net/ipdscp.h
+++ b/include/net/ipdscp.h
@@ -39,13 +39,9 @@
 #define IP_DSCP_EF	(0x2E)
=20
 #ifdef CONFIG_IP_DSCP_STAT
=2D#define IP_DSCP_INC_STATS(net, field)	SNMP_INC_STATS((net)->mib.ipdscp_s=
tatistics, field)
=2D#define IP_DSCP_INC_STATS_BH(net, field)	SNMP_INC_STATS_BH((net)->mib.ip=
dscp_statistics, field)
=2D#define IP_DSCP_INC_STATS_USER(net, field)	SNMP_INC_STATS_USER((net)-mib=
=2Eipdscp_statistics, field)
+#define IP_DSCPIN_INC_STATS_BH(net, field)	SNMP_INC_STATS_BH((net)->mib.ip=
dscp_in_statistics, field)
 #else
=2D#define IP_DSCP_INC_STATS(net, field)	((void)(net))
=2D#define IP_DSCP_INC_STATS_BH(net, field)	((void)(net))
=2D#define IP_DSCP_INC_STATS_USER(net, field)	((void)(net))
+#define IP_DSCPIN_INC_STATS_BH(net, field)	((void)(net))
 #endif
=20
=20
@@ -53,30 +49,30 @@ int __net_init ipdscp_stat_init(struct net *net);
 void ipdscp_stat_fini(struct net *net);
=20
=20
=2Dstatic inline void ipv4_dscp_stat(struct net *net, __u8 dsfield)
+static inline void ipv4_dscp_stat_in(struct net *net, __u8 dsfield)
 {
 	switch (dsfield >> 2) {
=2D	case IP_DSCP_CS0:	IP_DSCP_INC_STATS_BH(net, LINUX_MIB_IPDSCP_CS0);break;
=2D	case IP_DSCP_EF:	IP_DSCP_INC_STATS_BH(net, LINUX_MIB_IPDSCP_EF);break;
=2D	case IP_DSCP_CS1:	IP_DSCP_INC_STATS_BH(net, LINUX_MIB_IPDSCP_CS1);break;
=2D	case IP_DSCP_CS2:	IP_DSCP_INC_STATS_BH(net, LINUX_MIB_IPDSCP_CS2);break;
=2D	case IP_DSCP_CS3:	IP_DSCP_INC_STATS_BH(net, LINUX_MIB_IPDSCP_CS3);break;
=2D	case IP_DSCP_CS4:	IP_DSCP_INC_STATS_BH(net, LINUX_MIB_IPDSCP_CS4);break;
=2D	case IP_DSCP_CS5:	IP_DSCP_INC_STATS_BH(net, LINUX_MIB_IPDSCP_CS5);break;
=2D	case IP_DSCP_CS6:	IP_DSCP_INC_STATS_BH(net, LINUX_MIB_IPDSCP_CS6);break;
=2D	case IP_DSCP_CS7:	IP_DSCP_INC_STATS_BH(net, LINUX_MIB_IPDSCP_CS7);break;
=2D	case IP_DSCP_AF11:	IP_DSCP_INC_STATS_BH(net, LINUX_MIB_IPDSCP_AF11);bre=
ak;
=2D	case IP_DSCP_AF12:	IP_DSCP_INC_STATS_BH(net, LINUX_MIB_IPDSCP_AF12);bre=
ak;
=2D	case IP_DSCP_AF13:	IP_DSCP_INC_STATS_BH(net, LINUX_MIB_IPDSCP_AF13);bre=
ak;
=2D	case IP_DSCP_AF21:	IP_DSCP_INC_STATS_BH(net, LINUX_MIB_IPDSCP_AF21);bre=
ak;
=2D	case IP_DSCP_AF22:	IP_DSCP_INC_STATS_BH(net, LINUX_MIB_IPDSCP_AF22);bre=
ak;
=2D	case IP_DSCP_AF23:	IP_DSCP_INC_STATS_BH(net, LINUX_MIB_IPDSCP_AF23);bre=
ak;
=2D	case IP_DSCP_AF31:	IP_DSCP_INC_STATS_BH(net, LINUX_MIB_IPDSCP_AF31);bre=
ak;
=2D	case IP_DSCP_AF32:	IP_DSCP_INC_STATS_BH(net, LINUX_MIB_IPDSCP_AF32);bre=
ak;
=2D	case IP_DSCP_AF33:	IP_DSCP_INC_STATS_BH(net, LINUX_MIB_IPDSCP_AF33);bre=
ak;
=2D	case IP_DSCP_AF41:	IP_DSCP_INC_STATS_BH(net, LINUX_MIB_IPDSCP_AF41);bre=
ak;
=2D	case IP_DSCP_AF42:	IP_DSCP_INC_STATS_BH(net, LINUX_MIB_IPDSCP_AF42);bre=
ak;
=2D	case IP_DSCP_AF43:	IP_DSCP_INC_STATS_BH(net, LINUX_MIB_IPDSCP_AF43);bre=
ak;
+	case IP_DSCP_CS0:	IP_DSCPIN_INC_STATS_BH(net, LINUX_MIB_IPDSCP_CS0);break;
+	case IP_DSCP_EF:	IP_DSCPIN_INC_STATS_BH(net, LINUX_MIB_IPDSCP_EF);break;
+	case IP_DSCP_CS1:	IP_DSCPIN_INC_STATS_BH(net, LINUX_MIB_IPDSCP_CS1);break;
+	case IP_DSCP_CS2:	IP_DSCPIN_INC_STATS_BH(net, LINUX_MIB_IPDSCP_CS2);break;
+	case IP_DSCP_CS3:	IP_DSCPIN_INC_STATS_BH(net, LINUX_MIB_IPDSCP_CS3);break;
+	case IP_DSCP_CS4:	IP_DSCPIN_INC_STATS_BH(net, LINUX_MIB_IPDSCP_CS4);break;
+	case IP_DSCP_CS5:	IP_DSCPIN_INC_STATS_BH(net, LINUX_MIB_IPDSCP_CS5);break;
+	case IP_DSCP_CS6:	IP_DSCPIN_INC_STATS_BH(net, LINUX_MIB_IPDSCP_CS6);break;
+	case IP_DSCP_CS7:	IP_DSCPIN_INC_STATS_BH(net, LINUX_MIB_IPDSCP_CS7);break;
+	case IP_DSCP_AF11:	IP_DSCPIN_INC_STATS_BH(net, LINUX_MIB_IPDSCP_AF11);bre=
ak;
+	case IP_DSCP_AF12:	IP_DSCPIN_INC_STATS_BH(net, LINUX_MIB_IPDSCP_AF12);bre=
ak;
+	case IP_DSCP_AF13:	IP_DSCPIN_INC_STATS_BH(net, LINUX_MIB_IPDSCP_AF13);bre=
ak;
+	case IP_DSCP_AF21:	IP_DSCPIN_INC_STATS_BH(net, LINUX_MIB_IPDSCP_AF21);bre=
ak;
+	case IP_DSCP_AF22:	IP_DSCPIN_INC_STATS_BH(net, LINUX_MIB_IPDSCP_AF22);bre=
ak;
+	case IP_DSCP_AF23:	IP_DSCPIN_INC_STATS_BH(net, LINUX_MIB_IPDSCP_AF23);bre=
ak;
+	case IP_DSCP_AF31:	IP_DSCPIN_INC_STATS_BH(net, LINUX_MIB_IPDSCP_AF31);bre=
ak;
+	case IP_DSCP_AF32:	IP_DSCPIN_INC_STATS_BH(net, LINUX_MIB_IPDSCP_AF32);bre=
ak;
+	case IP_DSCP_AF33:	IP_DSCPIN_INC_STATS_BH(net, LINUX_MIB_IPDSCP_AF33);bre=
ak;
+	case IP_DSCP_AF41:	IP_DSCPIN_INC_STATS_BH(net, LINUX_MIB_IPDSCP_AF41);bre=
ak;
+	case IP_DSCP_AF42:	IP_DSCPIN_INC_STATS_BH(net, LINUX_MIB_IPDSCP_AF42);bre=
ak;
+	case IP_DSCP_AF43:	IP_DSCPIN_INC_STATS_BH(net, LINUX_MIB_IPDSCP_AF43);bre=
ak;
 	}
 }
=20
diff --git a/include/net/netns/mib.h b/include/net/netns/mib.h
index eccbc36..a849e89 100644
=2D-- a/include/net/netns/mib.h
+++ b/include/net/netns/mib.h
@@ -25,7 +25,7 @@ struct netns_mib {
 #endif
 #ifdef CONFIG_IP_DSCP_STAT
 	struct proc_dir_entry *proc_net_ipdscp;
=2D	DEFINE_SNMP_STAT(struct ipdscp_mib, ipdscp_statistics);
+	DEFINE_SNMP_STAT(struct ipdscp_mib, ipdscp_in_statistics);
 #endif
 };
=20
diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index ba23624..ba8cd2c 100644
=2D-- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -367,7 +367,7 @@ static int ip_rcv_finish(struct sk_buff *skb)
 				skb->len);
=20
 #ifdef CONFIG_IP_DSCP_STAT
=2D	ipv4_dscp_stat(dev_net(rt->u.dst.dev), iph->tos);
+	ipv4_dscp_stat_in(dev_net(rt->u.dst.dev), iph->tos);
 #endif
=20
 	return dst_input(skb);
diff --git a/net/ipv4/ipdscp.c b/net/ipv4/ipdscp.c
index 90f9fd1..fdbfb7b 100644
=2D-- a/net/ipv4/ipdscp.c
+++ b/net/ipv4/ipdscp.c
@@ -47,7 +47,7 @@ static int ipdscp_statistics_seq_show(struct seq_file *se=
q, void *v)
 	int i;
 	for (i=3D0; ipdscp_mib_list[i].name; i++)
 		seq_printf(seq, "%-24s\t%lu\n", ipdscp_mib_list[i].name,
=2D			   snmp_fold_field((void **)net->mib.ipdscp_statistics,
+			   snmp_fold_field((void **)net->mib.ipdscp_in_statistics,
 					   ipdscp_mib_list[i].entry));
 	return 0;
 }
@@ -87,19 +87,19 @@ int __net_init ipdscp_stat_init(struct net *net)
 {
 	int rv;
=20
=2D	if (snmp_mib_init((void **)net->mib.ipdscp_statistics,
+	if (snmp_mib_init((void **)net->mib.ipdscp_in_statistics,
 			  sizeof(struct ipdscp_mib)) < 0)
 		return -ENOMEM;
 	rv =3D ipdscp_proc_init(net);
 	if (rv < 0)
=2D		snmp_mib_free((void **)net->mib.ipdscp_statistics);
+		snmp_mib_free((void **)net->mib.ipdscp_in_statistics);
 	return rv;
 }
=20
 void ipdscp_stat_fini(struct net *net)
 {
 	ipdscp_proc_fini(net);
=2D	snmp_mib_free((void **)net->mib.ipdscp_statistics);
+	snmp_mib_free((void **)net->mib.ipdscp_in_statistics);
 }
=20
=20
=2D-=20
1.6.3.3


--Boundary-00=_RLzSLz1GD9+AymC
Content-Type: text/x-patch;
  charset="utf-8";
  name="0002-ipv4-add-DSCP-OUT-statistic.patch"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
	filename="0002-ipv4-add-DSCP-OUT-statistic.patch"

=46rom 6ee7c2ef1260fd9b700893aa05c3d2a770d65e45 Mon Sep 17 00:00:00 2001
=46rom: Torsten Schmidt <schmto@hrz.tu-chemnitz.de>
Date: Tue, 5 Jan 2010 09:34:51 +0100
Subject: [PATCH 2/3] ipv4: add DSCP OUT statistic

Signed-off-by: Torsten Schmidt <schmto@hrz.tu-chemnitz.de>
=2D--
 include/net/ipdscp.h    |   31 +++++++++++++++++++++++++++++++
 include/net/netns/mib.h |    1 +
 net/ipv4/ip_output.c    |    5 +++++
 net/ipv4/ipdscp.c       |   21 ++++++++++++++++-----
 4 files changed, 53 insertions(+), 5 deletions(-)

diff --git a/include/net/ipdscp.h b/include/net/ipdscp.h
index 4236704..c14f523 100644
=2D-- a/include/net/ipdscp.h
+++ b/include/net/ipdscp.h
@@ -38,10 +38,13 @@
 #define IP_DSCP_AF43	(0x26)
 #define IP_DSCP_EF	(0x2E)
=20
+
 #ifdef CONFIG_IP_DSCP_STAT
 #define IP_DSCPIN_INC_STATS_BH(net, field)	SNMP_INC_STATS_BH((net)->mib.ip=
dscp_in_statistics, field)
+#define IP_DSCPOUT_INC_STATS(net, field)	SNMP_INC_STATS((net)->mib.ipdscp_=
out_statistics, field)
 #else
 #define IP_DSCPIN_INC_STATS_BH(net, field)	((void)(net))
+#define IP_DSCPOUT_INC_STATS(net, field)	((void)(net))
 #endif
=20
=20
@@ -76,4 +79,32 @@ static inline void ipv4_dscp_stat_in(struct net *net, __=
u8 dsfield)
 	}
 }
=20
+
+static inline void ipv4_dscp_stat_out(struct net *net, __u8 dsfield)
+{
+	switch (dsfield >> 2) {
+	case IP_DSCP_CS0:	IP_DSCPOUT_INC_STATS(net, LINUX_MIB_IPDSCP_CS0);break;
+	case IP_DSCP_EF:	IP_DSCPOUT_INC_STATS(net, LINUX_MIB_IPDSCP_EF);break;
+	case IP_DSCP_CS1:	IP_DSCPOUT_INC_STATS(net, LINUX_MIB_IPDSCP_CS1);break;
+	case IP_DSCP_CS2:	IP_DSCPOUT_INC_STATS(net, LINUX_MIB_IPDSCP_CS2);break;
+	case IP_DSCP_CS3:	IP_DSCPOUT_INC_STATS(net, LINUX_MIB_IPDSCP_CS3);break;
+	case IP_DSCP_CS4:	IP_DSCPOUT_INC_STATS(net, LINUX_MIB_IPDSCP_CS4);break;
+	case IP_DSCP_CS5:	IP_DSCPOUT_INC_STATS(net, LINUX_MIB_IPDSCP_CS5);break;
+	case IP_DSCP_CS6:	IP_DSCPOUT_INC_STATS(net, LINUX_MIB_IPDSCP_CS6);break;
+	case IP_DSCP_CS7:	IP_DSCPOUT_INC_STATS(net, LINUX_MIB_IPDSCP_CS7);break;
+	case IP_DSCP_AF11:	IP_DSCPOUT_INC_STATS(net, LINUX_MIB_IPDSCP_AF11);break;
+	case IP_DSCP_AF12:	IP_DSCPOUT_INC_STATS(net, LINUX_MIB_IPDSCP_AF12);break;
+	case IP_DSCP_AF13:	IP_DSCPOUT_INC_STATS(net, LINUX_MIB_IPDSCP_AF13);break;
+	case IP_DSCP_AF21:	IP_DSCPOUT_INC_STATS(net, LINUX_MIB_IPDSCP_AF21);break;
+	case IP_DSCP_AF22:	IP_DSCPOUT_INC_STATS(net, LINUX_MIB_IPDSCP_AF22);break;
+	case IP_DSCP_AF23:	IP_DSCPOUT_INC_STATS(net, LINUX_MIB_IPDSCP_AF23);break;
+	case IP_DSCP_AF31:	IP_DSCPOUT_INC_STATS(net, LINUX_MIB_IPDSCP_AF31);break;
+	case IP_DSCP_AF32:	IP_DSCPOUT_INC_STATS(net, LINUX_MIB_IPDSCP_AF32);break;
+	case IP_DSCP_AF33:	IP_DSCPOUT_INC_STATS(net, LINUX_MIB_IPDSCP_AF33);break;
+	case IP_DSCP_AF41:	IP_DSCPOUT_INC_STATS(net, LINUX_MIB_IPDSCP_AF41);break;
+	case IP_DSCP_AF42:	IP_DSCPOUT_INC_STATS(net, LINUX_MIB_IPDSCP_AF42);break;
+	case IP_DSCP_AF43:	IP_DSCPOUT_INC_STATS(net, LINUX_MIB_IPDSCP_AF43);break;
+	}
+}
+
 #endif
diff --git a/include/net/netns/mib.h b/include/net/netns/mib.h
index a849e89..183f15b 100644
=2D-- a/include/net/netns/mib.h
+++ b/include/net/netns/mib.h
@@ -26,6 +26,7 @@ struct netns_mib {
 #ifdef CONFIG_IP_DSCP_STAT
 	struct proc_dir_entry *proc_net_ipdscp;
 	DEFINE_SNMP_STAT(struct ipdscp_mib, ipdscp_in_statistics);
+	DEFINE_SNMP_STAT(struct ipdscp_mib, ipdscp_out_statistics);
 #endif
 };
=20
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index f989518..e14eca8 100644
=2D-- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -79,6 +79,7 @@
 #include <linux/mroute.h>
 #include <linux/netlink.h>
 #include <linux/tcp.h>
+#include <net/ipdscp.h>
=20
 int sysctl_ip_default_ttl __read_mostly =3D IPDEFTTL;
=20
@@ -300,6 +301,10 @@ int ip_output(struct sk_buff *skb)
=20
 	IP_UPD_PO_STATS(dev_net(dev), IPSTATS_MIB_OUT, skb->len);
=20
+#ifdef CONFIG_IP_DSCP_STAT
+	ipv4_dscp_stat_out(dev_net(dev), ip_hdr(skb)->tos);
+#endif
+
 	skb->dev =3D dev;
 	skb->protocol =3D htons(ETH_P_IP);
=20
diff --git a/net/ipv4/ipdscp.c b/net/ipv4/ipdscp.c
index fdbfb7b..8988ccb 100644
=2D-- a/net/ipv4/ipdscp.c
+++ b/net/ipv4/ipdscp.c
@@ -46,8 +46,10 @@ static int ipdscp_statistics_seq_show(struct seq_file *s=
eq, void *v)
 	struct net *net =3D seq->private;
 	int i;
 	for (i=3D0; ipdscp_mib_list[i].name; i++)
=2D		seq_printf(seq, "%-24s\t%lu\n", ipdscp_mib_list[i].name,
+		seq_printf(seq, "%-24s\t%lu\t%lu\n", ipdscp_mib_list[i].name,
 			   snmp_fold_field((void **)net->mib.ipdscp_in_statistics,
+					   ipdscp_mib_list[i].entry),
+			   snmp_fold_field((void **)net->mib.ipdscp_out_statistics,
 					   ipdscp_mib_list[i].entry));
 	return 0;
 }
@@ -89,11 +91,20 @@ int __net_init ipdscp_stat_init(struct net *net)
=20
 	if (snmp_mib_init((void **)net->mib.ipdscp_in_statistics,
 			  sizeof(struct ipdscp_mib)) < 0)
=2D		return -ENOMEM;
+		goto err_ipdscp_in;
+	if (snmp_mib_init((void **)net->mib.ipdscp_out_statistics,
+			  sizeof(struct ipdscp_mib)) < 0)
+		goto err_ipdscp_out;
+
 	rv =3D ipdscp_proc_init(net);
=2D	if (rv < 0)
=2D		snmp_mib_free((void **)net->mib.ipdscp_in_statistics);
=2D	return rv;
+	if (rv >=3D 0)=20
+		return 0;=09
+
+err_ipdscp_out:
+	snmp_mib_free((void **)net->mib.ipdscp_out_statistics);
+err_ipdscp_in:
+	snmp_mib_free((void **)net->mib.ipdscp_in_statistics);=09
+	return -ENOMEM;
 }
=20
 void ipdscp_stat_fini(struct net *net)
=2D-=20
1.6.3.3


--Boundary-00=_RLzSLz1GD9+AymC
Content-Type: text/x-patch;
  charset="utf-8";
  name="0003-ipv4-change-DSCP-proc-file-name.patch"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
	filename="0003-ipv4-change-DSCP-proc-file-name.patch"

=46rom 54f9a93d6476dc47c9ca87f3350187011039adf9 Mon Sep 17 00:00:00 2001
=46rom: Torsten Schmidt <schmto@hrz.tu-chemnitz.de>
Date: Mon, 11 Jan 2010 14:49:48 +0100
Subject: [PATCH 3/3] ipv4: change DSCP proc file name

Signed-off-by: Torsten Schmidt <schmto@hrz.tu-chemnitz.de>
=2D--
 net/ipv4/ipdscp.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/ipdscp.c b/net/ipv4/ipdscp.c
index 8988ccb..151623a 100644
=2D-- a/net/ipv4/ipdscp.c
+++ b/net/ipv4/ipdscp.c
@@ -72,7 +72,7 @@ static const struct file_operations ipdscp_statistics_seq=
_fops =3D {
=20
 static int __net_init ipdscp_proc_init(struct net *net)
 {
=2D	if (!proc_net_fops_create(net, "ipdscp", S_IRUGO,
+	if (!proc_net_fops_create(net, "ip_dscp", S_IRUGO,
 				  &ipdscp_statistics_seq_fops))
 		return -ENOMEM;
 	return 0;
=2D-=20
1.6.3.3


--Boundary-00=_RLzSLz1GD9+AymC--
