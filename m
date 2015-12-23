From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH RFC 26/28] dsa: Convert mv88e6xxx into a library allowing driver modules
Date: Wed, 23 Dec 2015 13:56:40 +0100
Message-ID: <1450875402-20740-27-git-send-email-andrew@lunn.ch>
References: <1450875402-20740-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Florian Fainelli <f.fainelli@gmail.com>, narmstrong@baylibre.com,
	vivien.didelot@savoirfairelinux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:48699 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757101AbbLWM5f (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Dec 2015 07:57:35 -0500
In-Reply-To: <1450875402-20740-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Turn mv88e6xxx into a library module, by exporting its symbols.  Have
each driver register their own driver functions with the DSA core in
there init function.

This results in each driver being a loadable module.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/Makefile    | 19 +++--------
 drivers/net/dsa/mv88e6123.c | 16 ++++++++-
 drivers/net/dsa/mv88e6131.c | 17 +++++++++-
 drivers/net/dsa/mv88e6171.c | 17 +++++++++-
 drivers/net/dsa/mv88e6352.c | 17 +++++++++-
 drivers/net/dsa/mv88e6xxx.c | 81 +++++++++++++++++++++++++--------------------
 6 files changed, 114 insertions(+), 53 deletions(-)

diff --git a/drivers/net/dsa/Makefile b/drivers/net/dsa/Makefile
index a6e09939be65..7fa35fae4531 100644
--- a/drivers/net/dsa/Makefile
+++ b/drivers/net/dsa/Makefile
@@ -1,16 +1,7 @@
 obj-$(CONFIG_NET_DSA_MV88E6060) += mv88e6060.o
-obj-$(CONFIG_NET_DSA_MV88E6XXX) += mv88e6xxx_drv.o
-mv88e6xxx_drv-y += mv88e6xxx.o
-ifdef CONFIG_NET_DSA_MV88E6123
-mv88e6xxx_drv-y += mv88e6123.o
-endif
-ifdef CONFIG_NET_DSA_MV88E6131
-mv88e6xxx_drv-y += mv88e6131.o
-endif
-ifdef CONFIG_NET_DSA_MV88E6352
-mv88e6xxx_drv-y += mv88e6352.o
-endif
-ifdef CONFIG_NET_DSA_MV88E6171
-mv88e6xxx_drv-y += mv88e6171.o
-endif
+obj-$(CONFIG_NET_DSA_MV88E6XXX) += mv88e6xxx.o
+obj-$(CONFIGNET_DSA_MV88E6131)  += mv88e6123.o
+obj-$(CONFIG_NET_DSA_MV88E6131) += mv88e6131.o
+obj-$(CONFIG_NET_DSA_MV88E6352) += mv88e6352.o
+obj-$(CONFIG_NET_DSA_MV88E6171) += mv88e6171.o
 obj-$(CONFIG_NET_DSA_BCM_SF2)	+= bcm_sf2.o
diff --git a/drivers/net/dsa/mv88e6123.c b/drivers/net/dsa/mv88e6123.c
index bb39720f3e8b..9680e59fd2ae 100644
--- a/drivers/net/dsa/mv88e6123.c
+++ b/drivers/net/dsa/mv88e6123.c
@@ -167,7 +167,21 @@ static struct platform_driver mv88e6123_driver = {
 		.of_match_table = mv88e6123_of_match,
 	},
 };
-module_platform_driver(mv88e6123_driver);
 
+static int __init mv88e6123_init(void)
+{
+	register_switch_driver(&mv88e6123_switch_driver);
+
+	return platform_driver_register(&mv88e6123_driver);
+}
+
+static void __exit mv88e6123_exit(void)
+{
+	platform_driver_unregister(&mv88e6123_driver);
+	unregister_switch_driver(&mv88e6123_switch_driver);
+}
+
+module_init(mv88e6123_init);
+module_exit(mv88e6123_exit);
 MODULE_DESCRIPTION("Driver for Marvell 6123 family ethernet switch chips");
 MODULE_LICENSE("GPL");
