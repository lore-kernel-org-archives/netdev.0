From: Harald Welte <laforge-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>
Subject: Re: [PATCH] ebtables: Port ebt_[u]log.c to nf[netlink]_log
Date: Wed, 12 Oct 2005 08:27:46 +0200
Message-ID: <20051012062745.GB4237@rama.de.gnumonks.org>
References: <20051007234903.GR4450@rama.customers.eurospot.com> <1129059110.5087.8.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="Y5rl02BVI9TCfPar"
Cc: Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	ebtables-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Return-path: <ebtables-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: Bart De Schuymer <bdschuym-LPO8gxj9N8aZIoH1IeqzKA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1129059110.5087.8.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: ebtables-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: ebtables-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/ebtables-devel>,
	<mailto:ebtables-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Post: <mailto:ebtables-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:ebtables-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/ebtables-devel>,
	<mailto:ebtables-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=ebtables-devel>
List-Id: netdev.vger.kernel.org


--Y5rl02BVI9TCfPar
Content-Type: multipart/mixed; boundary="gatW/ieO32f1wygP"
Content-Disposition: inline


--gatW/ieO32f1wygP
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Oct 11, 2005 at 07:31:50PM +0000, Bart De Schuymer wrote:
> I seem to be unable to get Davem's current git tree.
> This fails miserably:=20
> cg-clone http://www.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6.git

Try getting it via rsync, I never have successfully ran cg/git via http.

Also, a recent linus tree should be sufficient, even one of the latest
2.6.14-rc3/rc4 tarballs should be fine.

> Your patch won't apply to 2.6.13. At first I thought it was a problem
> with evolution or the kernel version, but looking at the source code of
> your mail, I see "=3D20" added here and there...

I've attached it to this mail again.  Since it isn't inline, saving it
as attachment should do fine.

--=20
- Harald Welte <laforge-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>                 http://netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--gatW/ieO32f1wygP
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="81-ebt_ulog-nf_log.patch"
Content-Transfer-Encoding: quoted-printable

[NETFILTER] ebtables: Port ebt_[u]log.c to nf[netlink]_log

Since we now have a netfilter core logging API, we port the bridging log
and ulog watchers to this new API.

This basically means that if you use the "ebt_log" watcher, it will by
default log to the system console, but enables a userspace logging daemon
binds itself to PF_BRIDGE, and take over all logging.

ebt_ulog also registers itself as logger with nf_log, but any packets
explicitly send to ebt_ulog will always use the ulog mechanism and not
handled via the generic logging handler.

This change resembles the situation that is now present in ipv4.

Signed-off-by: Harald Welte <laforge-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>

---
commit 0dc2bc0656b4b1c5ba3524dadc8fbf36881903b7
tree 0e43d4f7b10f022ff523ea4751546d76d53c57b7
parent 2e64e94fe8e7e4630c9d9e66c437f3ba81e99f78
author Harald Welte <laforge-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org> Sat, 08 Oct 2005 01:43:49 +0200
committer Harald Welte <laforge-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org> Sat, 08 Oct 2005 01:43:49 +0=
200

 net/bridge/netfilter/Kconfig    |    6 +++-
 net/bridge/netfilter/ebt_log.c  |   61 +++++++++++++++++++++++++++++++++--=
----
 net/bridge/netfilter/ebt_ulog.c |   48 +++++++++++++++++++++++++++++--
 3 files changed, 102 insertions(+), 13 deletions(-)

diff --git a/net/bridge/netfilter/Kconfig b/net/bridge/netfilter/Kconfig
--- a/net/bridge/netfilter/Kconfig
+++ b/net/bridge/netfilter/Kconfig
@@ -196,9 +196,13 @@ config BRIDGE_EBT_LOG
 	  To compile it as a module, choose M here.  If unsure, say N.
=20
 config BRIDGE_EBT_ULOG
-	tristate "ebt: ulog support"
+	tristate "ebt: ulog support (OBSOLETE)"
 	depends on BRIDGE_NF_EBTABLES
 	help
+	  This option enables the old bridge-specific "ebt_ulog" implementation
+	  which has been obsoleted by the new "nfnetlink_log" code (see
+	  CONFIG_NETFILTER_NETLINK_LOG).
+
 	  This option adds the ulog watcher, that you can use in any rule
 	  in any ebtables table. The packet is passed to a userspace
 	  logging daemon using netlink multicast sockets. This differs
diff --git a/net/bridge/netfilter/ebt_log.c b/net/bridge/netfilter/ebt_log.c
--- a/net/bridge/netfilter/ebt_log.c
+++ b/net/bridge/netfilter/ebt_log.c
@@ -3,6 +3,7 @@
  *
  *	Authors:
  *	Bart De Schuymer <bdschuym-LPO8gxj9N8aZIoH1IeqzKA@public.gmane.org>
