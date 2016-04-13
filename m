From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 1/8] dsa: mv88e6xxx: Prepare for turning this into a library module
Date: Thu, 14 Apr 2016 01:59:51 +0200
Message-ID: <1460591998-20598-2-git-send-email-andrew@lunn.ch>
References: <1460591998-20598-1-git-send-email-andrew@lunn.ch>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:55205 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932080AbcDNAC0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Apr 2016 20:02:26 -0400
In-Reply-To: <1460591998-20598-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Export all the functions so that we can later turn the module into a
library module.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx.c | 44 ++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 44 insertions(+)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 9985a0cf31f1..9b568f39aaf0 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -120,6 +120,7 @@ int mv88e6xxx_reg_read(struct dsa_switch *ds, int addr, int reg)
 
 	return ret;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_reg_read);
 
 static int __mv88e6xxx_reg_write(struct mii_bus *bus, int sw_addr, int addr,
 				 int reg, u16 val)
@@ -177,6 +178,7 @@ int mv88e6xxx_reg_write(struct dsa_switch *ds, int addr, int reg, u16 val)
 
 	return ret;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_reg_write);
 
 int mv88e6xxx_set_addr_direct(struct dsa_switch *ds, u8 *addr)
 {
@@ -186,6 +188,7 @@ int mv88e6xxx_set_addr_direct(struct dsa_switch *ds, u8 *addr)
 
 	return 0;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_set_addr_direct);
 
 int mv88e6xxx_set_addr_indirect(struct dsa_switch *ds, u8 *addr)
 {
@@ -211,6 +214,7 @@ int mv88e6xxx_set_addr_indirect(struct dsa_switch *ds, u8 *addr)
 
 	return 0;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_set_addr_indirect);
 
 static int _mv88e6xxx_phy_read(struct dsa_switch *ds, int addr, int regnum)
 {
@@ -336,6 +340,7 @@ void mv88e6xxx_ppu_state_init(struct dsa_switch *ds)
 	ps->ppu_timer.data = (unsigned long)ps;
 	ps->ppu_timer.function = mv88e6xxx_ppu_reenable_timer;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_ppu_state_init);
 
 int mv88e6xxx_phy_read_ppu(struct dsa_switch *ds, int addr, int regnum)
 {
@@ -349,6 +354,7 @@ int mv88e6xxx_phy_read_ppu(struct dsa_switch *ds, int addr, int regnum)
 
 	return ret;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_phy_read_ppu);
 
 int mv88e6xxx_phy_write_ppu(struct dsa_switch *ds, int addr,
 			    int regnum, u16 val)
@@ -363,6 +369,7 @@ int mv88e6xxx_phy_write_ppu(struct dsa_switch *ds, int addr,
 
 	return ret;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_phy_write_ppu);
 #endif
 
 static bool mv88e6xxx_6065_family(struct dsa_switch *ds)
@@ -587,6 +594,7 @@ void mv88e6xxx_adjust_link(struct dsa_switch *ds, int port,
 out:
 	mutex_unlock(&ps->smi_mutex);
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_adjust_link);
 
 static int _mv88e6xxx_stats_wait(struct dsa_switch *ds)
 {
@@ -783,6 +791,7 @@ void mv88e6xxx_get_strings(struct dsa_switch *ds, int port, uint8_t *data)
 		}
 	}
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_get_strings);
 
 int mv88e6xxx_get_sset_count(struct dsa_switch *ds)
 {
@@ -796,6 +805,7 @@ int mv88e6xxx_get_sset_count(struct dsa_switch *ds)
 	}
 	return j;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_get_sset_count);
 
 void
 mv88e6xxx_get_ethtool_stats(struct dsa_switch *ds,
@@ -823,11 +833,13 @@ mv88e6xxx_get_ethtool_stats(struct dsa_switch *ds,
 
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
@@ -847,6 +859,7 @@ void mv88e6xxx_get_regs(struct dsa_switch *ds, int port,
 			p[i] = ret;
 	}
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_get_regs);
 
 static int _mv88e6xxx_wait(struct dsa_switch *ds, int reg, int offset,
 			   u16 mask)
@@ -890,12 +903,14 @@ int mv88e6xxx_eeprom_load_wait(struct dsa_switch *ds)
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
@@ -962,6 +977,7 @@ out:
 	mutex_unlock(&ps->smi_mutex);
 	return reg;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_get_eee);
 
 int mv88e6xxx_set_eee(struct dsa_switch *ds, int port,
 		      struct phy_device *phydev, struct ethtool_eee *e)