diff --git a/drivers/net/dsa/mv88e6131.c b/drivers/net/dsa/mv88e6131.c
index 2cd8c2155d3e..23fa2818b262 100644
--- a/drivers/net/dsa/mv88e6131.c
+++ b/drivers/net/dsa/mv88e6131.c
@@ -219,7 +219,22 @@ static struct platform_driver mv88e6131_driver = {
 		.of_match_table = mv88e6131_of_match,
 	},
 };
-module_platform_driver(mv88e6131_driver);
+
+static int __init mv88e6131_init(void)
+{
+	register_switch_driver(&mv88e6131_switch_driver);
+
+	return platform_driver_register(&mv88e6131_driver);
+}
+
+static void __exit mv88e6131_exit(void)
+{
+	platform_driver_unregister(&mv88e6131_driver);
+	unregister_switch_driver(&mv88e6131_switch_driver);
+}
+
+module_init(mv88e6131_init);
+module_exit(mv88e6131_exit);
 
 MODULE_DESCRIPTION("Driver for Marvell 6131 family ethernet switch chips");
 MODULE_LICENSE("GPL");
diff --git a/drivers/net/dsa/mv88e6171.c b/drivers/net/dsa/mv88e6171.c
index 780098d0ad19..c040664c1241 100644
--- a/drivers/net/dsa/mv88e6171.c
+++ b/drivers/net/dsa/mv88e6171.c
@@ -165,7 +165,22 @@ static struct platform_driver mv88e6171_driver = {
 		.of_match_table = mv88e6171_of_match,
 	},
 };
-module_platform_driver(mv88e6171_driver);
+
+static int __init mv88e6171_init(void)
+{
+	register_switch_driver(&mv88e6171_switch_driver);
+
+	return platform_driver_register(&mv88e6171_driver);
+}
+
+static void __exit mv88e6171_exit(void)
+{
+	platform_driver_unregister(&mv88e6171_driver);
+	unregister_switch_driver(&mv88e6171_switch_driver);
+}
+
+module_init(mv88e6171_init);
+module_exit(mv88e6171_exit);
 
 MODULE_DESCRIPTION("Driver for Marvell 6171 family ethernet switch chips");
 MODULE_LICENSE("GPL");
diff --git a/drivers/net/dsa/mv88e6352.c b/drivers/net/dsa/mv88e6352.c
index 7e28150d44e0..4248055909b0 100644
--- a/drivers/net/dsa/mv88e6352.c
+++ b/drivers/net/dsa/mv88e6352.c
@@ -384,7 +384,22 @@ static struct platform_driver mv88e6352_driver = {
 		.of_match_table = mv88e6352_of_match,
 	},
 };
-module_platform_driver(mv88e6352_driver);
+
+static int __init mv88e6352_init(void)
+{
+	register_switch_driver(&mv88e6352_switch_driver);
+
+	return platform_driver_register(&mv88e6352_driver);
+}
+
+static void __exit mv88e6352_exit(void)
+{
+	platform_driver_unregister(&mv88e6352_driver);
+	unregister_switch_driver(&mv88e6352_switch_driver);
+}
+
+module_init(mv88e6352_init);
+module_exit(mv88e6352_exit);
 
 MODULE_DESCRIPTION("Driver for Marvell 6352 family ethernet switch chips");
 MODULE_LICENSE("GPL");
diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 36921c3a1cf0..1dc0c4769036 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -123,6 +123,7 @@ int mv88e6xxx_reg_read(struct dsa_switch *ds, int addr, int reg)
 
 	return ret;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_reg_read);
 
 static int __mv88e6xxx_reg_write(struct mii_bus *bus, int sw_addr, int addr,
 				 int reg, u16 val)
