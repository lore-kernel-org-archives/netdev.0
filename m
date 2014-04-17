From: Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
Subject: [patch net-next RFC v3 06/10] net: introduce dummy switch
Date: Thu, 17 Apr 2014 14:14:33 +0200
Message-ID: <1397736876-11771-7-git-send-email-jiri@resnulli.us>
References: <1397736876-11771-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: ryazanov.s.a-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, jasowang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
 Neil.Jerram-QnUH15yq9NYqDJ6do+/SaQ@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, andy-QlMahl40kYEqcZcGjlUOXw@public.gmane.org,
 dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org, f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
 jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org,
 buytenh-OLH4Qvv75CYX/NnBR394Jw@public.gmane.org, roopa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org, jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org,
 linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, aviadr-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org,
 vyasevic-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, sfeldma-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org,
 stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org, dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org,
 davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1397736876-11771-1-git-send-email-jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Sender: "dev" <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

Dummy switch implementation using switchdev interface

Signed-off-by: Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
---
 drivers/net/Kconfig          |   7 +++
 drivers/net/Makefile         |   1 +
 drivers/net/dummyswitch.c    | 126 +++++++++++++++++++++++++++++++++++++++++++
 include/uapi/linux/if_link.h |   9 ++++
 4 files changed, 143 insertions(+)
 create mode 100644 drivers/net/dummyswitch.c

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 89402c3..a9629a7 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -71,6 +71,13 @@ config DUMMY
 	  To compile this driver as a module, choose M here: the module
 	  will be called dummy.
 
+config NET_DUMMY_SWITCH
+	tristate "Dummy switch net driver support"
+	depends on NET_SWITCHDEV
+	---help---
+	  To compile this driver as a module, choose M here: the module
+	  will be called dummyswitch.
+
 config EQUALIZER
 	tristate "EQL (serial line load balancing) support"
 	---help---
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 3fef8a8..d5d4ce6 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -7,6 +7,7 @@
 #
 obj-$(CONFIG_BONDING) += bonding/
 obj-$(CONFIG_DUMMY) += dummy.o
+obj-$(CONFIG_NET_DUMMY_SWITCH) += dummyswitch.o
 obj-$(CONFIG_EQUALIZER) += eql.o
 obj-$(CONFIG_IFB) += ifb.o
 obj-$(CONFIG_MACVLAN) += macvlan.o
diff --git a/drivers/net/dummyswitch.c b/drivers/net/dummyswitch.c
new file mode 100644
index 0000000..f0d1195
--- /dev/null
+++ b/drivers/net/dummyswitch.c
@@ -0,0 +1,126 @@
+/*
+ * drivers/net/dummyswitch.c - Dummy switch device
+ * Copyright (c) 2014 Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/init.h>
+#include <linux/etherdevice.h>
+#include <linux/switchdev.h>
+
+#include <net/rtnetlink.h>
+
+struct dummyswport_priv {
+	struct netdev_phys_item_id psid;
+};
+
+static netdev_tx_t dummyswport_start_xmit(struct sk_buff *skb,
+					  struct net_device *dev)
+{
+	dev_kfree_skb(skb);
+	return NETDEV_TX_OK;
+}
+
+static int dummyswport_swdev_get_id(struct net_device *dev,
+				    struct netdev_phys_item_id *psid)
+{
+	struct dummyswport_priv *dsp = netdev_priv(dev);
+
+	memcpy(psid, &dsp->psid, sizeof(*psid));
+	return 0;
+}
+
+static const struct net_device_ops dummyswport_netdev_ops = {
+	.ndo_start_xmit		= dummyswport_start_xmit,
+	.ndo_swdev_get_id	= dummyswport_swdev_get_id,
+};
+
+static void dummyswport_setup(struct net_device *dev)
+{
+	ether_setup(dev);
+
+	/* Initialize the device structure. */
+	dev->netdev_ops = &dummyswport_netdev_ops;
+	dev->destructor = free_netdev;
+
+	/* Fill in device structure with ethernet-generic values. */
+	dev->tx_queue_len = 0;
+	dev->flags |= IFF_NOARP;
+	dev->flags &= ~IFF_MULTICAST;
+	dev->priv_flags |= IFF_LIVE_ADDR_CHANGE;
+	dev->features	|= NETIF_F_SG | NETIF_F_FRAGLIST | NETIF_F_TSO;
+	dev->features	|= NETIF_F_HW_CSUM | NETIF_F_HIGHDMA | NETIF_F_LLTX;
+	eth_hw_addr_random(dev);
+}
+
+static int dummyswport_validate(struct nlattr *tb[], struct nlattr *data[])
+{
+	if (tb[IFLA_ADDRESS])
+		return -EINVAL;
+	if (!data || !data[IFLA_DYMMYSWPORT_PHYS_SWITCH_ID])
+		return -EINVAL;
+	return 0;
+}
+
+static int dummyswport_newlink(struct net *src_net, struct net_device *dev,
+			       struct nlattr *tb[], struct nlattr *data[])
+{
+	struct dummyswport_priv *dsp = netdev_priv(dev);
+	int err;
+
+	dsp->psid.id_len = nla_len(data[IFLA_DYMMYSWPORT_PHYS_SWITCH_ID]);
+	memcpy(dsp->psid.id, nla_data(data[IFLA_DYMMYSWPORT_PHYS_SWITCH_ID]),
+	       dsp->psid.id_len);
+
+	err = register_netdevice(dev);
+	if (err)
+		return err;
+
+	netif_carrier_on(dev);
+
+	return 0;
+}
+
+static const struct nla_policy dummyswport_policy[IFLA_DUMMYSWPORT_MAX + 1] = {
+	[IFLA_DYMMYSWPORT_PHYS_SWITCH_ID] = { .type = NLA_BINARY,
+					      .len = MAX_PHYS_ITEM_ID_LEN },
+};
+
+static struct rtnl_link_ops dummyswport_link_ops __read_mostly = {
+	.kind		= "dummyswport",
+	.priv_size	= sizeof(struct dummyswport_priv),
+	.setup		= dummyswport_setup,
+	.validate	= dummyswport_validate,
+	.newlink	= dummyswport_newlink,
+	.policy		= dummyswport_policy,
+	.maxtype	= IFLA_DUMMYSWPORT_MAX,
+};
+
+
+/*
+ * Module init/exit
+ */
+
+static int __init dummysw_module_init(void)
+{
+	return rtnl_link_register(&dummyswport_link_ops);
+}
+
+static void __exit dummysw_module_exit(void)
+{
+	rtnl_link_unregister(&dummyswport_link_ops);
+}
+
+module_init(dummysw_module_init);
+module_exit(dummysw_module_exit);
+
+MODULE_LICENSE("GPL v2");
+MODULE_AUTHOR("Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>");
+MODULE_DESCRIPTION("Dummy switch device");
+MODULE_ALIAS_RTNL_LINK("dummyswport");
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index c11f492..f38e3d9 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -546,4 +546,13 @@ enum {
 
 #define IFLA_HSR_MAX (__IFLA_HSR_MAX - 1)
 
+/* DUMMYSWPORT section */
+enum {
+	IFLA_DUMMYSWPORT_UNSPEC,
+	IFLA_DYMMYSWPORT_PHYS_SWITCH_ID,
+	__IFLA_DUMMYSWPORT_MAX,
+};
+
+#define IFLA_DUMMYSWPORT_MAX (__IFLA_DUMMYSWPORT_MAX - 1)
+
 #endif /* _UAPI_LINUX_IF_LINK_H */
-- 
1.9.0
