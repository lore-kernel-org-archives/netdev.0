From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH RFC v2 18/32] dsa: mv88e6xxx: Prepare for turning this into a library module
Date: Sun, 28 Feb 2016 17:41:26 +0100
Message-ID: <1456677700-23027-19-git-send-email-andrew@lunn.ch>
References: <1456677700-23027-1-git-send-email-andrew@lunn.ch>
Cc: Andrew Lunn <andrew@lunn.ch>
To: Florian Fainelli <f.fainelli@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:44905 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759177AbcB1QmE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Feb 2016 11:42:04 -0500
In-Reply-To: <1456677700-23027-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Export all the functions so that we can later turn the module into a
library module.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx.c | 46 +++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 46 insertions(+)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 4a4af245b0eb..b0838bf77fd9 100644
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
@@ -742,6 +750,7 @@ void mv88e6xxx_get_strings(struct dsa_switch *ds, int port, uint8_t *data)
 		}
 	}
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_get_strings);
 
 int mv88e6xxx_get_sset_count(struct dsa_switch *ds)
 {
@@ -755,6 +764,7 @@ int mv88e6xxx_get_sset_count(struct dsa_switch *ds)
 	}
 	return j;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_get_sset_count);
 
 void
 mv88e6xxx_get_ethtool_stats(struct dsa_switch *ds,
@@ -782,11 +792,13 @@ mv88e6xxx_get_ethtool_stats(struct dsa_switch *ds,
 
 	mutex_unlock(&ps->smi_mutex);
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_get_ethtool_stats);
 
 int mv88e6xxx_get_regs_len(struct dsa_switch *ds, int port)
 {
 	return 32 * sizeof(u16);
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_get_regs_len);
 
 void mv88e6xxx_get_regs(struct dsa_switch *ds, int port,
 			struct ethtool_regs *regs, void *_p)
@@ -806,6 +818,7 @@ void mv88e6xxx_get_regs(struct dsa_switch *ds, int port,
 			p[i] = ret;
 	}
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_get_regs);
 
 static int _mv88e6xxx_wait(struct dsa_switch *ds, int reg, int offset,
 			   u16 mask)
@@ -849,12 +862,14 @@ int mv88e6xxx_eeprom_load_wait(struct dsa_switch *ds)
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
@@ -921,6 +936,7 @@ out:
 	mutex_unlock(&ps->smi_mutex);
 	return reg;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_get_eee);
 
 int mv88e6xxx_set_eee(struct dsa_switch *ds, int port,
 		      struct phy_device *phydev, struct ethtool_eee *e)
@@ -947,6 +963,7 @@ out:
 
 	return ret;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_set_eee);
 
 static int _mv88e6xxx_atu_cmd(struct dsa_switch *ds, u16 cmd)
 {
@@ -1134,6 +1151,7 @@ int mv88e6xxx_port_stp_update(struct dsa_switch *ds, int port, u8 state)
 
 	return 0;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_port_stp_update);
 
 static int _mv88e6xxx_port_pvid_get(struct dsa_switch *ds, int port, u16 *pvid)
 {
@@ -1160,6 +1178,7 @@ int mv88e6xxx_port_pvid_get(struct dsa_switch *ds, int port, u16 *pvid)
 
 	return 0;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_port_pvid_get);
 
 static int _mv88e6xxx_port_pvid_set(struct dsa_switch *ds, int port, u16 pvid)
 {
@@ -1481,6 +1500,7 @@ int mv88e6xxx_port_vlan_prepare(struct dsa_switch *ds, int port,
 	 */
 	return 0;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_port_vlan_prepare);
 
 static int _mv88e6xxx_port_vlan_add(struct dsa_switch *ds, int port, u16 vid,
 				    bool untagged)
@@ -1535,6 +1555,7 @@ unlock:
 
 	return err;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_port_vlan_add);
 
 static int _mv88e6xxx_port_vlan_del(struct dsa_switch *ds, int port, u16 vid)
 {
@@ -1605,6 +1626,7 @@ unlock:
 
 	return err;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_port_vlan_del);
 
 int mv88e6xxx_vlan_getnext(struct dsa_switch *ds, u16 *vid,
 			   unsigned long *ports, unsigned long *untagged)
@@ -1651,6 +1673,7 @@ unlock:
 
 	return 0;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_vlan_getnext);
 
 static int _mv88e6xxx_atu_mac_write(struct dsa_switch *ds,
 				    const unsigned char *addr)