@@ -988,6 +1004,7 @@ out:
 
 	return ret;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_set_eee);
 
 static int _mv88e6xxx_atu_cmd(struct dsa_switch *ds, u16 fid, u16 cmd)
 {
@@ -1216,6 +1233,7 @@ void mv88e6xxx_port_stp_state_set(struct dsa_switch *ds, int port, u8 state)
 	set_bit(port, ps->port_state_update_mask);
 	schedule_work(&ps->bridge_work);
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_port_stp_state_set);
 
 static int _mv88e6xxx_port_pvid(struct dsa_switch *ds, int port, u16 *new,
 				u16 *old)
@@ -1456,6 +1474,7 @@ unlock:
 
 	return err;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_port_vlan_dump);
 
 static int _mv88e6xxx_vtu_loadpurge(struct dsa_switch *ds,
 				    struct mv88e6xxx_vtu_stu_entry *entry)
@@ -1864,6 +1883,7 @@ unlock:
 
 	return ret;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_port_vlan_filtering);
 
 int mv88e6xxx_port_vlan_prepare(struct dsa_switch *ds, int port,
 				const struct switchdev_obj_port_vlan *vlan,
@@ -1884,6 +1904,7 @@ int mv88e6xxx_port_vlan_prepare(struct dsa_switch *ds, int port,
 	 */
 	return 0;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_port_vlan_prepare);
 
 static int _mv88e6xxx_port_vlan_add(struct dsa_switch *ds, int port, u16 vid,
 				    bool untagged)
@@ -1924,6 +1945,7 @@ void mv88e6xxx_port_vlan_add(struct dsa_switch *ds, int port,
 
 	mutex_unlock(&ps->smi_mutex);
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_port_vlan_add);
 
 static int _mv88e6xxx_port_vlan_del(struct dsa_switch *ds, int port, u16 vid)
 {
@@ -1990,6 +2012,7 @@ unlock:
 
 	return err;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_port_vlan_del);
 
 static int _mv88e6xxx_atu_mac_write(struct dsa_switch *ds,
 				    const unsigned char *addr)
@@ -2079,6 +2102,7 @@ int mv88e6xxx_port_fdb_prepare(struct dsa_switch *ds, int port,
 	 */
 	return 0;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_port_fdb_prepare);
 
 void mv88e6xxx_port_fdb_add(struct dsa_switch *ds, int port,
 			    const struct switchdev_obj_port_fdb *fdb,
@@ -2094,6 +2118,7 @@ void mv88e6xxx_port_fdb_add(struct dsa_switch *ds, int port,
 		netdev_err(ds->ports[port], "failed to load MAC address\n");
 	mutex_unlock(&ps->smi_mutex);
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_port_fdb_add);
 
 int mv88e6xxx_port_fdb_del(struct dsa_switch *ds, int port,
 			   const struct switchdev_obj_port_fdb *fdb)
@@ -2108,6 +2133,7 @@ int mv88e6xxx_port_fdb_del(struct dsa_switch *ds, int port,
 
 	return ret;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_port_fdb_del);
 
 static int _mv88e6xxx_atu_getnext(struct dsa_switch *ds, u16 fid,
 				  struct mv88e6xxx_atu_entry *entry)
@@ -2241,6 +2267,7 @@ unlock:
 
 	return err;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_port_fdb_dump);
 
 int mv88e6xxx_port_bridge_join(struct dsa_switch *ds, int port,
 			       struct net_device *bridge)
@@ -2283,6 +2310,7 @@ unlock:
 
 	return err;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_port_bridge_join);
 
 void mv88e6xxx_port_bridge_leave(struct dsa_switch *ds, int port)
 {
@@ -2308,6 +2336,7 @@ void mv88e6xxx_port_bridge_leave(struct dsa_switch *ds, int port)
 
 	mutex_unlock(&ps->smi_mutex);
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_port_bridge_leave);
 
 static void mv88e6xxx_bridge_work(struct work_struct *work)
 {
@@ -2659,6 +2688,7 @@ int mv88e6xxx_setup_ports(struct dsa_switch *ds)
 	}
 	return 0;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_setup_ports);
 
 int mv88e6xxx_setup_common(struct dsa_switch *ds)
 {
@@ -2673,6 +2703,7 @@ int mv88e6xxx_setup_common(struct dsa_switch *ds)
 
 	return 0;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_setup_common);
 
 int mv88e6xxx_setup_global(struct dsa_switch *ds)
 {
@@ -2793,6 +2824,7 @@ unlock:
 
 	return ret;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_setup_global);
 
 int mv88e6xxx_switch_reset(struct dsa_switch *ds, bool ppu_active)
 {
@@ -2842,6 +2874,7 @@ int mv88e6xxx_switch_reset(struct dsa_switch *ds, bool ppu_active)
 
 	return 0;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_switch_reset);
 
 int mv88e6xxx_phy_page_read(struct dsa_switch *ds, int port, int page, int reg)
 {
@@ -2854,6 +2887,7 @@ int mv88e6xxx_phy_page_read(struct dsa_switch *ds, int port, int page, int reg)
 
 	return ret;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_phy_page_read);
 
 int mv88e6xxx_phy_page_write(struct dsa_switch *ds, int port, int page,
 			     int reg, int val)