@@ -180,6 +181,7 @@ int mv88e6xxx_reg_write(struct dsa_switch *ds, int addr, int reg, u16 val)
 
 	return ret;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_reg_write);
 
 int mv88e6xxx_set_addr_direct(struct dsa_switch *ds, u8 *addr)
 {
@@ -189,6 +191,7 @@ int mv88e6xxx_set_addr_direct(struct dsa_switch *ds, u8 *addr)
 
 	return 0;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_set_addr_direct);
 
 int mv88e6xxx_set_addr_indirect(struct dsa_switch *ds, u8 *addr)
 {
@@ -214,6 +217,7 @@ int mv88e6xxx_set_addr_indirect(struct dsa_switch *ds, u8 *addr)
 
 	return 0;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_set_addr_indirect);
 
 static int _mv88e6xxx_phy_read(struct dsa_switch *ds, int addr, int regnum)
 {
@@ -339,6 +343,7 @@ void mv88e6xxx_ppu_state_init(struct dsa_switch *ds)
 	ps->ppu_timer.data = (unsigned long)ps;
 	ps->ppu_timer.function = mv88e6xxx_ppu_reenable_timer;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_ppu_state_init);
 
 int mv88e6xxx_phy_read_ppu(struct dsa_switch *ds, int addr, int regnum)
 {
@@ -352,6 +357,7 @@ int mv88e6xxx_phy_read_ppu(struct dsa_switch *ds, int addr, int regnum)
 
 	return ret;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_phy_read_ppu);
 
 int mv88e6xxx_phy_write_ppu(struct dsa_switch *ds, int addr,
 			    int regnum, u16 val)
@@ -366,6 +372,7 @@ int mv88e6xxx_phy_write_ppu(struct dsa_switch *ds, int addr,
 
 	return ret;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_phy_write_ppu);
 #endif
 
 static bool mv88e6xxx_6065_family(struct dsa_switch *ds)
@@ -546,6 +553,7 @@ void mv88e6xxx_adjust_link(struct dsa_switch *ds, int port,
 out:
 	mutex_unlock(&ps->smi_mutex);
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_adjust_link);
 
 static int _mv88e6xxx_stats_wait(struct dsa_switch *ds)
 {
@@ -749,6 +757,7 @@ mv88e6xxx_get_strings(struct dsa_switch *ds, int port, uint8_t *data)
 		_mv88e6xxx_get_strings(ds, ARRAY_SIZE(mv88e6xxx_hw_stats) - 3,
 				       mv88e6xxx_hw_stats, port, data);
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_get_strings);
 
 int mv88e6xxx_get_sset_count(struct dsa_switch *ds)
 {
@@ -756,6 +765,7 @@ int mv88e6xxx_get_sset_count(struct dsa_switch *ds)
 		return ARRAY_SIZE(mv88e6xxx_hw_stats);
 	return ARRAY_SIZE(mv88e6xxx_hw_stats) - 3;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_get_sset_count);
 
 void
 mv88e6xxx_get_ethtool_stats(struct dsa_switch *ds,
@@ -770,11 +780,13 @@ mv88e6xxx_get_ethtool_stats(struct dsa_switch *ds,
 			ds, ARRAY_SIZE(mv88e6xxx_hw_stats) - 3,
 			mv88e6xxx_hw_stats, port, data);
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_get_ethtool_stats);
 
 int mv88e6xxx_get_regs_len(struct dsa_switch *ds, int port)
 {
 	return 32 * sizeof(u16);
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_get_regs_len);
 
 void mv88e6xxx_get_regs(struct dsa_switch *ds, int port,
 			struct ethtool_regs *regs, void *_p)
@@ -794,6 +806,7 @@ void mv88e6xxx_get_regs(struct dsa_switch *ds, int port,
 			p[i] = ret;
 	}
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_get_regs);
 
 static int _mv88e6xxx_wait(struct dsa_switch *ds, int reg, int offset,
 			   u16 mask)