@@ -1738,6 +1761,7 @@ int mv88e6xxx_port_fdb_prepare(struct dsa_switch *ds, int port,
 	 */
 	return 0;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_port_fdb_prepare);
 
 int mv88e6xxx_port_fdb_add(struct dsa_switch *ds, int port,
 			   const struct switchdev_obj_port_fdb *fdb,
@@ -1755,6 +1779,7 @@ int mv88e6xxx_port_fdb_add(struct dsa_switch *ds, int port,
 
 	return ret;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_port_fdb_add);
 
 int mv88e6xxx_port_fdb_del(struct dsa_switch *ds, int port,
 			   const struct switchdev_obj_port_fdb *fdb)
@@ -1769,6 +1794,7 @@ int mv88e6xxx_port_fdb_del(struct dsa_switch *ds, int port,
 
 	return ret;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_port_fdb_del);
 
 static int _mv88e6xxx_atu_getnext(struct dsa_switch *ds, u16 fid,
 				  struct mv88e6xxx_atu_entry *entry)
@@ -1883,6 +1909,7 @@ unlock:
 
 	return err;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_port_fdb_dump);
 
 int mv88e6xxx_port_bridge_join(struct dsa_switch *ds, int port, u32 members)
 {
@@ -1898,6 +1925,7 @@ int mv88e6xxx_port_bridge_join(struct dsa_switch *ds, int port, u32 members)
 	mutex_unlock(&ps->smi_mutex);
 	return err;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_port_bridge_join);
 
 int mv88e6xxx_port_bridge_leave(struct dsa_switch *ds, int port, u32 members)
 {
@@ -1913,6 +1941,7 @@ int mv88e6xxx_port_bridge_leave(struct dsa_switch *ds, int port, u32 members)
 	mutex_unlock(&ps->smi_mutex);
 	return err;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_port_bridge_leave);
 
 static void mv88e6xxx_bridge_work(struct work_struct *work)
 {
@@ -2196,6 +2225,7 @@ int mv88e6xxx_setup_ports(struct dsa_switch *ds)
 	}
 	return 0;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_setup_ports);
 
 int mv88e6xxx_setup_common(struct dsa_switch *ds, struct device *dev)
 {
@@ -2224,6 +2254,7 @@ int mv88e6xxx_setup_common(struct dsa_switch *ds, struct device *dev)
 
 	return 0;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_setup_common);
 
 int mv88e6xxx_setup_global(struct dsa_switch *ds)
 {
@@ -2344,6 +2375,7 @@ unlock:
 
 	return ret;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_setup_global);
 
 int mv88e6xxx_switch_reset(struct dsa_switch *ds, bool ppu_active)
 {
@@ -2393,6 +2425,7 @@ int mv88e6xxx_switch_reset(struct dsa_switch *ds, bool ppu_active)
 
 	return 0;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_switch_reset);
 
 int mv88e6xxx_phy_page_read(struct dsa_switch *ds, int port, int page, int reg)
 {
@@ -2409,6 +2442,7 @@ error:
 	mutex_unlock(&ps->smi_mutex);
 	return ret;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_phy_page_write);
 
 int mv88e6xxx_phy_page_write(struct dsa_switch *ds, int port, int page,
 			     int reg, int val)
@@ -2427,6 +2461,7 @@ error:
 	mutex_unlock(&ps->smi_mutex);
 	return ret;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_phy_page_read);
 
 static int mv88e6xxx_port_to_phy_addr(struct dsa_switch *ds, int port)
 {
@@ -2452,6 +2487,7 @@ mv88e6xxx_phy_read(struct dsa_switch *ds, int port, int regnum)
 	mutex_unlock(&ps->smi_mutex);
 	return ret;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_phy_read);
 
 int
 mv88e6xxx_phy_write(struct dsa_switch *ds, int port, int regnum, u16 val)
@@ -2468,6 +2504,7 @@ mv88e6xxx_phy_write(struct dsa_switch *ds, int port, int regnum, u16 val)
 	mutex_unlock(&ps->smi_mutex);
 	return ret;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_phy_write);
 
 int
 mv88e6xxx_phy_read_indirect(struct dsa_switch *ds, int port, int regnum)
@@ -2484,6 +2521,7 @@ mv88e6xxx_phy_read_indirect(struct dsa_switch *ds, int port, int regnum)
 	mutex_unlock(&ps->smi_mutex);
 	return ret;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_phy_read_indirect);
 
 int
 mv88e6xxx_phy_write_indirect(struct dsa_switch *ds, int port, int regnum,
@@ -2501,6 +2539,7 @@ mv88e6xxx_phy_write_indirect(struct dsa_switch *ds, int port, int regnum,
 	mutex_unlock(&ps->smi_mutex);
 	return ret;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_phy_write_indirect);
 
 #ifdef CONFIG_NET_DSA_HWMON
 
@@ -2572,6 +2611,7 @@ int mv88e6xxx_get_temp(struct dsa_switch *ds, int *temp)
 
 	return mv88e61xx_get_temp(ds, temp);
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_get_temp);
 
 int mv88e6xxx_get_temp_limit(struct dsa_switch *ds, int *temp)
 {
@@ -2591,6 +2631,7 @@ int mv88e6xxx_get_temp_limit(struct dsa_switch *ds, int *temp)
 
 	return 0;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_get_temp_limit);
 
 int mv88e6xxx_set_temp_limit(struct dsa_switch *ds, int temp)
 {
@@ -2607,6 +2648,7 @@ int mv88e6xxx_set_temp_limit(struct dsa_switch *ds, int temp)
 	return mv88e6xxx_phy_page_write(ds, phy, 6, 26,
 					(ret & 0xe0ff) | (temp << 8));
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_set_temp_limit);
 
 int mv88e6xxx_get_temp_alarm(struct dsa_switch *ds, bool *alarm)
 {
@@ -2626,6 +2668,7 @@ int mv88e6xxx_get_temp_alarm(struct dsa_switch *ds, bool *alarm)
 
 	return 0;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_get_temp_alarm);
 #endif /* CONFIG_NET_DSA_HWMON */
 
 char *mv88e6xxx_lookup_name(struct mii_bus *bus, int sw_addr,
@@ -2659,6 +2702,7 @@ char *mv88e6xxx_lookup_name(struct mii_bus *bus, int sw_addr,
 
 	return NULL;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_lookup_name);
 
 int mv88e6xxx_bind(struct device *dev,
 		   struct dsa_switch_tree *dst,
@@ -2697,6 +2741,7 @@ int mv88e6xxx_bind(struct device *dev,
 
 	return 0;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_bind);
 
 void mv88e6xxx_unbind(struct device *dev, struct device *master, void *data)
 {
@@ -2708,6 +2753,7 @@ void mv88e6xxx_unbind(struct device *dev, struct device *master, void *data)
 
 	put_device(&ps->bus->dev);
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_unbind);
 
 static int __init mv88e6xxx_init(void)
 {
-- 
2.7.0