@@ -2867,6 +2901,7 @@ int mv88e6xxx_phy_page_write(struct dsa_switch *ds, int port, int page,
 
 	return ret;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_phy_page_write);
 
 static int mv88e6xxx_port_to_phy_addr(struct dsa_switch *ds, int port)
 {
@@ -2892,6 +2927,7 @@ mv88e6xxx_phy_read(struct dsa_switch *ds, int port, int regnum)
 	mutex_unlock(&ps->smi_mutex);
 	return ret;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_phy_read);
 
 int
 mv88e6xxx_phy_write(struct dsa_switch *ds, int port, int regnum, u16 val)
@@ -2908,6 +2944,7 @@ mv88e6xxx_phy_write(struct dsa_switch *ds, int port, int regnum, u16 val)
 	mutex_unlock(&ps->smi_mutex);
 	return ret;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_phy_write);
 
 int
 mv88e6xxx_phy_read_indirect(struct dsa_switch *ds, int port, int regnum)
@@ -2924,6 +2961,7 @@ mv88e6xxx_phy_read_indirect(struct dsa_switch *ds, int port, int regnum)
 	mutex_unlock(&ps->smi_mutex);
 	return ret;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_phy_read_indirect);
 
 int
 mv88e6xxx_phy_write_indirect(struct dsa_switch *ds, int port, int regnum,
@@ -2941,6 +2979,7 @@ mv88e6xxx_phy_write_indirect(struct dsa_switch *ds, int port, int regnum,
 	mutex_unlock(&ps->smi_mutex);
 	return ret;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_phy_write_indirect);
 
 #ifdef CONFIG_NET_DSA_HWMON
 
@@ -3012,6 +3051,7 @@ int mv88e6xxx_get_temp(struct dsa_switch *ds, int *temp)
 
 	return mv88e61xx_get_temp(ds, temp);
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_get_temp);
 
 int mv88e6xxx_get_temp_limit(struct dsa_switch *ds, int *temp)
 {
@@ -3031,6 +3071,7 @@ int mv88e6xxx_get_temp_limit(struct dsa_switch *ds, int *temp)
 
 	return 0;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_get_temp_limit);
 
 int mv88e6xxx_set_temp_limit(struct dsa_switch *ds, int temp)
 {
@@ -3047,6 +3088,7 @@ int mv88e6xxx_set_temp_limit(struct dsa_switch *ds, int temp)
 	return mv88e6xxx_phy_page_write(ds, phy, 6, 26,
 					(ret & 0xe0ff) | (temp << 8));
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_set_temp_limit);
 
 int mv88e6xxx_get_temp_alarm(struct dsa_switch *ds, bool *alarm)
 {
@@ -3066,6 +3108,7 @@ int mv88e6xxx_get_temp_alarm(struct dsa_switch *ds, bool *alarm)
 
 	return 0;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_get_temp_alarm);
 #endif /* CONFIG_NET_DSA_HWMON */
 
 static char *mv88e6xxx_lookup_name(struct mii_bus *bus, int sw_addr,
@@ -3125,6 +3168,7 @@ char *mv88e6xxx_drv_probe(struct device *dsa_dev, struct device *host_dev,
 	}
 	return name;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_drv_probe);
 
 static int __init mv88e6xxx_init(void)
 {
-- 
2.7.0