@@ -837,12 +850,14 @@ int mv88e6xxx_eeprom_load_wait(struct dsa_switch *ds)
 	return mv88e6xxx_wait(ds, REG_GLOBAL2, GLOBAL2_EEPROM_OP,
 			      GLOBAL2_EEPROM_OP_LOAD);
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_eeprom_load_wait);
 
 int mv88e6xxx_eeprom_busy_wait(struct dsa_switch *ds)
 {
 	return mv88e6xxx_wait(ds, REG_GLOBAL2, GLOBAL2_EEPROM_OP,
 			      GLOBAL2_EEPROM_OP_BUSY);
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_eeprom_busy_wait);
 
 static int _mv88e6xxx_atu_wait(struct dsa_switch *ds)
 {
@@ -909,6 +924,7 @@ out:
 	mutex_unlock(&ps->smi_mutex);
 	return reg;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_get_eee);
 
 int mv88e6xxx_set_eee(struct dsa_switch *ds, int port,
 		      struct phy_device *phydev, struct ethtool_eee *e)
@@ -935,6 +951,7 @@ out:
 
 	return ret;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_set_eee);
 
 static int _mv88e6xxx_atu_cmd(struct dsa_switch *ds, u16 cmd)
 {
@@ -1122,6 +1139,7 @@ int mv88e6xxx_port_stp_update(struct dsa_switch *ds, int port, u8 state)
 
 	return 0;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_port_stp_update);
 
 static int _mv88e6xxx_port_pvid_get(struct dsa_switch *ds, int port, u16 *pvid)
 {
@@ -1148,6 +1166,7 @@ int mv88e6xxx_port_pvid_get(struct dsa_switch *ds, int port, u16 *pvid)
 
 	return 0;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_port_pvid_get);
 
 static int _mv88e6xxx_port_pvid_set(struct dsa_switch *ds, int port, u16 pvid)
 {
@@ -1469,6 +1488,7 @@ int mv88e6xxx_port_vlan_prepare(struct dsa_switch *ds, int port,
 	 */
 	return 0;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_port_vlan_prepare);
 
 static int _mv88e6xxx_port_vlan_add(struct dsa_switch *ds, int port, u16 vid,
 				    bool untagged)
@@ -1523,6 +1543,7 @@ unlock:
 
 	return err;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_port_vlan_add);
 
 static int _mv88e6xxx_port_vlan_del(struct dsa_switch *ds, int port, u16 vid)
 {
@@ -1593,6 +1614,7 @@ unlock:
 
 	return err;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_port_vlan_del);
 
 int mv88e6xxx_vlan_getnext(struct dsa_switch *ds, u16 *vid,
 			   unsigned long *ports, unsigned long *untagged)
@@ -1639,6 +1661,7 @@ unlock:
 
 	return 0;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_vlan_getnext);
 
 static int _mv88e6xxx_atu_mac_write(struct dsa_switch *ds,
 				    const unsigned char *addr)
