From: igorm@etf.rs
Subject: [PATCH 4/4 net-next] net:bridge: use IS_ENABLED
Date: Mon, 12 Dec 2011 04:58:25 -0800
Message-ID: <1323694705-2793-4-git-send-email-igorm@etf.rs>
References: <igorm@etf.rs>
 <1323694705-2793-1-git-send-email-igorm@etf.rs>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, =?UTF-8?q?Igor=20Maravi=C4=87?= <igorm@etf.rs>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.etf.rs ([147.91.14.169]:47699 "EHLO mx1.etf.bg.ac.rs"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753032Ab1LLM7D convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Dec 2011 07:59:03 -0500
In-Reply-To: <1323694705-2793-1-git-send-email-igorm@etf.rs>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Igor Maravi=C4=87 <igorm@etf.rs>

Use IS_ENABLED(CONFIG_FOO)
instead of defined(CONFIG_FOO) || defined (CONFIG_FOO_MODULE)

Signed-off-by: Igor Maravi=C4=87 <igorm@etf.rs>
---
 net/bridge/br.c                |    4 ++--
 net/bridge/br_fdb.c            |    2 +-
 net/bridge/br_netfilter.c      |    2 +-
 net/bridge/br_private.h        |    2 +-
 net/bridge/netfilter/ebt_log.c |    2 +-
 5 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/bridge/br.c b/net/bridge/br.c
index f20c4fd..ba780cc 100644
--- a/net/bridge/br.c
+++ b/net/bridge/br.c
@@ -62,7 +62,7 @@ static int __init br_init(void)
=20
 	brioctl_set(br_ioctl_deviceless_stub);
=20
-#if defined(CONFIG_ATM_LANE) || defined(CONFIG_ATM_LANE_MODULE)
+#if IS_ENABLED(CONFIG_ATM_LANE)
 	br_fdb_test_addr_hook =3D br_fdb_test_addr;
 #endif
=20
@@ -93,7 +93,7 @@ static void __exit br_deinit(void)
 	rcu_barrier(); /* Wait for completion of call_rcu()'s */
=20
 	br_netfilter_fini();
-#if defined(CONFIG_ATM_LANE) || defined(CONFIG_ATM_LANE_MODULE)
+#if IS_ENABLED(CONFIG_ATM_LANE)
 	br_fdb_test_addr_hook =3D NULL;
 #endif
=20
diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index a1429af..f963f6b 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -247,7 +247,7 @@ struct net_bridge_fdb_entry *__br_fdb_get(struct ne=
t_bridge *br,
 	return NULL;
 }
=20
-#if defined(CONFIG_ATM_LANE) || defined(CONFIG_ATM_LANE_MODULE)
+#if IS_ENABLED(CONFIG_ATM_LANE)
 /* Interface used by ATM LANE hook to test
  * if an addr is on some other bridge port */
 int br_fdb_test_addr(struct net_device *dev, unsigned char *addr)
diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index 834dfab..52e4460 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -807,7 +807,7 @@ static unsigned int br_nf_forward_arp(unsigned int =
hook, struct sk_buff *skb,
 	return NF_STOLEN;
 }
=20
-#if defined(CONFIG_NF_CONNTRACK_IPV4) || defined(CONFIG_NF_CONNTRACK_I=
PV4_MODULE)
+#if IS_ENABLED(CONFIG_NF_CONNTRACK_IPV4)
 static int br_nf_dev_queue_xmit(struct sk_buff *skb)
 {
 	int ret;
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 57dcd14..0b67a63 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -537,7 +537,7 @@ extern void br_stp_port_timer_init(struct net_bridg=
e_port *p);
 extern unsigned long br_timer_value(const struct timer_list *timer);
=20
 /* br.c */
-#if defined(CONFIG_ATM_LANE) || defined(CONFIG_ATM_LANE_MODULE)
+#if IS_ENABLED(CONFIG_ATM_LANE)
 extern int (*br_fdb_test_addr_hook)(struct net_device *dev, unsigned c=
har *addr);
 #endif
=20
diff --git a/net/bridge/netfilter/ebt_log.c b/net/bridge/netfilter/ebt_=
log.c
index 88d7d1d..f88ee53 100644
--- a/net/bridge/netfilter/ebt_log.c
+++ b/net/bridge/netfilter/ebt_log.c
@@ -107,7 +107,7 @@ ebt_log_packet(u_int8_t pf, unsigned int hooknum,
 		goto out;
 	}
=20
-#if defined(CONFIG_BRIDGE_EBT_IP6) || defined(CONFIG_BRIDGE_EBT_IP6_MO=
DULE)
+#if IS_ENABLED(CONFIG_BRIDGE_EBT_IP6)
 	if ((bitmask & EBT_LOG_IP6) && eth_hdr(skb)->h_proto =3D=3D
 	   htons(ETH_P_IPV6)) {
 		const struct ipv6hdr *ih;
--=20
1.7.5.4
