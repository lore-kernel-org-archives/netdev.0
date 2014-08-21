From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next RFC 07/12] dsa: implement ndo_swdev_get_id
Date: Thu, 21 Aug 2014 18:19:00 +0200
Message-ID: <1408637945-10390-8-git-send-email-jiri@resnulli.us>
References: <1408637945-10390-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, nhorman@tuxdriver.com, andy@greyhouse.net,
	tgraf@suug.ch, dborkman@redhat.com, ogerlitz@mellanox.com,
	jesse@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, jhs@mojatatu.com, sfeldma@cumulusnetworks.com,
	f.fainelli@gmail.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, dev@openvswitch.org, jasowang@redhat.com,
	ebiederm@xmission.com, nicolas.dichtel@6wind.com,
	ryazanov.s.a@gmail.com, buytenh@wantstofly.org,
	aviadr@mellanox.com, nbd@openwrt.org, alexei.starovoitov@gmail.com,
	Neil.Jerram@metaswitch.com, ronye@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:61479 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752374AbaHUQTe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2014 12:19:34 -0400
Received: by mail-wi0-f173.google.com with SMTP id f8so8966850wiw.12
        for <netdev@vger.kernel.org>; Thu, 21 Aug 2014 09:19:33 -0700 (PDT)
In-Reply-To: <1408637945-10390-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 net/dsa/Kconfig |  2 +-
 net/dsa/slave.c | 16 ++++++++++++++++
 2 files changed, 17 insertions(+), 1 deletion(-)

diff --git a/net/dsa/Kconfig b/net/dsa/Kconfig
index f5eede1..66c445a 100644
--- a/net/dsa/Kconfig
+++ b/net/dsa/Kconfig
@@ -1,6 +1,6 @@
 config HAVE_NET_DSA
 	def_bool y
-	depends on NETDEVICES && !S390
+	depends on NETDEVICES && NET_SWITCHDEV && !S390
 
 # Drivers must select NET_DSA and the appropriate tagging format
 
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 45a1e34..e069ba3 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -171,6 +171,19 @@ static int dsa_slave_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 	return -EOPNOTSUPP;
 }
 
+static int dsa_slave_swdev_get_id(struct net_device *dev,
+				  struct netdev_phys_item_id *psid)
+{
+	struct dsa_slave_priv *p = netdev_priv(dev);
+	struct dsa_switch *ds = p->parent;
+	u64 tmp = (u64) ds;
+
+	/* TODO: add more sophisticated id generation */
+	memcpy(&psid->id, &tmp, sizeof(tmp));
+	psid->id_len = sizeof(tmp);
+
+	return 0;
+}
 
 /* ethtool operations *******************************************************/
 static int
@@ -303,6 +316,7 @@ static const struct net_device_ops dsa_netdev_ops = {
 	.ndo_set_rx_mode	= dsa_slave_set_rx_mode,
 	.ndo_set_mac_address	= dsa_slave_set_mac_address,
 	.ndo_do_ioctl		= dsa_slave_ioctl,
+	.ndo_swdev_get_id	= dsa_slave_swdev_get_id,
 };
 #endif
 #ifdef CONFIG_NET_DSA_TAG_EDSA
@@ -315,6 +329,7 @@ static const struct net_device_ops edsa_netdev_ops = {
 	.ndo_set_rx_mode	= dsa_slave_set_rx_mode,
 	.ndo_set_mac_address	= dsa_slave_set_mac_address,
 	.ndo_do_ioctl		= dsa_slave_ioctl,
+	.ndo_swdev_get_id	= dsa_slave_swdev_get_id,
 };
 #endif
 #ifdef CONFIG_NET_DSA_TAG_TRAILER
@@ -327,6 +342,7 @@ static const struct net_device_ops trailer_netdev_ops = {
 	.ndo_set_rx_mode	= dsa_slave_set_rx_mode,
 	.ndo_set_mac_address	= dsa_slave_set_mac_address,
 	.ndo_do_ioctl		= dsa_slave_ioctl,
+	.ndo_swdev_get_id	= dsa_slave_swdev_get_id,
 };
 #endif
 
-- 
1.9.3