@@ -1726,6 +1749,7 @@ int mv88e6xxx_port_fdb_prepare(struct dsa_switch *ds, int port,
 	 */
 	return 0;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_port_fdb_prepare);
 
 int mv88e6xxx_port_fdb_add(struct dsa_switch *ds, int port,
 			   const struct switchdev_obj_port_fdb *fdb,
@@ -1743,6 +1767,7 @@ int mv88e6xxx_port_fdb_add(struct dsa_switch *ds, int port,
 
 	return ret;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_port_fdb_add);
 
 int mv88e6xxx_port_fdb_del(struct dsa_switch *ds, int port,
 			   const struct switchdev_obj_port_fdb *fdb)
@@ -1757,6 +1782,7 @@ int mv88e6xxx_port_fdb_del(struct dsa_switch *ds, int port,
 
 	return ret;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_port_fdb_del);
 
 static int _mv88e6xxx_atu_getnext(struct dsa_switch *ds, u16 fid,
 				  struct mv88e6xxx_atu_entry *entry)
@@ -1871,6 +1897,7 @@ unlock:
 
 	return err;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_port_fdb_dump);
 
 int mv88e6xxx_port_bridge_join(struct dsa_switch *ds, int port, u32 members)
 {
@@ -1886,6 +1913,7 @@ int mv88e6xxx_port_bridge_join(struct dsa_switch *ds, int port, u32 members)
 	mutex_unlock(&ps->smi_mutex);
 	return err;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_port_bridge_join);
 
 int mv88e6xxx_port_bridge_leave(struct dsa_switch *ds, int port, u32 members)
 {
@@ -1901,6 +1929,7 @@ int mv88e6xxx_port_bridge_leave(struct dsa_switch *ds, int port, u32 members)
 	mutex_unlock(&ps->smi_mutex);
 	return err;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_port_bridge_leave);
 
 static void mv88e6xxx_bridge_work(struct work_struct *work)
 {
@@ -2183,6 +2212,7 @@ int mv88e6xxx_setup_ports(struct dsa_switch *ds)
 	}
 	return 0;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_setup_ports);
 
 int mv88e6xxx_setup_common(struct dsa_switch *ds, struct device *dev)
 {
@@ -2207,6 +2237,7 @@ int mv88e6xxx_setup_common(struct dsa_switch *ds, struct device *dev)
 
 	return 0;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_setup_common);
 
 int mv88e6xxx_setup_global(struct dsa_switch *ds)
 {
@@ -2327,6 +2358,7 @@ unlock:
 
 	return ret;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_setup_global);
 
 int mv88e6xxx_switch_reset(struct dsa_switch *ds, bool ppu_active)
 {
@@ -2376,6 +2408,7 @@ int mv88e6xxx_switch_reset(struct dsa_switch *ds, bool ppu_active)
 
 	return 0;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_switch_reset);
 
 int mv88e6xxx_phy_page_read(struct dsa_switch *ds, int port, int page, int reg)
 {
@@ -2392,6 +2425,7 @@ error:
 	mutex_unlock(&ps->smi_mutex);
 	return ret;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_phy_page_write);
 
 int mv88e6xxx_phy_page_write(struct dsa_switch *ds, int port, int page,
 			     int reg, int val)
@@ -2410,6 +2444,7 @@ error:
 	mutex_unlock(&ps->smi_mutex);
 	return ret;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_phy_page_read);
 
 static int mv88e6xxx_port_to_phy_addr(struct dsa_switch *ds, int port)
 {
@@ -2435,6 +2470,7 @@ mv88e6xxx_phy_read(struct dsa_switch *ds, int port, int regnum)
 	mutex_unlock(&ps->smi_mutex);
 	return ret;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_phy_read);
 
 int
 mv88e6xxx_phy_write(struct dsa_switch *ds, int port, int regnum, u16 val)
@@ -2451,6 +2487,7 @@ mv88e6xxx_phy_write(struct dsa_switch *ds, int port, int regnum, u16 val)
 	mutex_unlock(&ps->smi_mutex);
 	return ret;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_phy_write);
 
 int
 mv88e6xxx_phy_read_indirect(struct dsa_switch *ds, int port, int regnum)
