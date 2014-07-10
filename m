From: Tom Gundersen <teg@jklm.no>
Subject: [PATCH v7 05/33] net: set name assign type for names assigned using a static string
Date: Thu, 10 Jul 2014 10:17:10 +0200
Message-ID: <1404980258-30853-6-git-send-email-teg@jklm.no>
References: <1404980258-30853-1-git-send-email-teg@jklm.no>
Cc: linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>,
	David Herrmann <dh.herrmann@gmail.com>,
	Kay Sievers <kay@vrfy.org>, Tom Gundersen <teg@jklm.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f179.google.com ([209.85.217.179]:57279 "EHLO
	mail-lb0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752074AbaGJISM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2014 04:18:12 -0400
Received: by mail-lb0-f179.google.com with SMTP id z11so5833035lbi.10
        for <netdev@vger.kernel.org>; Thu, 10 Jul 2014 01:18:10 -0700 (PDT)
In-Reply-To: <1404980258-30853-1-git-send-email-teg@jklm.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This covers the trivial case:

alloc_netdev(_, "bar", NET_NAME_PREDICTABLE, _);

Signed-off-by: Tom Gundersen <teg@jklm.no>
---
 drivers/media/dvb-core/dvb_net.c | 2 +-
 drivers/misc/sgi-xp/xpnet.c      | 2 +-
 drivers/net/caif/caif_virtio.c   | 2 +-
 drivers/net/eql.c                | 4 ++--
 drivers/net/loopback.c           | 2 +-
 drivers/net/wan/sbni.c           | 2 +-
 drivers/net/wan/sdla.c           | 4 ++--
 drivers/s390/net/ctcm_main.c     | 4 ++--
 drivers/staging/vt6655/wpactl.c  | 2 +-
 net/ipv6/ip6_gre.c               | 2 +-
 net/ipv6/ip6_tunnel.c            | 3 ++-
 net/ipv6/ip6_vti.c               | 2 +-
 net/ipv6/sit.c                   | 2 +-
 13 files changed, 17 insertions(+), 16 deletions(-)

diff --git a/drivers/media/dvb-core/dvb_net.c b/drivers/media/dvb-core/dvb_net.c
index 059e611..998baf6 100644
--- a/drivers/media/dvb-core/dvb_net.c
+++ b/drivers/media/dvb-core/dvb_net.c
@@ -1277,7 +1277,7 @@ static int dvb_net_add_if(struct dvb_net *dvbnet, u16 pid, u8 feedtype)
 		return -EINVAL;
 
 	net = alloc_netdev(sizeof(struct dvb_net_priv), "dvb",
-			   NET_NAME_UNKNOWN, dvb_net_setup);
+			   NET_NAME_PREDICTABLE, dvb_net_setup);
 	if (!net)
 		return -ENOMEM;
 
diff --git a/drivers/misc/sgi-xp/xpnet.c b/drivers/misc/sgi-xp/xpnet.c
index 557f978..2adb022 100644
--- a/drivers/misc/sgi-xp/xpnet.c
+++ b/drivers/misc/sgi-xp/xpnet.c
@@ -544,7 +544,7 @@ xpnet_init(void)
 	 * use ether_setup() to init the majority of our device
 	 * structure and then override the necessary pieces.
 	 */
-	xpnet_device = alloc_netdev(0, XPNET_DEVICE_NAME, NET_NAME_UNKNOWN,
+	xpnet_device = alloc_netdev(0, XPNET_DEVICE_NAME, NET_NAME_PREDICTABLE,
 				    ether_setup);
 	if (xpnet_device == NULL) {
 		kfree(xpnet_broadcast_partitions);
diff --git a/drivers/net/caif/caif_virtio.c b/drivers/net/caif/caif_virtio.c
index a5fefb9..07c6a24 100644
--- a/drivers/net/caif/caif_virtio.c
+++ b/drivers/net/caif/caif_virtio.c
@@ -661,7 +661,7 @@ static int cfv_probe(struct virtio_device *vdev)
 	int err = -EINVAL;
 
 	netdev = alloc_netdev(sizeof(struct cfv_info), cfv_netdev_name,
-			      NET_NAME_UNKNOWN, cfv_netdev_setup);
+			      NET_NAME_PREDICTABLE, cfv_netdev_setup);
 	if (!netdev)
 		return -ENOMEM;
 
diff --git a/drivers/net/eql.c b/drivers/net/eql.c
index 957e5c0..5c1d986 100644
--- a/drivers/net/eql.c
+++ b/drivers/net/eql.c
@@ -585,8 +585,8 @@ static int __init eql_init_module(void)
 
 	pr_info("%s\n", version);
 
-	dev_eql = alloc_netdev(sizeof(equalizer_t), "eql", NET_NAME_UNKNOWN,
-			       eql_setup);
+	dev_eql = alloc_netdev(sizeof(equalizer_t), "eql",
+			       NET_NAME_PREDICTABLE, eql_setup);
 	if (!dev_eql)
 		return -ENOMEM;
 
diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
index 8f22625..6077691 100644
--- a/drivers/net/loopback.c
+++ b/drivers/net/loopback.c
@@ -195,7 +195,7 @@ static __net_init int loopback_net_init(struct net *net)
 	int err;
 
 	err = -ENOMEM;
-	dev = alloc_netdev(0, "lo", NET_NAME_UNKNOWN, loopback_setup);
+	dev = alloc_netdev(0, "lo", NET_NAME_PREDICTABLE, loopback_setup);
 	if (!dev)
 		goto out;
 
diff --git a/drivers/net/wan/sbni.c b/drivers/net/wan/sbni.c
index a9b7e9a..516b2ac 100644
--- a/drivers/net/wan/sbni.c
+++ b/drivers/net/wan/sbni.c
@@ -228,7 +228,7 @@ int __init sbni_probe(int unit)
 	int err;
 
 	dev = alloc_netdev(sizeof(struct net_local), "sbni",
-			   NET_NAME_UNKNOWN, sbni_devsetup);
+			   NET_NAME_PREDICTABLE, sbni_devsetup);
 	if (!dev)
 		return -ENOMEM;
 