+ *	Harald Welte <laforge-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>
  *
  *  April, 2002
  *
@@ -10,6 +11,7 @@
=20
 #include <linux/netfilter_bridge/ebtables.h>
 #include <linux/netfilter_bridge/ebt_log.h>
+#include <linux/netfilter.h>
 #include <linux/module.h>
 #include <linux/ip.h>
 #include <linux/if_arp.h>
@@ -55,17 +57,19 @@ static void print_MAC(unsigned char *p)
 }
=20
 #define myNIPQUAD(a) a[0], a[1], a[2], a[3]
-static void ebt_log(const struct sk_buff *skb, unsigned int hooknr,
-   const struct net_device *in, const struct net_device *out,
-   const void *data, unsigned int datalen)
+static void
+ebt_log_packet(unsigned int pf, unsigned int hooknum,
+   const struct sk_buff *skb, const struct net_device *in,
+   const struct net_device *out, const struct nf_loginfo *loginfo,
+   const char *prefix)
 {
-	struct ebt_log_info *info =3D (struct ebt_log_info *)data;
 	char level_string[4] =3D "< >";
+	unsigned int bitmask;
=20
-	level_string[1] =3D '0' + info->loglevel;
+	level_string[1] =3D '0' + loginfo->u.log.level;
 	spin_lock_bh(&ebt_log_lock);
 	printk(level_string);
-	printk("%s IN=3D%s OUT=3D%s ", info->prefix, in ? in->name : "",
+	printk("%s IN=3D%s OUT=3D%s ", prefix, in ? in->name : "",
 	   out ? out->name : "");
=20
 	printk("MAC source =3D ");
@@ -75,7 +79,12 @@ static void ebt_log(const struct sk_buff
=20
 	printk("proto =3D 0x%04x", ntohs(eth_hdr(skb)->h_proto));
=20
-	if ((info->bitmask & EBT_LOG_IP) && eth_hdr(skb)->h_proto =3D=3D
+	if (loginfo->type =3D=3D NF_LOG_TYPE_LOG)
+		bitmask =3D loginfo->u.log.logflags;
+	else
+		bitmask =3D NF_LOG_MASK;
+
+	if ((bitmask & EBT_LOG_IP) && eth_hdr(skb)->h_proto =3D=3D
 	   htons(ETH_P_IP)){
 		struct iphdr _iph, *ih;
=20
@@ -104,7 +113,7 @@ static void ebt_log(const struct sk_buff
 		goto out;
 	}
=20
-	if ((info->bitmask & EBT_LOG_ARP) &&
+	if ((bitmask & EBT_LOG_ARP) &&
 	    ((eth_hdr(skb)->h_proto =3D=3D htons(ETH_P_ARP)) ||
 	     (eth_hdr(skb)->h_proto =3D=3D htons(ETH_P_RARP)))) {
 		struct arphdr _arph, *ah;
@@ -144,6 +153,21 @@ static void ebt_log(const struct sk_buff
 out:
 	printk("\n");
 	spin_unlock_bh(&ebt_log_lock);
+
+}
+
+static void ebt_log(const struct sk_buff *skb, unsigned int hooknr,
+   const struct net_device *in, const struct net_device *out,
+   const void *data, unsigned int datalen)
+{
+	struct ebt_log_info *info =3D (struct ebt_log_info *)data;
+	struct nf_loginfo li;
+
+	li.type =3D NF_LOG_TYPE_LOG;
+	li.u.log.level =3D info->loglevel;
+	li.u.log.logflags =3D info->bitmask;
+
+	nf_log_packet(PF_BRIDGE, hooknr, skb, in, out, &li, info->prefix);
 }
=20
 static struct ebt_watcher log =3D
@@ -154,13 +178,32 @@ static struct ebt_watcher log =3D
 	.me		=3D THIS_MODULE,
 };
=20
+static struct nf_logger ebt_log_logger =3D {
+	.name 		=3D "ebt_log",
+	.logfn		=3D &ebt_log_packet,
+	.me		=3D THIS_MODULE,
+};
+
 static int __init init(void)
 {
-	return ebt_register_watcher(&log);
+	int ret;
+
+	ret =3D ebt_register_watcher(&log);
+	if (ret < 0)
+		return ret;
+	if (nf_log_register(PF_BRIDGE, &ebt_log_logger) < 0) {
+		printk(KERN_WARNING "ebt_log: not logging via system console "
+		       "since somebody else already registered for PF_INET\n");
+		/* wecannot make module load fail here, since otherwise=20
+		 * ebtables userspace would abort */
+	}
+
+	return 0;
 }
=20
 static void __exit fini(void)
 {
+	nf_log_unregister_logger(&ebt_log_logger);
 	ebt_unregister_watcher(&log);
 }
=20
diff --git a/net/bridge/netfilter/ebt_ulog.c b/net/bridge/netfilter/ebt_ulo=
g.c
--- a/net/bridge/netfilter/ebt_ulog.c
+++ b/net/bridge/netfilter/ebt_ulog.c
@@ -3,6 +3,7 @@
  *
  *	Authors:
  *	Bart De Schuymer <bdschuym-LPO8gxj9N8aZIoH1IeqzKA@public.gmane.org>
+ *	Harald Welte <laforge-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>
  *
  *  November, 2004
  *
@@ -115,14 +116,13 @@ static struct sk_buff *ulog_alloc_skb(un
 	return skb;
 }
=20
-static void ebt_ulog(const struct sk_buff *skb, unsigned int hooknr,
+static void ebt_ulog_packet(unsigned int hooknr, const struct sk_buff *skb,
    const struct net_device *in, const struct net_device *out,
-   const void *data, unsigned int datalen)
+   const struct ebt_ulog_info *uloginfo, const char *prefix)
 {
 	ebt_ulog_packet_msg_t *pm;
 	size_t size, copy_len;
 	struct nlmsghdr *nlh;
-	struct ebt_ulog_info *uloginfo =3D (struct ebt_ulog_info *)data;
 	unsigned int group =3D uloginfo->nlgroup;
 	ebt_ulog_buff_t *ub =3D &ulog_buffers[group];
 	spinlock_t *lock =3D &ub->lock;
@@ -216,6 +216,39 @@ alloc_failure:
 	goto unlock;
 }
=20
+/* this function is registered with the netfilter core */
+static void ebt_log_packet(unsigned int pf, unsigned int hooknum,
+   const struct sk_buff *skb, const struct net_device *in,
+   const struct net_device *out, const struct nf_loginfo *li,
+   const char *prefix)
+{
+	struct ebt_ulog_info loginfo;
+
+	if (!li || li->type !=3D NF_LOG_TYPE_ULOG) {
+		loginfo.nlgroup =3D EBT_ULOG_DEFAULT_NLGROUP;
+		loginfo.cprange =3D 0;
+		loginfo.qthreshold =3D EBT_ULOG_DEFAULT_QTHRESHOLD;
+		loginfo.prefix[0] =3D '\0';
+	} else {
+		loginfo.nlgroup =3D li->u.ulog.group;
+		loginfo.cprange =3D li->u.ulog.copy_len;
+		loginfo.qthreshold =3D li->u.ulog.qthreshold;
+		strlcpy(loginfo.prefix, prefix, sizeof(loginfo.prefix));
+	}
+
+	ebt_ulog_packet(hooknum, skb, in, out, &loginfo, prefix);
+}
+
+static void ebt_ulog(const struct sk_buff *skb, unsigned int hooknr,
+   const struct net_device *in, const struct net_device *out,
+   const void *data, unsigned int datalen)
+{
+	struct ebt_ulog_info *uloginfo =3D (struct ebt_ulog_info *)data;
+
+	ebt_ulog_packet(hooknr, skb, in, out, uloginfo, NULL);
+}
+
+
 static int ebt_ulog_check(const char *tablename, unsigned int hookmask,
    const struct ebt_entry *e, void *data, unsigned int datalen)
 {
@@ -240,6 +273,12 @@ static struct ebt_watcher ulog =3D {
 	.me		=3D THIS_MODULE,
 };
=20
+static struct nf_logger ebt_ulog_logger =3D {
+	.name		=3D EBT_ULOG_WATCHER,
+	.logfn		=3D &ebt_log_packet,
+	.me		=3D THIS_MODULE,
+};
+
 static int __init init(void)
 {
 	int i, ret =3D 0;
@@ -265,6 +304,8 @@ static int __init init(void)
 	else if ((ret =3D ebt_register_watcher(&ulog)))
 		sock_release(ebtulognl->sk_socket);
=20
+	nf_log_register(PF_BRIDGE, &ebt_ulog_logger);
+
 	return ret;
 }
=20
@@ -273,6 +314,7 @@ static void __exit fini(void)
 	ebt_ulog_buff_t *ub;
 	int i;
=20
+	nf_log_unregister_logger(&ebt_ulog_logger);
 	ebt_unregister_watcher(&ulog);
 	for (i =3D 0; i < EBT_ULOG_MAXNLGROUPS; i++) {
 		ub =3D &ulog_buffers[i];

--gatW/ieO32f1wygP--

--Y5rl02BVI9TCfPar
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQFDTKzhXaXGVTD0i/8RAp3vAJ9SBcxzDE8ksp4LalHozxLlx0Dq2wCgqlS5
L8+hoZFJ2AGi8dAeYbfE7Q4=
=PcJq
-----END PGP SIGNATURE-----

--Y5rl02BVI9TCfPar--


-------------------------------------------------------
This SF.Net email is sponsored by:
Power Architecture Resource Center: Free content, downloads, discussions,
and more. http://solutions.newsforge.com/ibmarch.tmpl