@@ -2467,6 +2504,7 @@ mv88e6xxx_phy_read_indirect(struct dsa_switch *ds, int port, int regnum)
 	mutex_unlock(&ps->smi_mutex);
 	return ret;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_phy_read_indirect);
 
 int
 mv88e6xxx_phy_write_indirect(struct dsa_switch *ds, int port, int regnum,
@@ -2484,6 +2522,7 @@ mv88e6xxx_phy_write_indirect(struct dsa_switch *ds, int port, int regnum,
 	mutex_unlock(&ps->smi_mutex);
 	return ret;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_phy_write_indirect);
 
 #ifdef CONFIG_NET_DSA_HWMON
 
@@ -2555,6 +2594,7 @@ int mv88e6xxx_get_temp(struct dsa_switch *ds, int *temp)
 
 	return mv88e61xx_get_temp(ds, temp);
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_get_temp);
 
 int mv88e6xxx_get_temp_limit(struct dsa_switch *ds, int *temp)
 {
@@ -2574,6 +2614,7 @@ int mv88e6xxx_get_temp_limit(struct dsa_switch *ds, int *temp)
 
 	return 0;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_get_temp_limit);
 
 int mv88e6xxx_set_temp_limit(struct dsa_switch *ds, int temp)
 {
@@ -2590,6 +2631,7 @@ int mv88e6xxx_set_temp_limit(struct dsa_switch *ds, int temp)
 	return mv88e6xxx_phy_page_write(ds, phy, 6, 26,
 					(ret & 0xe0ff) | (temp << 8));
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_set_temp_limit);
 
 int mv88e6xxx_get_temp_alarm(struct dsa_switch *ds, bool *alarm)
 {
@@ -2609,6 +2651,7 @@ int mv88e6xxx_get_temp_alarm(struct dsa_switch *ds, bool *alarm)
 
 	return 0;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_get_temp_alarm);
 #endif /* CONFIG_NET_DSA_HWMON */
 
 char *mv88e6xxx_lookup_name(struct mii_bus *bus, int sw_addr,
@@ -2639,6 +2682,7 @@ char *mv88e6xxx_lookup_name(struct mii_bus *bus, int sw_addr,
 
 	return NULL;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_lookup_name);
 
 int mv88e6xxx_bind(struct device *dev,
 		   struct dsa_switch_tree *dst,
@@ -2679,6 +2723,7 @@ int mv88e6xxx_bind(struct device *dev,
 
 	return 0;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_bind);
 
 void mv88e6xxx_unbind(struct device *dev, struct device *master, void *data)
 {
@@ -2688,41 +2733,7 @@ void mv88e6xxx_unbind(struct device *dev, struct device *master, void *data)
 	dsa_switch_unregister(ds);
 	put_device(&ps->bus->dev);
 }
-
-static int __init mv88e6xxx_init(void)
-{
-#if IS_ENABLED(CONFIG_NET_DSA_MV88E6131)
-	register_switch_driver(&mv88e6131_switch_driver);
-#endif
-#if IS_ENABLED(CONFIG_NET_DSA_MV88E6123)
-	register_switch_driver(&mv88e6123_switch_driver);
-#endif
-#if IS_ENABLED(CONFIG_NET_DSA_MV88E6352)
-	register_switch_driver(&mv88e6352_switch_driver);
-#endif
-#if IS_ENABLED(CONFIG_NET_DSA_MV88E6171)
-	register_switch_driver(&mv88e6171_switch_driver);
-#endif
-	return 0;
-}
-module_init(mv88e6xxx_init);
-
-static void __exit mv88e6xxx_cleanup(void)
-{
-#if IS_ENABLED(CONFIG_NET_DSA_MV88E6171)
-	unregister_switch_driver(&mv88e6171_switch_driver);
-#endif
-#if IS_ENABLED(CONFIG_NET_DSA_MV88E6352)
-	unregister_switch_driver(&mv88e6352_switch_driver);
-#endif
-#if IS_ENABLED(CONFIG_NET_DSA_MV88E6123_61_65)
-	unregister_switch_driver(&mv88e6123_61_65_switch_driver);
-#endif
-#if IS_ENABLED(CONFIG_NET_DSA_MV88E6131)
-	unregister_switch_driver(&mv88e6131_switch_driver);
-#endif
-}
-module_exit(mv88e6xxx_cleanup);
+EXPORT_SYMBOL_GPL(mv88e6xxx_unbind);
 
 MODULE_AUTHOR("Lennert Buytenhek <buytenh@wantstofly.org>");
 MODULE_DESCRIPTION("Driver for Marvell 88E6XXX ethernet switch chips");
-- 
2.6.3