diff --git a/drivers/net/wan/sdla.c b/drivers/net/wan/sdla.c
index 421ac5f..128d196 100644
--- a/drivers/net/wan/sdla.c
+++ b/drivers/net/wan/sdla.c
@@ -1631,8 +1631,8 @@ static int __init init_sdla(void)
 
 	printk("%s.\n", version);
 
-	sdla = alloc_netdev(sizeof(struct frad_local), "sdla0",
-			    NET_NAME_UNKNOWN, setup_sdla);
+	sdla = alloc_netdev(sizeof(struct frad_local), "sdla0", NET_NAME_PREDICTABLE,
+			    setup_sdla);
 	if (!sdla) 
 		return -ENOMEM;
 
diff --git a/drivers/s390/net/ctcm_main.c b/drivers/s390/net/ctcm_main.c
index e056dd4..5bf3254 100644
--- a/drivers/s390/net/ctcm_main.c
+++ b/drivers/s390/net/ctcm_main.c
@@ -1137,10 +1137,10 @@ static struct net_device *ctcm_init_netdevice(struct ctcm_priv *priv)
 		return NULL;
 
 	if (IS_MPC(priv))
-		dev = alloc_netdev(0, MPC_DEVICE_GENE, NET_NAME_UNKNOWN,
+		dev = alloc_netdev(0, MPC_DEVICE_GENE, NET_NAME_PREDICTABLE,
 				   ctcm_dev_setup);
 	else
-		dev = alloc_netdev(0, CTC_DEVICE_GENE, NET_NAME_UNKNOWN,
+		dev = alloc_netdev(0, CTC_DEVICE_GENE, NET_NAME_PREDICTABLE,
 				   ctcm_dev_setup);
 
 	if (!dev) {
diff --git a/drivers/staging/vt6655/wpactl.c b/drivers/staging/vt6655/wpactl.c
index 0814bfd..6167117 100644
--- a/drivers/staging/vt6655/wpactl.c
+++ b/drivers/staging/vt6655/wpactl.c
@@ -90,7 +90,7 @@ static int wpa_init_wpadev(PSDevice pDevice)
 	int ret = 0;
 
 	pDevice->wpadev = alloc_netdev(sizeof(PSDevice), "vntwpa",
-				       NET_NAME_UNKNOWN, wpadev_setup);
+				       NET_NAME_PREDICTABLE, wpadev_setup);
 	if (pDevice->wpadev == NULL)
 		return -ENOMEM;
 
diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index 1b7acfb..780e6fe 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -1324,7 +1324,7 @@ static int __net_init ip6gre_init_net(struct net *net)
 	int err;
 
 	ign->fb_tunnel_dev = alloc_netdev(sizeof(struct ip6_tnl), "ip6gre0",
-					  NET_NAME_UNKNOWN,
+					  NET_NAME_PREDICTABLE,
 					  ip6gre_tunnel_setup);
 	if (!ign->fb_tunnel_dev) {
 		err = -ENOMEM;
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 71bd2ad..cbba655 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -1773,7 +1773,8 @@ static int __net_init ip6_tnl_init_net(struct net *net)
 
 	err = -ENOMEM;
 	ip6n->fb_tnl_dev = alloc_netdev(sizeof(struct ip6_tnl), "ip6tnl0",
-					NET_NAME_UNKNOWN, ip6_tnl_dev_setup);
+					NET_NAME_PREDICTABLE,
+					ip6_tnl_dev_setup);
 
 	if (!ip6n->fb_tnl_dev)
 		goto err_alloc_dev;
diff --git a/net/ipv6/ip6_vti.c b/net/ipv6/ip6_vti.c
index 17ee4fc..67fd4e5 100644
--- a/net/ipv6/ip6_vti.c
+++ b/net/ipv6/ip6_vti.c
@@ -1020,7 +1020,7 @@ static int __net_init vti6_init_net(struct net *net)
 
 	err = -ENOMEM;
 	ip6n->fb_tnl_dev = alloc_netdev(sizeof(struct ip6_tnl), "ip6_vti0",
-					NET_NAME_UNKNOWN, vti6_dev_setup);
+					NET_NAME_PREDICTABLE, vti6_dev_setup);
 
 	if (!ip6n->fb_tnl_dev)
 		goto err_alloc_dev;
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 2e9ba03..ff5aff8 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -1730,7 +1730,7 @@ static int __net_init sit_init_net(struct net *net)
 	sitn->tunnels[3] = sitn->tunnels_r_l;
 
 	sitn->fb_tunnel_dev = alloc_netdev(sizeof(struct ip_tunnel), "sit0",
-					   NET_NAME_UNKNOWN,
+					   NET_NAME_PREDICTABLE,
 					   ipip6_tunnel_setup);
 	if (!sitn->fb_tunnel_dev) {
 		err = -ENOMEM;
-- 
1.9.3
