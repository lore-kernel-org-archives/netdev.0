From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next RFC v3 07/10] dsa: implement ndo_swdev_get_id
Date: Thu, 17 Apr 2014 14:14:34 +0200
Message-ID: <1397736876-11771-8-git-send-email-jiri@resnulli.us>
References: <1397736876-11771-1-git-send-email-jiri@resnulli.us>
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
	Neil.Jerram@metaswitch.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f44.google.com ([74.125.83.44]:47979 "EHLO
	mail-ee0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1945891AbaDQMPJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Apr 2014 08:15:09 -0400
Received: by mail-ee0-f44.google.com with SMTP id e49so611571eek.3
        for <netdev@vger.kernel.org>; Thu, 17 Apr 2014 05:15:08 -0700 (PDT)
In-Reply-To: <1397736876-11771-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 net/dsa/slave.c | 16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 02c0e17..22855f3 100644
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
1.9.0
