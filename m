From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next] drivers/net: Remove unnecessary returns from void
 function()s
Date: Tue, 11 May 2010 12:30:24 -0700
Message-ID: <1273606224.20514.295.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:2151 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752669Ab0EKTa1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 May 2010 15:30:27 -0400
Received: from [192.168.1.151] (new-host-5.home [192.168.1.151])
	by mail.perches.com (Postfix) with ESMTP id 64DEE24368
	for <netdev@vger.kernel.org>; Tue, 11 May 2010 12:30:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes from drivers/net/ all the unnecessary
return; statements that precede the last closing brace of
void functions.

It does not remove the returns that are immediately
preceded by a label as gcc doesn't like that.

Done via:
$ grep -rP --include=*.[ch] -l "return;\n}" net/ | \
  xargs perl -i -e 'local $/ ; while (<>) { s/\n[ \t\n]+return;\n}/\n}/g; print; }'

with some cleanups by hand.

Compile tested x86 allmodconfig only.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/3c501.c                           |    1 -
 drivers/net/3c503.c                           |    2 -
 drivers/net/3c507.c                           |    1 -
 drivers/net/3c509.c                           |    1 -
 drivers/net/3c515.c                           |    2 -
 drivers/net/3c59x.c                           |    3 -
 drivers/net/7990.c                            |    1 -
 drivers/net/8139cp.c                          |    2 -
 drivers/net/a2065.c                           |    1 -
 drivers/net/ac3200.c                          |    2 -
 drivers/net/acenic.c                          |    2 -
 drivers/net/apne.c                            |    1 -
 drivers/net/appletalk/cops.c                  |    4 --
 drivers/net/appletalk/ltpc.c                  |    1 -
 drivers/net/at1700.c                          |    2 -
 drivers/net/atl1c/atl1c_ethtool.c             |    2 -
 drivers/net/atl1c/atl1c_main.c                |    2 -
 drivers/net/atl1e/atl1e_ethtool.c             |    2 -
 drivers/net/atl1e/atl1e_main.c                |    7 ---
 drivers/net/atlx/atl1.c                       |    3 -
 drivers/net/atp.c                             |    1 -
 drivers/net/ax88796.c                         |    1 -
 drivers/net/benet/be_ethtool.c                |    3 -
 drivers/net/benet/be_main.c                   |   12 ----
 drivers/net/bfin_mac.c                        |    2 -
 drivers/net/bmac.c                            |    3 -
 drivers/net/bonding/bonding.h                 |    3 -
 drivers/net/can/usb/ems_usb.c                 |    4 --
 drivers/net/cnic.c                            |    3 -
 drivers/net/cs89x0.c                          |    2 -
 drivers/net/cxgb3/l2t.c                       |    1 -
 drivers/net/declance.c                        |    1 -
 drivers/net/depca.c                           |    6 --
 drivers/net/dl2k.c                            |    2 -
 drivers/net/e1000/e1000_ethtool.c             |    4 --
 drivers/net/e1000/e1000_main.c                |    2 -
 drivers/net/e1000e/82571.c                    |    4 --
 drivers/net/e1000e/es2lan.c                   |    2 -
 drivers/net/e1000e/ich8lan.c                  |   10 ----
 drivers/net/e1000e/netdev.c                   |    4 --
 drivers/net/e2100.c                           |    1 -
 drivers/net/eexpress.c                        |    1 -
 drivers/net/ehea/ehea_main.c                  |    5 --
 drivers/net/epic100.c                         |    4 --
 drivers/net/es3210.c                          |    2 -
 drivers/net/ewrk3.c                           |    2 -
 drivers/net/gianfar.c                         |    4 --
 drivers/net/hamachi.c                         |    3 -
 drivers/net/hamradio/scc.c                    |    1 -
 drivers/net/hp-plus.c                         |    4 --
 drivers/net/hp.c                              |    3 -
 drivers/net/ibmveth.c                         |    1 -
 drivers/net/igb/e1000_82575.c                 |    2 -
 drivers/net/igb/igb_main.c                    |    3 -
 drivers/net/igbvf/ethtool.c                   |    3 -
 drivers/net/irda/mcs7780.c                    |    4 --
 drivers/net/irda/smsc-ircc2.c                 |    1 -
 drivers/net/ixgb/ixgb_ee.c                    |   10 ----
 drivers/net/ixgb/ixgb_hw.c                    |   17 ------
 drivers/net/ixgbe/ixgbe_dcb_nl.c              |    1 -
 drivers/net/ixgbe/ixgbe_ethtool.c             |    4 --
 drivers/net/ixgbe/ixgbe_main.c                |    5 --
 drivers/net/ixgbevf/ixgbevf_main.c            |    4 --
 drivers/net/jme.c                             |    4 --
 drivers/net/lib8390.c                         |    1 -
 drivers/net/lne390.c                          |    2 -
 drivers/net/mac8390.c                         |    2 -
 drivers/net/meth.c                            |    2 -
 drivers/net/mlx4/en_cq.c                      |    1 -
 drivers/net/mlx4/en_ethtool.c                 |    2 -
 drivers/net/mlx4/en_resources.c               |    1 -
 drivers/net/ne-h8300.c                        |    1 -
 drivers/net/ne.c                              |    1 -
 drivers/net/ne2.c                             |    1 -
 drivers/net/ne2k-pci.c                        |    1 -
 drivers/net/ne3210.c                          |    2 -
 drivers/net/netxen/netxen_nic_init.c          |    1 -
 drivers/net/netxen/netxen_nic_main.c          |    1 -
 drivers/net/ni5010.c                          |    2 -
 drivers/net/octeon/octeon_mgmt.c              |    1 -
 drivers/net/pasemi_mac.c                      |    2 -
 drivers/net/pcmcia/3c574_cs.c                 |    2 -
 drivers/net/pcmcia/axnet_cs.c                 |    2 -
 drivers/net/pcmcia/fmvj18x_cs.c               |    2 -
 drivers/net/pcmcia/ibmtr_cs.c                 |    2 -
 drivers/net/pcmcia/nmclan_cs.c                |    2 -
 drivers/net/pcmcia/smc91c92_cs.c              |    6 --
 drivers/net/pcnet32.c                         |    3 -
 drivers/net/phy/national.c                    |    3 -
 drivers/net/plip.c                            |    3 -
 drivers/net/ppp_mppe.c                        |    1 -
 drivers/net/ps3_gelic_wireless.c              |    1 -
 drivers/net/qla3xxx.c                         |    6 --
 drivers/net/qlcnic/qlcnic_main.c              |    2 -
 drivers/net/qlge/qlge_ethtool.c               |    2 -
 drivers/net/s2io.c                            |    3 -
 drivers/net/sb1000.c                          |    5 --
 drivers/net/seeq8005.c                        |    1 -
 drivers/net/sis900.c                          |    7 ---
 drivers/net/skfp/skfddi.c                     |    2 -
 drivers/net/slhc.c                            |    1 -
 drivers/net/smc-mca.c                         |    1 -
 drivers/net/smc-ultra.c                       |    1 -
 drivers/net/smc-ultra32.c                     |    1 -
 drivers/net/smc9194.c                         |    3 -
 drivers/net/spider_net.c                      |    2 -
 drivers/net/starfire.c                        |    2 -
 drivers/net/stmmac/dwmac1000_core.c           |    8 ---
 drivers/net/stmmac/dwmac1000_dma.c            |    3 -
 drivers/net/stmmac/dwmac100_core.c            |    7 ---
 drivers/net/stmmac/dwmac100_dma.c             |    4 --
 drivers/net/stmmac/dwmac_lib.c                |   12 ----
 drivers/net/stmmac/enh_desc.c                 |    5 --
 drivers/net/stmmac/norm_desc.c                |    4 --
 drivers/net/stmmac/stmmac_ethtool.c           |    7 ---
 drivers/net/stmmac/stmmac_main.c              |   22 --------
 drivers/net/stmmac/stmmac_timer.c             |    6 --
 drivers/net/stnic.c                           |    1 -
 drivers/net/sundance.c                        |    5 --
 drivers/net/sungem.c                          |    1 -
 drivers/net/sunhme.c                          |    1 -
 drivers/net/tokenring/madgemc.c               |   12 ----
 drivers/net/tokenring/smctr.c                 |    2 -
 drivers/net/tokenring/tms380tr.c              |   47 -----------------
 drivers/net/tulip/de4x5.c                     |   68 -------------------------
 drivers/net/tulip/dmfe.c                      |    1 -
 drivers/net/tulip/media.c                     |    2 -
 drivers/net/tulip/winbond-840.c               |    2 -
 drivers/net/tun.c                             |    1 -
 drivers/net/usb/hso.c                         |    2 -
 drivers/net/vxge/vxge-config.c                |   17 ------
 drivers/net/vxge/vxge-main.c                  |    4 --
 drivers/net/vxge/vxge-traffic.c               |   28 ----------
 drivers/net/wd.c                              |    1 -
 drivers/net/wimax/i2400m/control.c            |    2 -
 drivers/net/wimax/i2400m/driver.c             |    2 -
 drivers/net/wimax/i2400m/netdev.c             |    2 -
 drivers/net/wimax/i2400m/rx.c                 |    7 ---
 drivers/net/wimax/i2400m/sdio-rx.c            |    2 -
 drivers/net/wimax/i2400m/usb-notif.c          |    1 -
 drivers/net/wireless/at76c50x-usb.c           |    1 -
 drivers/net/wireless/ath/ath5k/phy.c          |    2 -
 drivers/net/wireless/ath/ath5k/reset.c        |    3 -
 drivers/net/wireless/ath/ath9k/ar9003_calib.c |    1 -
 drivers/net/wireless/ath/ath9k/calib.c        |    1 -
 drivers/net/wireless/ath/ath9k/common.c       |    1 -
 drivers/net/wireless/ath/ath9k/eeprom.c       |    2 -
 drivers/net/wireless/ath/ath9k/eeprom_def.c   |    3 -
 drivers/net/wireless/ath/ath9k/htc_drv_txrx.c |    1 -
 drivers/net/wireless/ath/ath9k/hw.c           |    1 -
 drivers/net/wireless/ath/ath9k/rc.c           |    1 -
 drivers/net/wireless/ath/regd.c               |    1 -
 drivers/net/wireless/ipw2x00/ipw2100.c        |    1 -
 drivers/net/wireless/ipw2x00/ipw2200.c        |    2 -
 drivers/net/wireless/ipw2x00/libipw_rx.c      |    1 -
 drivers/net/wireless/iwlwifi/iwl-3945-rs.c    |    3 -
 drivers/net/wireless/iwlwifi/iwl-3945.c       |    1 -
 drivers/net/wireless/iwlwifi/iwl-agn-rs.c     |    3 -
 drivers/net/wireless/iwlwifi/iwl-agn.c        |    1 -
 drivers/net/wireless/iwlwifi/iwl-calib.c      |    2 -
 drivers/net/wireless/iwlwifi/iwl-core.c       |    1 -
 drivers/net/wireless/iwlwifi/iwl3945-base.c   |    1 -
 drivers/net/wireless/iwmc3200wifi/sdio.c      |    2 -
 drivers/net/wireless/libertas/debugfs.c       |    3 -
 drivers/net/wireless/libertas/if_usb.c        |    4 --
 drivers/net/wireless/libertas/rx.c            |    1 -
 drivers/net/wireless/libertas_tf/if_usb.c     |    1 -
 drivers/net/wireless/libertas_tf/main.c       |    1 -
 drivers/net/wireless/orinoco/main.c           |    2 -
 drivers/net/wireless/p54/p54usb.c             |    1 -
 drivers/net/wireless/prism54/isl_ioctl.c      |    2 -
 drivers/net/wireless/ray_cs.c                 |    5 --
 drivers/net/wireless/rndis_wlan.c             |    1 -
 drivers/net/wireless/rt2x00/rt2x00debug.c     |    2 -
 drivers/net/wireless/wl12xx/wl1251_rx.c       |    2 -
 drivers/net/wireless/wl3501_cs.c              |    2 -
 drivers/net/wireless/zd1201.c                 |    3 -
 drivers/net/yellowfin.c                       |    1 -
 drivers/net/znet.c                            |    1 -
 drivers/net/zorro8390.c                       |    1 -
 180 files changed, 0 insertions(+), 649 deletions(-)

diff --git a/drivers/net/3c501.c b/drivers/net/3c501.c
index 4fed2a8..1776ab6 100644
--- a/drivers/net/3c501.c
+++ b/drivers/net/3c501.c
@@ -726,7 +726,6 @@ static void el_receive(struct net_device *dev)
 		dev->stats.rx_packets++;
 		dev->stats.rx_bytes += pkt_len;
 	}
-	return;
 }
 
 /**
diff --git a/drivers/net/3c503.c b/drivers/net/3c503.c
index b74a0ea..baac246 100644
--- a/drivers/net/3c503.c
+++ b/drivers/net/3c503.c
@@ -573,7 +573,6 @@ el2_block_output(struct net_device *dev, int count,
     }
     blocked:;
     outb_p(ei_status.interface_num==0 ? ECNTRL_THIN : ECNTRL_AUI, E33G_CNTRL);
-    return;
 }
 
 /* Read the 4 byte, page aligned 8390 specific header. */
@@ -689,7 +688,6 @@ el2_block_input(struct net_device *dev, int count, struct sk_buff *skb, int ring
     }
     blocked:;
     outb_p(ei_status.interface_num == 0 ? ECNTRL_THIN : ECNTRL_AUI, E33G_CNTRL);
-    return;
 }
 
 
diff --git a/drivers/net/3c507.c b/drivers/net/3c507.c
index c4e272f..82eaf65 100644
--- a/drivers/net/3c507.c
+++ b/drivers/net/3c507.c
@@ -764,7 +764,6 @@ static void init_82586_mem(struct net_device *dev)
 	if (net_debug > 4)
 		pr_debug("%s: Initialized 82586, status %04x.\n", dev->name,
 			   readw(shmem+iSCB_STATUS));
-	return;
 }
 
 static void hardware_send_packet(struct net_device *dev, void *buf, short length, short pad)
diff --git a/drivers/net/3c509.c b/drivers/net/3c509.c
index 54deaa9..91abb96 100644
--- a/drivers/net/3c509.c
+++ b/drivers/net/3c509.c
@@ -1037,7 +1037,6 @@ static void update_stats(struct net_device *dev)
 	/* Back to window 1, and turn statistics back on. */
 	EL3WINDOW(1);
 	outw(StatsEnable, ioaddr + EL3_CMD);
-	return;
 }
 
 static int
diff --git a/drivers/net/3c515.c b/drivers/net/3c515.c
index 569e269..3bba835 100644
--- a/drivers/net/3c515.c
+++ b/drivers/net/3c515.c
@@ -958,7 +958,6 @@ static void corkscrew_timer(unsigned long data)
 		       dev->name, media_tbl[dev->if_port].name);
 
 #endif				/* AUTOMEDIA */
-	return;
 }
 
 static void corkscrew_timeout(struct net_device *dev)
@@ -1516,7 +1515,6 @@ static void update_stats(int ioaddr, struct net_device *dev)
 
 	/* We change back to window 7 (not 1) with the Vortex. */
 	EL3WINDOW(7);
-	return;
 }
 
 /* This new version of set_rx_mode() supports v1.4 kernels.
diff --git a/drivers/net/3c59x.c b/drivers/net/3c59x.c
index dab2afa..d75803e 100644
--- a/drivers/net/3c59x.c
+++ b/drivers/net/3c59x.c
@@ -1855,7 +1855,6 @@ leave_media_alone:
 	mod_timer(&vp->timer, RUN_AT(next_tick));
 	if (vp->deferred)
 		iowrite16(FakeIntr, ioaddr + EL3_CMD);
-	return;
 }
 
 static void vortex_tx_timeout(struct net_device *dev)
@@ -2798,7 +2797,6 @@ static void update_stats(void __iomem *ioaddr, struct net_device *dev)
 	}
 
 	EL3WINDOW(old_window >> 13);
-	return;
 }
 
 static int vortex_nway_reset(struct net_device *dev)
@@ -3120,7 +3118,6 @@ static void mdio_write(struct net_device *dev, int phy_id, int location, int val
 		iowrite16(MDIO_ENB_IN | MDIO_SHIFT_CLK, mdio_addr);
 		mdio_delay();
 	}
-	return;
 }
 
 /* ACPI: Advanced Configuration and Power Interface. */
diff --git a/drivers/net/7990.c b/drivers/net/7990.c
index 561d3d5..903bcb3 100644
--- a/drivers/net/7990.c
+++ b/drivers/net/7990.c
@@ -619,7 +619,6 @@ static void lance_load_multicast (struct net_device *dev)
                 crc = crc >> 26;
                 mcast_table [crc >> 4] |= 1 << (crc & 0xf);
         }
-        return;
 }
 
 
diff --git a/drivers/net/8139cp.c b/drivers/net/8139cp.c
index cd63b97..9c14975 100644
--- a/drivers/net/8139cp.c
+++ b/drivers/net/8139cp.c
@@ -1224,8 +1224,6 @@ static void cp_tx_timeout(struct net_device *dev)
 	netif_wake_queue(dev);
 
 	spin_unlock_irqrestore(&cp->lock, flags);
-
-	return;
 }
 
 #ifdef BROKEN
diff --git a/drivers/net/a2065.c b/drivers/net/a2065.c
index ecaa28c..541f9a2 100644
--- a/drivers/net/a2065.c
+++ b/drivers/net/a2065.c
@@ -627,7 +627,6 @@ static void lance_load_multicast (struct net_device *dev)
 		crc = crc >> 26;
 		mcast_table [crc >> 4] |= 1 << (crc & 0xf);
 	}
-	return;
 }
 
 static void lance_set_multicast (struct net_device *dev)
diff --git a/drivers/net/ac3200.c b/drivers/net/ac3200.c
index eac7338..b9115a7 100644
--- a/drivers/net/ac3200.c
+++ b/drivers/net/ac3200.c
@@ -307,8 +307,6 @@ static void ac_reset_8390(struct net_device *dev)
 	ei_status.txing = 0;
 	outb(AC_ENABLE, ioaddr + AC_RESET_PORT);
 	if (ei_debug > 1) printk("reset done\n");
-
-	return;
 }
 
 /* Grab the 8390 specific header. Similar to the block_input routine, but
diff --git a/drivers/net/acenic.c b/drivers/net/acenic.c
index 1328eb9..b9a5916 100644
--- a/drivers/net/acenic.c
+++ b/drivers/net/acenic.c
@@ -2919,8 +2919,6 @@ static void __devinit ace_clear(struct ace_regs __iomem *regs, u32 dest, int siz
 		dest += tsize;
 		size -= tsize;
 	}
-
-	return;
 }
 
 
diff --git a/drivers/net/apne.c b/drivers/net/apne.c
index 1437f5d..2fe60f1 100644
--- a/drivers/net/apne.c
+++ b/drivers/net/apne.c
@@ -521,7 +521,6 @@ apne_block_output(struct net_device *dev, int count,
 
     outb(ENISR_RDC, nic_base + NE_EN0_ISR);	/* Ack intr. */
     ei_status.dmaing &= ~0x01;
-    return;
 }
 
 static irqreturn_t apne_interrupt(int irq, void *dev_id)
diff --git a/drivers/net/appletalk/cops.c b/drivers/net/appletalk/cops.c
index 14e1d95..748c9f5 100644
--- a/drivers/net/appletalk/cops.c
+++ b/drivers/net/appletalk/cops.c
@@ -593,8 +593,6 @@ static void cops_load (struct net_device *dev)
                 tangent_wait_reset(ioaddr);
                 inb(ioaddr);	/* Clear initial ready signal. */
         }
-
-        return;
 }
 
 /*
@@ -701,8 +699,6 @@ static void cops_poll(unsigned long ltdev)
 	/* poll 20 times per second */
 	cops_timer.expires = jiffies + HZ/20;
 	add_timer(&cops_timer);
-
-	return;
 }
 
 /*
diff --git a/drivers/net/appletalk/ltpc.c b/drivers/net/appletalk/ltpc.c
index 6af65b6..adc0755 100644
--- a/drivers/net/appletalk/ltpc.c
+++ b/drivers/net/appletalk/ltpc.c
@@ -641,7 +641,6 @@ done:
 		inb_p(base+7);
 		inb_p(base+7);
 	}
-	return;
 }
 
 
diff --git a/drivers/net/at1700.c b/drivers/net/at1700.c
index 861f07a..93185f5 100644
--- a/drivers/net/at1700.c
+++ b/drivers/net/at1700.c
@@ -795,7 +795,6 @@ net_rx(struct net_device *dev)
 			printk("%s: Exint Rx packet with mode %02x after %d ticks.\n",
 				   dev->name, inb(ioaddr + RX_MODE), i);
 	}
-	return;
 }
 
 /* The inverse routine to net_open(). */
@@ -869,7 +868,6 @@ set_rx_mode(struct net_device *dev)
 		outw(saved_bank, ioaddr + CONFIG_0);
 	}
 	spin_unlock_irqrestore (&lp->lock, flags);
-	return;
 }
 
 #ifdef MODULE
diff --git a/drivers/net/atl1c/atl1c_ethtool.c b/drivers/net/atl1c/atl1c_ethtool.c
index 3233924..7c52150 100644
--- a/drivers/net/atl1c/atl1c_ethtool.c
+++ b/drivers/net/atl1c/atl1c_ethtool.c
@@ -263,8 +263,6 @@ static void atl1c_get_wol(struct net_device *netdev,
 		wol->wolopts |= WAKE_MAGIC;
 	if (adapter->wol & AT_WUFC_LNKC)
 		wol->wolopts |= WAKE_PHY;
-
-	return;
 }
 
 static int atl1c_set_wol(struct net_device *netdev, struct ethtool_wolinfo *wol)
diff --git a/drivers/net/atl1c/atl1c_main.c b/drivers/net/atl1c/atl1c_main.c
index 3d70511..1c3c046 100644
--- a/drivers/net/atl1c/atl1c_main.c
+++ b/drivers/net/atl1c/atl1c_main.c
@@ -317,8 +317,6 @@ static void atl1c_common_task(struct work_struct *work)
 
 	if (adapter->work_event & ATL1C_WORK_EVENT_LINK_CHANGE)
 		atl1c_check_link_status(adapter);
-
-	return;
 }
 
 
diff --git a/drivers/net/atl1e/atl1e_ethtool.c b/drivers/net/atl1e/atl1e_ethtool.c
index ffd696e..6943a6c 100644
--- a/drivers/net/atl1e/atl1e_ethtool.c
+++ b/drivers/net/atl1e/atl1e_ethtool.c
@@ -338,8 +338,6 @@ static void atl1e_get_wol(struct net_device *netdev,
 		wol->wolopts |= WAKE_MAGIC;
 	if (adapter->wol & AT_WUFC_LNKC)
 		wol->wolopts |= WAKE_PHY;
-
-	return;
 }
 
 static int atl1e_set_wol(struct net_device *netdev, struct ethtool_wolinfo *wol)
diff --git a/drivers/net/atl1e/atl1e_main.c b/drivers/net/atl1e/atl1e_main.c
index 7dd3377..1acea57 100644
--- a/drivers/net/atl1e/atl1e_main.c
+++ b/drivers/net/atl1e/atl1e_main.c
@@ -707,8 +707,6 @@ static void atl1e_init_ring_resources(struct atl1e_adapter *adapter)
 	adapter->ring_vir_addr = NULL;
 	adapter->rx_ring.desc = NULL;
 	rwlock_init(&adapter->tx_ring.tx_lock);
-
-	return;
 }
 
 /*
@@ -905,8 +903,6 @@ static inline void atl1e_configure_des_ring(const struct atl1e_adapter *adapter)
 	AT_WRITE_REG(hw, REG_HOST_RXFPAGE_SIZE, rx_ring->page_size);
 	/* Load all of base address above */
 	AT_WRITE_REG(hw, REG_LOAD_PTR, 1);
-
-	return;
 }
 
 static inline void atl1e_configure_tx(struct atl1e_adapter *adapter)
@@ -950,7 +946,6 @@ static inline void atl1e_configure_tx(struct atl1e_adapter *adapter)
 			(((u16)hw->tpd_burst & TXQ_CTRL_NUM_TPD_BURST_MASK)
 			 << TXQ_CTRL_NUM_TPD_BURST_SHIFT)
 			| TXQ_CTRL_ENH_MODE | TXQ_CTRL_EN);
-	return;
 }
 
 static inline void atl1e_configure_rx(struct atl1e_adapter *adapter)
@@ -1004,7 +999,6 @@ static inline void atl1e_configure_rx(struct atl1e_adapter *adapter)
 			 RXQ_CTRL_CUT_THRU_EN | RXQ_CTRL_EN;
 
 	AT_WRITE_REG(hw, REG_RXQ_CTRL, rxq_ctrl_data);
-	return;
 }
 
 static inline void atl1e_configure_dma(struct atl1e_adapter *adapter)
@@ -1024,7 +1018,6 @@ static inline void atl1e_configure_dma(struct atl1e_adapter *adapter)
 		<< DMA_CTRL_DMAW_DLY_CNT_SHIFT;
 
 	AT_WRITE_REG(hw, REG_DMA_CTRL, dma_ctrl_data);
-	return;
 }
 
 static void atl1e_setup_mac_ctrl(struct atl1e_adapter *adapter)
diff --git a/drivers/net/atlx/atl1.c b/drivers/net/atlx/atl1.c
index 33448a0..63b9ba0 100644
--- a/drivers/net/atlx/atl1.c
+++ b/drivers/net/atlx/atl1.c
@@ -1830,8 +1830,6 @@ static void atl1_rx_checksum(struct atl1_adapter *adapter,
 		adapter->hw_csum_good++;
 		return;
 	}
-
-	return;
 }
 
 /*
@@ -3390,7 +3388,6 @@ static void atl1_get_wol(struct net_device *netdev,
 	wol->wolopts = 0;
 	if (adapter->wol & ATLX_WUFC_MAG)
 		wol->wolopts |= WAKE_MAGIC;
-	return;
 }
 
 static int atl1_set_wol(struct net_device *netdev,
diff --git a/drivers/net/atp.c b/drivers/net/atp.c
index 75ff0c5..bd2f9d3 100644
--- a/drivers/net/atp.c
+++ b/drivers/net/atp.c
@@ -802,7 +802,6 @@ static void net_rx(struct net_device *dev)
  done:
 	write_reg(ioaddr, CMR1, CMR1_NextPkt);
 	lp->last_rx_time = jiffies;
-	return;
 }
 
 static void read_block(long ioaddr, int length, unsigned char *p, int data_mode)
diff --git a/drivers/net/ax88796.c b/drivers/net/ax88796.c
index b718dc6..55c9958 100644
--- a/drivers/net/ax88796.c
+++ b/drivers/net/ax88796.c
@@ -303,7 +303,6 @@ static void ax_block_output(struct net_device *dev, int count,
 
 	ei_outb(ENISR_RDC, nic_base + EN0_ISR);	/* Ack intr. */
 	ei_status.dmaing &= ~0x01;
-	return;
 }
 
 /* definitions for accessing MII/EEPROM interface */
diff --git a/drivers/net/benet/be_ethtool.c b/drivers/net/benet/be_ethtool.c
index d488d52..200e985 100644
--- a/drivers/net/benet/be_ethtool.c
+++ b/drivers/net/benet/be_ethtool.c
@@ -276,8 +276,6 @@ be_get_ethtool_stats(struct net_device *netdev,
 		data[i] = (et_stats[i].size == sizeof(u64)) ?
 				*(u64 *)p: *(u32 *)p;
 	}
-
-	return;
 }
 
 static void
@@ -466,7 +464,6 @@ be_get_wol(struct net_device *netdev, struct ethtool_wolinfo *wol)
 	else
 		wol->wolopts = 0;
 	memset(&wol->sopass, 0, sizeof(wol->sopass));
-	return;
 }
 
 static int
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index fa10f13..058d7f9 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -830,7 +830,6 @@ static void skb_fill_rx_data(struct be_adapter *adapter,
 
 done:
 	be_rx_stats_update(adapter, pktsize, num_rcvd);
-	return;
 }
 
 /* Process the RX completion indicated by rxcp when GRO is disabled */
@@ -884,8 +883,6 @@ static void be_rx_compl_process(struct be_adapter *adapter,
 	} else {
 		netif_receive_skb(skb);
 	}
-
-	return;
 }
 
 /* Process the RX completion indicated by rxcp when GRO is enabled */
@@ -965,7 +962,6 @@ static void be_rx_compl_process_gro(struct be_adapter *adapter,
 	}
 
 	be_rx_stats_update(adapter, pkt_size, num_rcvd);
-	return;
 }
 
 static struct be_eth_rx_compl *be_rx_compl_get(struct be_adapter *adapter)
@@ -1059,8 +1055,6 @@ static void be_post_rx_frags(struct be_adapter *adapter)
 		/* Let be_worker replenish when memory is available */
 		adapter->rx_post_starved = true;
 	}
-
-	return;
 }
 
 static struct be_eth_tx_compl *be_tx_compl_get(struct be_queue_info *tx_cq)
@@ -1622,7 +1616,6 @@ static void be_msix_enable(struct be_adapter *adapter)
 		BE_NUM_MSIX_VECTORS);
 	if (status == 0)
 		adapter->msix_enabled = true;
-	return;
 }
 
 static void be_sriov_enable(struct be_adapter *adapter)
@@ -1634,7 +1627,6 @@ static void be_sriov_enable(struct be_adapter *adapter)
 		adapter->sriov_enabled = status ? false : true;
 	}
 #endif
-	return;
 }
 
 static void be_sriov_disable(struct be_adapter *adapter)
@@ -1741,7 +1733,6 @@ static void be_irq_unregister(struct be_adapter *adapter)
 	be_free_irq(adapter, &adapter->rx_eq);
 done:
 	adapter->isr_registered = false;
-	return;
 }
 
 static int be_open(struct net_device *netdev)
@@ -2620,8 +2611,6 @@ static void be_shutdown(struct pci_dev *pdev)
 		be_setup_wol(adapter, true);
 
 	pci_disable_device(pdev);
-
-	return;
 }
 
 static pci_ers_result_t be_eeh_err_detected(struct pci_dev *pdev,
@@ -2703,7 +2692,6 @@ static void be_eeh_resume(struct pci_dev *pdev)
 	return;
 err:
 	dev_err(&adapter->pdev->dev, "EEH resume failed\n");
-	return;
 }
 
 static struct pci_error_handlers be_eeh_handlers = {
diff --git a/drivers/net/bfin_mac.c b/drivers/net/bfin_mac.c
index b0207f0..3554870 100644
--- a/drivers/net/bfin_mac.c
+++ b/drivers/net/bfin_mac.c
@@ -835,8 +835,6 @@ static void bfin_mac_multicast_hash(struct net_device *dev)
 
 	bfin_write_EMAC_HASHHI(emac_hashhi);
 	bfin_write_EMAC_HASHLO(emac_hashlo);
-
-	return;
 }
 
 /*
diff --git a/drivers/net/bmac.c b/drivers/net/bmac.c
index 44ceecf..39250b2 100644
--- a/drivers/net/bmac.c
+++ b/drivers/net/bmac.c
@@ -167,7 +167,6 @@ static inline void
 dbdma_st32(volatile __u32 __iomem *a, unsigned long x)
 {
 	__asm__ volatile( "stwbrx %0,0,%1" : : "r" (x), "r" (a) : "memory");
-	return;
 }
 
 static inline unsigned long
@@ -382,8 +381,6 @@ bmac_init_registers(struct net_device *dev)
 	bmwrite(dev, RXCFG, RxCRCNoStrip | RxHashFilterEnable | RxRejectOwnPackets);
 
 	bmwrite(dev, INTDISABLE, EnableNormal);
-
-	return;
 }
 
 #if 0
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 2aa3367..02497bc 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -368,15 +368,12 @@ void bond_unregister_ipv6_notifier(void);
 #else
 static inline void bond_send_unsolicited_na(struct bonding *bond)
 {
-	return;
 }
 static inline void bond_register_ipv6_notifier(void)
 {
-	return;
 }
 static inline void bond_unregister_ipv6_notifier(void)
 {
-	return;
 }
 #endif
 
diff --git a/drivers/net/can/usb/ems_usb.c b/drivers/net/can/usb/ems_usb.c
index d800b59..df0a636 100644
--- a/drivers/net/can/usb/ems_usb.c
+++ b/drivers/net/can/usb/ems_usb.c
@@ -300,8 +300,6 @@ static void ems_usb_read_interrupt_callback(struct urb *urb)
 	else if (err)
 		dev_err(netdev->dev.parent,
 			"failed resubmitting intr urb: %d\n", err);
-
-	return;
 }
 
 static void ems_usb_rx_can_msg(struct ems_usb *dev, struct ems_cpc_msg *msg)
@@ -497,8 +495,6 @@ resubmit_urb:
 	else if (retval)
 		dev_err(netdev->dev.parent,
 			"failed resubmitting read bulk urb: %d\n", retval);
-
-	return;
 }
 
 /*
diff --git a/drivers/net/cnic.c b/drivers/net/cnic.c
index 4b451a7..4b08b18 100644
--- a/drivers/net/cnic.c
+++ b/drivers/net/cnic.c
@@ -2092,7 +2092,6 @@ end:
 		i += j;
 		j = 1;
 	}
-	return;
 }
 
 static u16 cnic_bnx2_next_idx(u16 idx)
@@ -2325,7 +2324,6 @@ done:
 			   status_idx, IGU_INT_ENABLE, 1);
 
 	cp->kcq_prod_idx = sw_prod;
-	return;
 }
 
 static int cnic_service_bnx2x(void *data, void *status_blk)
@@ -4628,7 +4626,6 @@ static void __exit cnic_exit(void)
 {
 	unregister_netdevice_notifier(&cnic_netdev_notifier);
 	cnic_release();
-	return;
 }
 
 module_init(cnic_init);
diff --git a/drivers/net/cs89x0.c b/drivers/net/cs89x0.c
index 2281ebc..2ccb9f1 100644
--- a/drivers/net/cs89x0.c
+++ b/drivers/net/cs89x0.c
@@ -902,7 +902,6 @@ get_dma_channel(struct net_device *dev)
 			return;
 		}
 	}
-	return;
 }
 
 static void
@@ -1672,7 +1671,6 @@ count_rx_errors(int status, struct net_local *lp)
 		/* per str 172 */
 		lp->stats.rx_crc_errors++;
 	if (status & RX_DRIBBLE) lp->stats.rx_frame_errors++;
-	return;
 }
 
 /* We have a good packet(s), get it/them out of the buffers. */
diff --git a/drivers/net/cxgb3/l2t.c b/drivers/net/cxgb3/l2t.c
index 2f3ee72..f452c40 100644
--- a/drivers/net/cxgb3/l2t.c
+++ b/drivers/net/cxgb3/l2t.c
@@ -207,7 +207,6 @@ again:
 		 */
 		neigh_event_send(e->neigh, NULL);
 	}
-	return;
 }
 
 EXPORT_SYMBOL(t3_l2t_send_event);
diff --git a/drivers/net/declance.c b/drivers/net/declance.c
index 74abe19..1d973db 100644
--- a/drivers/net/declance.c
+++ b/drivers/net/declance.c
@@ -969,7 +969,6 @@ static void lance_load_multicast(struct net_device *dev)
 		crc = crc >> 26;
 		*lib_ptr(ib, filter[crc >> 4], lp->type) |= 1 << (crc & 0xf);
 	}
-	return;
 }
 
 static void lance_set_multicast(struct net_device *dev)
diff --git a/drivers/net/depca.c b/drivers/net/depca.c
index 38d4d9e..bf66e9b 100644
--- a/drivers/net/depca.c
+++ b/drivers/net/depca.c
@@ -1203,8 +1203,6 @@ static void LoadCSRs(struct net_device *dev)
 	outw(ACON, DEPCA_DATA);
 
 	outw(CSR0, DEPCA_ADDR);	/* Point back to CSR0 */
-
-	return;
 }
 
 static int InitRestartDepca(struct net_device *dev)
@@ -1302,8 +1300,6 @@ static void SetMulticastFilter(struct net_device *dev)
 			}
 		}
 	}
-
-	return;
 }
 
 static int __init depca_common_init (u_long ioaddr, struct net_device **devp)
@@ -1908,8 +1904,6 @@ static void depca_dbg_open(struct net_device *dev)
 		outw(CSR3, DEPCA_ADDR);
 		printk("CSR3: 0x%4.4x\n", inw(DEPCA_DATA));
 	}
-
-	return;
 }
 
 /*
diff --git a/drivers/net/dl2k.c b/drivers/net/dl2k.c
index 6579225..a2f238d 100644
--- a/drivers/net/dl2k.c
+++ b/drivers/net/dl2k.c
@@ -596,8 +596,6 @@ alloc_list (struct net_device *dev)
 	/* Set RFDListPtr */
 	writel (np->rx_ring_dma, dev->base_addr + RFDListPtr0);
 	writel (0, dev->base_addr + RFDListPtr1);
-
-	return;
 }
 
 static netdev_tx_t
diff --git a/drivers/net/e1000/e1000_ethtool.c b/drivers/net/e1000/e1000_ethtool.c
index 2a3b2dc..d5ff029 100644
--- a/drivers/net/e1000/e1000_ethtool.c
+++ b/drivers/net/e1000/e1000_ethtool.c
@@ -1015,8 +1015,6 @@ static void e1000_free_desc_rings(struct e1000_adapter *adapter)
 	txdr->buffer_info = NULL;
 	kfree(rxdr->buffer_info);
 	rxdr->buffer_info = NULL;
-
-	return;
 }
 
 static int e1000_setup_desc_rings(struct e1000_adapter *adapter)
@@ -1711,8 +1709,6 @@ static void e1000_get_wol(struct net_device *netdev,
 		wol->wolopts |= WAKE_BCAST;
 	if (adapter->wol & E1000_WUFC_MAG)
 		wol->wolopts |= WAKE_MAGIC;
-
-	return;
 }
 
 static int e1000_set_wol(struct net_device *netdev, struct ethtool_wolinfo *wol)
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 4dd2c23..f06c897 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -2546,8 +2546,6 @@ set_itr_now:
 		adapter->itr = new_itr;
 		ew32(ITR, 1000000000 / (new_itr * 256));
 	}
-
-	return;
 }
 
 #define E1000_TX_FLAGS_CSUM		0x00000001
diff --git a/drivers/net/e1000e/82571.c b/drivers/net/e1000e/82571.c
index 1e73edd..e2ede8c 100644
--- a/drivers/net/e1000e/82571.c
+++ b/drivers/net/e1000e/82571.c
@@ -1137,8 +1137,6 @@ static void e1000_initialize_hw_bits_82571(struct e1000_hw *hw)
 	default:
 		break;
 	}
-
-	return;
 }
 
 /**
@@ -1642,8 +1640,6 @@ static void e1000_power_down_phy_copper_82571(struct e1000_hw *hw)
 	/* If the management interface is not enabled, then power down */
 	if (!(mac->ops.check_mng_mode(hw) || phy->ops.check_reset_block(hw)))
 		e1000_power_down_phy_copper(hw);
-
-	return;
 }
 
 /**
diff --git a/drivers/net/e1000e/es2lan.c b/drivers/net/e1000e/es2lan.c
index 27d2158..5bc7a3d 100644
--- a/drivers/net/e1000e/es2lan.c
+++ b/drivers/net/e1000e/es2lan.c
@@ -1380,8 +1380,6 @@ static void e1000_power_down_phy_copper_80003es2lan(struct e1000_hw *hw)
 	if (!(hw->mac.ops.check_mng_mode(hw) ||
 	      hw->phy.ops.check_reset_block(hw)))
 		e1000_power_down_phy_copper(hw);
-
-	return;
 }
 
 /**
diff --git a/drivers/net/e1000e/ich8lan.c b/drivers/net/e1000e/ich8lan.c
index b8c4dce..e8c8738 100644
--- a/drivers/net/e1000e/ich8lan.c
+++ b/drivers/net/e1000e/ich8lan.c
@@ -687,8 +687,6 @@ static s32 e1000_acquire_nvm_ich8lan(struct e1000_hw *hw)
 static void e1000_release_nvm_ich8lan(struct e1000_hw *hw)
 {
 	mutex_unlock(&nvm_mutex);
-
-	return;
 }
 
 static DEFINE_MUTEX(swflag_mutex);
@@ -767,8 +765,6 @@ static void e1000_release_swflag_ich8lan(struct e1000_hw *hw)
 	ew32(EXTCNF_CTRL, extcnf_ctrl);
 
 	mutex_unlock(&swflag_mutex);
-
-	return;
 }
 
 /**
@@ -2778,8 +2774,6 @@ static void e1000_initialize_hw_bits_ich8lan(struct e1000_hw *hw)
 	reg = er32(RFCTL);
 	reg |= (E1000_RFCTL_NFSW_DIS | E1000_RFCTL_NFSR_DIS);
 	ew32(RFCTL, reg);
-
-	return;
 }
 
 /**
@@ -3157,8 +3151,6 @@ void e1000e_disable_gig_wol_ich8lan(struct e1000_hw *hw)
 	default:
 		break;
 	}
-
-	return;
 }
 
 /**
@@ -3350,8 +3342,6 @@ static void e1000_power_down_phy_copper_ich8lan(struct e1000_hw *hw)
 	if (!(hw->mac.ops.check_mng_mode(hw) ||
 	      hw->phy.ops.check_reset_block(hw)))
 		e1000_power_down_phy_copper(hw);
-
-	return;
 }
 
 /**
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index c5f65a2..068e0c5 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -1767,8 +1767,6 @@ void e1000e_reset_interrupt_capability(struct e1000_adapter *adapter)
 		pci_disable_msi(adapter->pdev);
 		adapter->flags &= ~FLAG_MSI_ENABLED;
 	}
-
-	return;
 }
 
 /**
@@ -1820,8 +1818,6 @@ void e1000e_set_interrupt_capability(struct e1000_adapter *adapter)
 		/* Don't do anything; this is the system default */
 		break;
 	}
-
-	return;
 }
 
 /**
diff --git a/drivers/net/e2100.c b/drivers/net/e2100.c
index ca93c9a..06e72fb 100644
--- a/drivers/net/e2100.c
+++ b/drivers/net/e2100.c
@@ -328,7 +328,6 @@ e21_reset_8390(struct net_device *dev)
 	/* Set up the ASIC registers, just in case something changed them. */
 
 	if (ei_debug > 1) printk("reset done\n");
-	return;
 }
 
 /* Grab the 8390 specific header. We put the 2k window so the header page
diff --git a/drivers/net/eexpress.c b/drivers/net/eexpress.c
index 43c9c9c..12c37d2 100644
--- a/drivers/net/eexpress.c
+++ b/drivers/net/eexpress.c
@@ -1570,7 +1570,6 @@ static void eexp_hw_init586(struct net_device *dev)
 #if NET_DEBUG > 6
         printk("%s: leaving eexp_hw_init586()\n", dev->name);
 #endif
-	return;
 }
 
 static void eexp_setup_filter(struct net_device *dev)
diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
index 33a41e2..ddf0e44 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -1881,7 +1881,6 @@ static void ehea_promiscuous(struct net_device *dev, int enable)
 	port->promisc = enable;
 out:
 	free_page((unsigned long)cb7);
-	return;
 }
 
 static u64 ehea_multicast_reg_helper(struct ehea_port *port, u64 mc_mac_addr,
@@ -2025,7 +2024,6 @@ static void ehea_set_multicast_list(struct net_device *dev)
 	}
 out:
 	ehea_update_bcmc_registrations();
-	return;
 }
 
 static int ehea_change_mtu(struct net_device *dev, int new_mtu)
@@ -2303,7 +2301,6 @@ static void ehea_vlan_rx_add_vid(struct net_device *dev, unsigned short vid)
 		ehea_error("modify_ehea_port failed");
 out:
 	free_page((unsigned long)cb1);
-	return;
 }
 
 static void ehea_vlan_rx_kill_vid(struct net_device *dev, unsigned short vid)
@@ -2338,7 +2335,6 @@ static void ehea_vlan_rx_kill_vid(struct net_device *dev, unsigned short vid)
 		ehea_error("modify_ehea_port failed");
 out:
 	free_page((unsigned long)cb1);
-	return;
 }
 
 int ehea_activate_qp(struct ehea_adapter *adapter, struct ehea_qp *qp)
@@ -2881,7 +2877,6 @@ static void ehea_reset_port(struct work_struct *work)
 	netif_wake_queue(dev);
 out:
 	mutex_unlock(&port->port_lock);
-	return;
 }
 
 static void ehea_rereg_mrs(struct work_struct *work)
diff --git a/drivers/net/epic100.c b/drivers/net/epic100.c
index a48da2d..6838dfc 100644
--- a/drivers/net/epic100.c
+++ b/drivers/net/epic100.c
@@ -652,7 +652,6 @@ static void mdio_write(struct net_device *dev, int phy_id, int loc, int value)
 		if ((inl(ioaddr + MIICtrl) & MII_WRITEOP) == 0)
 			break;
 	}
-	return;
 }
 
 
@@ -840,7 +839,6 @@ static void epic_restart(struct net_device *dev)
 		   " interrupt %4.4x.\n",
 		   dev->name, (int)inl(ioaddr + COMMAND), (int)inl(ioaddr + GENCTL),
 		   (int)inl(ioaddr + INTSTAT));
-	return;
 }
 
 static void check_media(struct net_device *dev)
@@ -958,7 +956,6 @@ static void epic_init_ring(struct net_device *dev)
 			(i+1)*sizeof(struct epic_tx_desc);
 	}
 	ep->tx_ring[i-1].next = ep->tx_ring_dma;
-	return;
 }
 
 static netdev_tx_t epic_start_xmit(struct sk_buff *skb, struct net_device *dev)
@@ -1413,7 +1410,6 @@ static void set_rx_mode(struct net_device *dev)
 			outw(((u16 *)mc_filter)[i], ioaddr + MC0 + i*4);
 		memcpy(ep->mc_filter, mc_filter, sizeof(mc_filter));
 	}
-	return;
 }
 
 static void netdev_get_drvinfo (struct net_device *dev, struct ethtool_drvinfo *info)
diff --git a/drivers/net/es3210.c b/drivers/net/es3210.c
index 5569f2f..0ba5e7b 100644
--- a/drivers/net/es3210.c
+++ b/drivers/net/es3210.c
@@ -319,8 +319,6 @@ static void es_reset_8390(struct net_device *dev)
 	ei_status.txing = 0;
 	outb(0x01, ioaddr + ES_RESET_PORT);
 	if (ei_debug > 1) printk("reset done\n");
-
-	return;
 }
 
 /*
diff --git a/drivers/net/ewrk3.c b/drivers/net/ewrk3.c
index 99eb56b..380d061 100644
--- a/drivers/net/ewrk3.c
+++ b/drivers/net/ewrk3.c
@@ -1369,8 +1369,6 @@ static void __init EthwrkSignature(char *name, char *eeprom_image)
 		name[EWRK3_STRLEN] = '\0';
 	} else
 		name[0] = '\0';
-
-	return;
 }
 
 /*
diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 11d8cae..41d32b2 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -3009,8 +3009,6 @@ static void gfar_set_multi(struct net_device *dev)
 				gfar_set_hash_for_addr(dev, ha->addr);
 		}
 	}
-
-	return;
 }
 
 
@@ -3051,8 +3049,6 @@ static void gfar_set_hash_for_addr(struct net_device *dev, u8 *addr)
 	tempval = gfar_read(priv->hash_regs[whichreg]);
 	tempval |= value;
 	gfar_write(priv->hash_regs[whichreg], tempval);
-
-	return;
 }
 
 
diff --git a/drivers/net/hamachi.c b/drivers/net/hamachi.c
index 83f43bb..61f2b1c 100644
--- a/drivers/net/hamachi.c
+++ b/drivers/net/hamachi.c
@@ -859,7 +859,6 @@ static void mdio_write(struct net_device *dev, int phy_id, int location, int val
 	for (i = 10000; i >= 0; i--)
 		if ((readw(ioaddr + MII_Status) & 1) == 0)
 			break;
-	return;
 }
 
 
@@ -1225,8 +1224,6 @@ static void hamachi_init_ring(struct net_device *dev)
 	}
 	/* Mark the last entry of the ring */
 	hmp->tx_ring[TX_RING_SIZE-1].status_n_length |= cpu_to_le32(DescEndRing);
-
-	return;
 }
 
 
diff --git a/drivers/net/hamradio/scc.c b/drivers/net/hamradio/scc.c
index f3a96b8..9f64c86 100644
--- a/drivers/net/hamradio/scc.c
+++ b/drivers/net/hamradio/scc.c
@@ -1629,7 +1629,6 @@ static void scc_net_rx(struct scc_channel *scc, struct sk_buff *skb)
 	skb->protocol = ax25_type_trans(skb, scc->dev);
 	
 	netif_rx(skb);
-	return;
 }
 
 /* ----> transmit frame <---- */
diff --git a/drivers/net/hp-plus.c b/drivers/net/hp-plus.c
index efdbcad..82bffc3 100644
--- a/drivers/net/hp-plus.c
+++ b/drivers/net/hp-plus.c
@@ -351,7 +351,6 @@ hpp_reset_8390(struct net_device *dev)
 		printk("%s: hp_reset_8390() did not complete.\n", dev->name);
 
 	if (ei_debug > 1) printk("8390 reset done (%ld).", jiffies);
-	return;
 }
 
 /* The programmed-I/O version of reading the 4 byte 8390 specific header.
@@ -422,7 +421,6 @@ hpp_io_block_output(struct net_device *dev, int count,
 	int ioaddr = dev->base_addr - NIC_OFFSET;
 	outw(start_page << 8, ioaddr + HPP_OUT_ADDR);
 	outsl(ioaddr + HP_DATAPORT, buf, (count+3)>>2);
-	return;
 }
 
 static void
@@ -436,8 +434,6 @@ hpp_mem_block_output(struct net_device *dev, int count,
 	outw(option_reg & ~(MemDisable + BootROMEnb), ioaddr + HPP_OPTION);
 	memcpy_toio(ei_status.mem, buf, (count + 3) & ~3);
 	outw(option_reg, ioaddr + HPP_OPTION);
-
-	return;
 }
 
 
diff --git a/drivers/net/hp.c b/drivers/net/hp.c
index 5c4d78c..86ececd 100644
--- a/drivers/net/hp.c
+++ b/drivers/net/hp.c
@@ -240,7 +240,6 @@ hp_reset_8390(struct net_device *dev)
 		printk("%s: hp_reset_8390() did not complete.\n", dev->name);
 
 	if (ei_debug > 1) printk("8390 reset done (%ld).", jiffies);
-	return;
 }
 
 static void
@@ -360,7 +359,6 @@ hp_block_output(struct net_device *dev, int count,
 			   dev->name, (start_page << 8) + count, addr);
 	}
 	outb_p(saved_config & (~HP_DATAON), nic_base - NIC_OFFSET + HP_CONFIGURE);
-	return;
 }
 
 /* This function resets the ethercard if something screws up. */
@@ -371,7 +369,6 @@ hp_init_card(struct net_device *dev)
 	NS8390p_init(dev, 0);
 	outb_p(irqmap[irq&0x0f] | HP_RUN,
 		   dev->base_addr - NIC_OFFSET + HP_CONFIGURE);
-	return;
 }
 
 #ifdef MODULE
diff --git a/drivers/net/ibmveth.c b/drivers/net/ibmveth.c
index 092fb9d..3e4dead 100644
--- a/drivers/net/ibmveth.c
+++ b/drivers/net/ibmveth.c
@@ -1421,7 +1421,6 @@ static void ibmveth_proc_register_adapter(struct ibmveth_adapter *adapter)
 		if (!entry)
 			ibmveth_error_printk("Cannot create adapter proc entry");
 	}
-	return;
 }
 
 static void ibmveth_proc_unregister_adapter(struct ibmveth_adapter *adapter)
diff --git a/drivers/net/igb/e1000_82575.c b/drivers/net/igb/e1000_82575.c
index 3ef4955..86438b5 100644
--- a/drivers/net/igb/e1000_82575.c
+++ b/drivers/net/igb/e1000_82575.c
@@ -1214,8 +1214,6 @@ void igb_power_down_phy_copper_82575(struct e1000_hw *hw)
 	/* If the management interface is not enabled, then power down */
 	if (!(igb_enable_mng_pass_thru(hw) || igb_check_reset_block(hw)))
 		igb_power_down_phy_copper(hw);
-
-	return;
 }
 
 /**
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 589cf4a..3881918 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -1054,7 +1054,6 @@ msi_only:
 out:
 	/* Notify the stack of the (possibly) reduced Tx Queue count. */
 	adapter->netdev->real_num_tx_queues = adapter->num_tx_queues;
-	return;
 }
 
 /**
@@ -3717,8 +3716,6 @@ set_itr_now:
 		q_vector->itr_val = new_itr;
 		q_vector->set_itr = 1;
 	}
-
-	return;
 }
 
 #define IGB_TX_FLAGS_CSUM		0x00000001
diff --git a/drivers/net/igbvf/ethtool.c b/drivers/net/igbvf/ethtool.c
index 8afff07..a5ef645 100644
--- a/drivers/net/igbvf/ethtool.c
+++ b/drivers/net/igbvf/ethtool.c
@@ -124,7 +124,6 @@ static int igbvf_set_settings(struct net_device *netdev,
 static void igbvf_get_pauseparam(struct net_device *netdev,
                                  struct ethtool_pauseparam *pause)
 {
-	return;
 }
 
 static int igbvf_set_pauseparam(struct net_device *netdev,
@@ -390,8 +389,6 @@ static void igbvf_get_wol(struct net_device *netdev,
 {
 	wol->supported = 0;
 	wol->wolopts = 0;
-
-	return;
 }
 
 static int igbvf_set_wol(struct net_device *netdev,
diff --git a/drivers/net/irda/mcs7780.c b/drivers/net/irda/mcs7780.c
index c0e0bb9..5b1036a 100644
--- a/drivers/net/irda/mcs7780.c
+++ b/drivers/net/irda/mcs7780.c
@@ -434,8 +434,6 @@ static void mcs_unwrap_mir(struct mcs_cb *mcs, __u8 *buf, int len)
 
 	mcs->netdev->stats.rx_packets++;
 	mcs->netdev->stats.rx_bytes += new_len;
-
-	return;
 }
 
 /* Unwrap received packets at FIR speed.  A 32 bit crc_ccitt checksum is
@@ -487,8 +485,6 @@ static void mcs_unwrap_fir(struct mcs_cb *mcs, __u8 *buf, int len)
 
 	mcs->netdev->stats.rx_packets++;
 	mcs->netdev->stats.rx_bytes += new_len;
-
-	return;
 }
 
 
diff --git a/drivers/net/irda/smsc-ircc2.c b/drivers/net/irda/smsc-ircc2.c
index 35e4e44..d67e484 100644
--- a/drivers/net/irda/smsc-ircc2.c
+++ b/drivers/net/irda/smsc-ircc2.c
@@ -2822,7 +2822,6 @@ static void __init preconfigure_ali_port(struct pci_dev *dev,
 	tmpbyte |= mask;
 	pci_write_config_byte(dev, reg, tmpbyte);
 	IRDA_MESSAGE("Activated ALi 1533 ISA bridge port 0x%04x.\n", port);
-	return;
 }
 
 static int __init preconfigure_through_ali(struct pci_dev *dev,
diff --git a/drivers/net/ixgb/ixgb_ee.c b/drivers/net/ixgb/ixgb_ee.c
index 06303a3..813993f 100644
--- a/drivers/net/ixgb/ixgb_ee.c
+++ b/drivers/net/ixgb/ixgb_ee.c
@@ -58,7 +58,6 @@ ixgb_raise_clock(struct ixgb_hw *hw,
 	*eecd_reg = *eecd_reg | IXGB_EECD_SK;
 	IXGB_WRITE_REG(hw, EECD, *eecd_reg);
 	udelay(50);
-	return;
 }
 
 /******************************************************************************
@@ -77,7 +76,6 @@ ixgb_lower_clock(struct ixgb_hw *hw,
 	*eecd_reg = *eecd_reg & ~IXGB_EECD_SK;
 	IXGB_WRITE_REG(hw, EECD, *eecd_reg);
 	udelay(50);
-	return;
 }
 
 /******************************************************************************
@@ -127,7 +125,6 @@ ixgb_shift_out_bits(struct ixgb_hw *hw,
 	/* We leave the "DI" bit set to "0" when we leave this routine. */
 	eecd_reg &= ~IXGB_EECD_DI;
 	IXGB_WRITE_REG(hw, EECD, eecd_reg);
-	return;
 }
 
 /******************************************************************************
@@ -192,7 +189,6 @@ ixgb_setup_eeprom(struct ixgb_hw *hw)
 	/*  Set CS  */
 	eecd_reg |= IXGB_EECD_CS;
 	IXGB_WRITE_REG(hw, EECD, eecd_reg);
-	return;
 }
 
 /******************************************************************************
@@ -226,7 +222,6 @@ ixgb_standby_eeprom(struct ixgb_hw *hw)
 	eecd_reg &= ~IXGB_EECD_SK;
 	IXGB_WRITE_REG(hw, EECD, eecd_reg);
 	udelay(50);
-	return;
 }
 
 /******************************************************************************
@@ -250,7 +245,6 @@ ixgb_clock_eeprom(struct ixgb_hw *hw)
 	eecd_reg &= ~IXGB_EECD_SK;
 	IXGB_WRITE_REG(hw, EECD, eecd_reg);
 	udelay(50);
-	return;
 }
 
 /******************************************************************************
@@ -270,7 +264,6 @@ ixgb_cleanup_eeprom(struct ixgb_hw *hw)
 	IXGB_WRITE_REG(hw, EECD, eecd_reg);
 
 	ixgb_clock_eeprom(hw);
-	return;
 }
 
 /******************************************************************************
@@ -359,7 +352,6 @@ ixgb_update_eeprom_checksum(struct ixgb_hw *hw)
 	checksum = (u16) EEPROM_SUM - checksum;
 
 	ixgb_write_eeprom(hw, EEPROM_CHECKSUM_REG, checksum);
-	return;
 }
 
 /******************************************************************************
@@ -414,8 +406,6 @@ ixgb_write_eeprom(struct ixgb_hw *hw, u16 offset, u16 data)
 
 	/* clear the init_ctrl_reg_1 to signify that the cache is invalidated */
 	ee_map->init_ctrl_reg_1 = cpu_to_le16(EEPROM_ICW1_SIGNATURE_CLEAR);
-
-	return;
 }
 
 /******************************************************************************
diff --git a/drivers/net/ixgb/ixgb_hw.c b/drivers/net/ixgb/ixgb_hw.c
index cd247b8..397acab 100644
--- a/drivers/net/ixgb/ixgb_hw.c
+++ b/drivers/net/ixgb/ixgb_hw.c
@@ -413,8 +413,6 @@ ixgb_init_rx_addrs(struct ixgb_hw *hw)
 		IXGB_WRITE_REG_ARRAY(hw, RA, ((i << 1) + 1), 0);
 		IXGB_WRITE_REG_ARRAY(hw, RA, (i << 1), 0);
 	}
-
-	return;
 }
 
 /******************************************************************************
@@ -483,7 +481,6 @@ ixgb_mc_addr_list_update(struct ixgb_hw *hw,
 	}
 
 	pr_debug("MC Update Complete\n");
-	return;
 }
 
 /******************************************************************************
@@ -566,8 +563,6 @@ ixgb_mta_set(struct ixgb_hw *hw,
 	mta_reg |= (1 << hash_bit);
 
 	IXGB_WRITE_REG_ARRAY(hw, MTA, hash_reg, mta_reg);
-
-	return;
 }
 
 /******************************************************************************
@@ -600,7 +595,6 @@ ixgb_rar_set(struct ixgb_hw *hw,
 
 	IXGB_WRITE_REG_ARRAY(hw, RA, (index << 1), rar_low);
 	IXGB_WRITE_REG_ARRAY(hw, RA, ((index << 1) + 1), rar_high);
-	return;
 }
 
 /******************************************************************************
@@ -616,7 +610,6 @@ ixgb_write_vfta(struct ixgb_hw *hw,
 		 u32 value)
 {
 	IXGB_WRITE_REG_ARRAY(hw, VFTA, offset, value);
-	return;
 }
 
 /******************************************************************************
@@ -631,7 +624,6 @@ ixgb_clear_vfta(struct ixgb_hw *hw)
 
 	for (offset = 0; offset < IXGB_VLAN_FILTER_TBL_SIZE; offset++)
 		IXGB_WRITE_REG_ARRAY(hw, VFTA, offset, 0);
-	return;
 }
 
 /******************************************************************************
@@ -1050,7 +1042,6 @@ ixgb_clear_hw_cntrs(struct ixgb_hw *hw)
 	temp_reg = IXGB_READ_REG(hw, XOFFRXC);
 	temp_reg = IXGB_READ_REG(hw, XOFFTXC);
 	temp_reg = IXGB_READ_REG(hw, RJC);
-	return;
 }
 
 /******************************************************************************
@@ -1066,7 +1057,6 @@ ixgb_led_on(struct ixgb_hw *hw)
 	/* To turn on the LED, clear software-definable pin 0 (SDP0). */
 	ctrl0_reg &= ~IXGB_CTRL0_SDP0;
 	IXGB_WRITE_REG(hw, CTRL0, ctrl0_reg);
-	return;
 }
 
 /******************************************************************************
@@ -1082,7 +1072,6 @@ ixgb_led_off(struct ixgb_hw *hw)
 	/* To turn off the LED, set software-definable pin 0 (SDP0). */
 	ctrl0_reg |= IXGB_CTRL0_SDP0;
 	IXGB_WRITE_REG(hw, CTRL0, ctrl0_reg);
-	return;
 }
 
 /******************************************************************************
@@ -1122,8 +1111,6 @@ ixgb_get_bus_info(struct ixgb_hw *hw)
 
 	hw->bus.width = (status_reg & IXGB_STATUS_BUS64) ?
 		ixgb_bus_width_64 : ixgb_bus_width_32;
-
-	return;
 }
 
 /******************************************************************************
@@ -1210,8 +1197,6 @@ ixgb_optics_reset(struct ixgb_hw *hw)
 					     IXGB_PHY_ADDRESS,
 					     MDIO_MMD_PMAPMD);
 	}
-
-	return;
 }
 
 /******************************************************************************
@@ -1272,6 +1257,4 @@ ixgb_optics_reset_bcm(struct ixgb_hw *hw)
 
 	/* SerDes needs extra delay */
 	msleep(IXGB_SUN_PHY_RESET_DELAY);
-
-	return;
 }
diff --git a/drivers/net/ixgbe/ixgbe_dcb_nl.c b/drivers/net/ixgbe/ixgbe_dcb_nl.c
index dd4883f..71da325 100644
--- a/drivers/net/ixgbe/ixgbe_dcb_nl.c
+++ b/drivers/net/ixgbe/ixgbe_dcb_nl.c
@@ -488,7 +488,6 @@ static void ixgbe_dcbnl_setpfcstate(struct net_device *netdev, u8 state)
 	if (adapter->temp_dcb_cfg.pfc_mode_enable !=
 		adapter->dcb_cfg.pfc_mode_enable)
 		adapter->dcb_set_bitmap |= BIT_PFC;
-	return;
 }
 
 /**
diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index dc7fd5b..251767d 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -1493,8 +1493,6 @@ static void ixgbe_free_desc_rings(struct ixgbe_adapter *adapter)
 	tx_ring->tx_buffer_info = NULL;
 	kfree(rx_ring->rx_buffer_info);
 	rx_ring->rx_buffer_info = NULL;
-
-	return;
 }
 
 static int ixgbe_setup_desc_rings(struct ixgbe_adapter *adapter)
@@ -1973,8 +1971,6 @@ static void ixgbe_get_wol(struct net_device *netdev,
 		wol->wolopts |= WAKE_BCAST;
 	if (adapter->wol & IXGBE_WUFC_MAG)
 		wol->wolopts |= WAKE_MAGIC;
-
-	return;
 }
 
 static int ixgbe_set_wol(struct net_device *netdev, struct ethtool_wolinfo *wol)
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index d1a1868..4846851 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -1611,8 +1611,6 @@ static void ixgbe_set_itr_msix(struct ixgbe_q_vector *q_vector)
 
 		ixgbe_write_eitr(q_vector);
 	}
-
-	return;
 }
 
 static void ixgbe_check_fan_failure(struct ixgbe_adapter *adapter, u32 eicr)
@@ -2176,8 +2174,6 @@ static void ixgbe_set_itr(struct ixgbe_adapter *adapter)
 
 		ixgbe_write_eitr(q_vector);
 	}
-
-	return;
 }
 
 /**
@@ -4461,7 +4457,6 @@ static void ixgbe_reset_interrupt_capability(struct ixgbe_adapter *adapter)
 		adapter->flags &= ~IXGBE_FLAG_MSI_ENABLED;
 		pci_disable_msi(adapter->pdev);
 	}
-	return;
 }
 
 /**
diff --git a/drivers/net/ixgbevf/ixgbevf_main.c b/drivers/net/ixgbevf/ixgbevf_main.c
index 40f47b8..a16cff7 100644
--- a/drivers/net/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ixgbevf/ixgbevf_main.c
@@ -946,8 +946,6 @@ static void ixgbevf_set_itr_msix(struct ixgbevf_q_vector *q_vector)
 		itr_reg = EITR_INTS_PER_SEC_TO_REG(new_itr);
 		ixgbevf_write_eitr(adapter, v_idx, itr_reg);
 	}
-
-	return;
 }
 
 static irqreturn_t ixgbevf_msix_mbx(int irq, void *data)
@@ -2151,8 +2149,6 @@ static void ixgbevf_reset_interrupt_capability(struct ixgbevf_adapter *adapter)
 	pci_disable_msix(adapter->pdev);
 	kfree(adapter->msix_entries);
 	adapter->msix_entries = NULL;
-
-	return;
 }
 
 /**
diff --git a/drivers/net/jme.c b/drivers/net/jme.c
index 4e868ee..4a09065 100644
--- a/drivers/net/jme.c
+++ b/drivers/net/jme.c
@@ -103,8 +103,6 @@ jme_mdio_write(struct net_device *netdev,
 
 	if (i == 0)
 		jeprintk(jme->pdev, "phy(%d) write timeout : %d\n", phy, reg);
-
-	return;
 }
 
 static inline void
@@ -130,8 +128,6 @@ jme_reset_phy_processor(struct jme_adapter *jme)
 	jme_mdio_write(jme->dev,
 			jme->mii_if.phy_id,
 			MII_BMCR, val | BMCR_RESET);
-
-	return;
 }
 
 static void
diff --git a/drivers/net/lib8390.c b/drivers/net/lib8390.c
index 64d51d6..316bb70 100644
--- a/drivers/net/lib8390.c
+++ b/drivers/net/lib8390.c
@@ -791,7 +791,6 @@ static void ei_receive(struct net_device *dev)
 	/* We used to also ack ENISR_OVER here, but that would sometimes mask
 	   a real overrun, leaving the 8390 in a stopped state with rec'vr off. */
 	ei_outb_p(ENISR_RX+ENISR_RX_ERR, e8390_base+EN0_ISR);
-	return;
 }
 
 /**
diff --git a/drivers/net/lne390.c b/drivers/net/lne390.c
index 41cbaae..8a1097c 100644
--- a/drivers/net/lne390.c
+++ b/drivers/net/lne390.c
@@ -307,8 +307,6 @@ static void lne390_reset_8390(struct net_device *dev)
 	ei_status.txing = 0;
 	outb(0x01, ioaddr + LNE390_RESET_PORT);
 	if (ei_debug > 1) printk("reset done\n");
-
-	return;
 }
 
 /*
diff --git a/drivers/net/mac8390.c b/drivers/net/mac8390.c
index c8e68fd..1136c9a 100644
--- a/drivers/net/mac8390.c
+++ b/drivers/net/mac8390.c
@@ -661,7 +661,6 @@ static void mac8390_no_reset(struct net_device *dev)
 	ei_status.txing = 0;
 	if (ei_debug > 1)
 		pr_info("reset not supported\n");
-	return;
 }
 
 static void interlan_reset(struct net_device *dev)
@@ -673,7 +672,6 @@ static void interlan_reset(struct net_device *dev)
 	target[0xC0000] = 0;
 	if (ei_debug > 1)
 		pr_cont("reset complete\n");
-	return;
 }
 
 /* dayna_memcpy_fromio/dayna_memcpy_toio */
diff --git a/drivers/net/meth.c b/drivers/net/meth.c
index 16a3594..42e3294 100644
--- a/drivers/net/meth.c
+++ b/drivers/net/meth.c
@@ -748,8 +748,6 @@ static void meth_tx_timeout(struct net_device *dev)
 
 	dev->trans_start = jiffies; /* prevent tx timeout */
 	netif_wake_queue(dev);
-
-	return;
 }
 
 /*
diff --git a/drivers/net/mlx4/en_cq.c b/drivers/net/mlx4/en_cq.c
index 21786ad..1851c17 100644
--- a/drivers/net/mlx4/en_cq.c
+++ b/drivers/net/mlx4/en_cq.c
@@ -39,7 +39,6 @@
 
 static void mlx4_en_cq_event(struct mlx4_cq *cq, enum mlx4_event event)
 {
-	return;
 }
 
 
diff --git a/drivers/net/mlx4/en_ethtool.c b/drivers/net/mlx4/en_ethtool.c
index 86467b4..d5afd03 100644
--- a/drivers/net/mlx4/en_ethtool.c
+++ b/drivers/net/mlx4/en_ethtool.c
@@ -140,8 +140,6 @@ static void mlx4_en_get_wol(struct net_device *netdev,
 {
 	wol->supported = 0;
 	wol->wolopts = 0;
-
-	return;
 }
 
 static int mlx4_en_get_sset_count(struct net_device *dev, int sset)
diff --git a/drivers/net/mlx4/en_resources.c b/drivers/net/mlx4/en_resources.c
index 0dfb4ec..264a764 100644
--- a/drivers/net/mlx4/en_resources.c
+++ b/drivers/net/mlx4/en_resources.c
@@ -97,6 +97,5 @@ void mlx4_en_unmap_buffer(struct mlx4_buf *buf)
 
 void mlx4_en_sqp_event(struct mlx4_qp *qp, enum mlx4_event event)
 {
-    return;
 }
 
diff --git a/drivers/net/ne-h8300.c b/drivers/net/ne-h8300.c
index 7bd6662..e0b0ef1 100644
--- a/drivers/net/ne-h8300.c
+++ b/drivers/net/ne-h8300.c
@@ -608,7 +608,6 @@ retry:
 
 	outb_p(ENISR_RDC, NE_BASE + EN0_ISR);	/* Ack intr. */
 	ei_status.dmaing &= ~0x01;
-	return;
 }
 
 
diff --git a/drivers/net/ne.c b/drivers/net/ne.c
index f4347f8..b8e2923 100644
--- a/drivers/net/ne.c
+++ b/drivers/net/ne.c
@@ -785,7 +785,6 @@ retry:
 
 	outb_p(ENISR_RDC, nic_base + EN0_ISR);	/* Ack intr. */
 	ei_status.dmaing &= ~0x01;
-	return;
 }
 
 static int __init ne_drv_probe(struct platform_device *pdev)
diff --git a/drivers/net/ne2.c b/drivers/net/ne2.c
index ff3c4c8..70cdc69 100644
--- a/drivers/net/ne2.c
+++ b/drivers/net/ne2.c
@@ -730,7 +730,6 @@ retry:
 
 	outb_p(ENISR_RDC, nic_base + EN0_ISR);	/* Ack intr. */
 	ei_status.dmaing &= ~0x01;
-	return;
 }
 
 
diff --git a/drivers/net/ne2k-pci.c b/drivers/net/ne2k-pci.c
index 85aec4f..3c333cb 100644
--- a/drivers/net/ne2k-pci.c
+++ b/drivers/net/ne2k-pci.c
@@ -631,7 +631,6 @@ static void ne2k_pci_block_output(struct net_device *dev, int count,
 
 	outb(ENISR_RDC, nic_base + EN0_ISR);	/* Ack intr. */
 	ei_status.dmaing &= ~0x01;
-	return;
 }
 
 static void ne2k_pci_get_drvinfo(struct net_device *dev,
diff --git a/drivers/net/ne3210.c b/drivers/net/ne3210.c
index a00bbfb..243ed2a 100644
--- a/drivers/net/ne3210.c
+++ b/drivers/net/ne3210.c
@@ -255,8 +255,6 @@ static void ne3210_reset_8390(struct net_device *dev)
 	ei_status.txing = 0;
 	outb(0x01, ioaddr + NE3210_RESET_PORT);
 	if (ei_debug > 1) printk("reset done\n");
-
-	return;
 }
 
 /*
diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index 388feaf..cdc3953 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -1899,6 +1899,5 @@ netxen_post_rx_buffers_nodb(struct netxen_adapter *adapter,
 void netxen_nic_clear_stats(struct netxen_adapter *adapter)
 {
 	memset(&adapter->stats, 0, sizeof(adapter->stats));
-	return;
 }
 
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index b665b42..557a6ca 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -2753,7 +2753,6 @@ netxen_config_indev_addr(struct net_device *dev, unsigned long event)
 	} endfor_ifa(indev);
 
 	in_dev_put(indev);
-	return;
 }
 
 static int netxen_netdev_event(struct notifier_block *this,
diff --git a/drivers/net/ni5010.c b/drivers/net/ni5010.c
index f80b501..4d3f2e2 100644
--- a/drivers/net/ni5010.c
+++ b/drivers/net/ni5010.c
@@ -514,8 +514,6 @@ static void dump_packet(void *buf, int len)
 		if (i % 16 == 15) printk("\n");
 	}
 	printk("\n");
-
-	return;
 }
 
 /* We have a good packet, get it out of the buffer. */
diff --git a/drivers/net/octeon/octeon_mgmt.c b/drivers/net/octeon/octeon_mgmt.c
index 43bf26f..000e792 100644
--- a/drivers/net/octeon/octeon_mgmt.c
+++ b/drivers/net/octeon/octeon_mgmt.c
@@ -1005,7 +1005,6 @@ static void octeon_mgmt_poll_controller(struct net_device *netdev)
 
 	octeon_mgmt_receive_packets(p, 16);
 	octeon_mgmt_update_rx_stats(netdev);
-	return;
 }
 #endif
 
diff --git a/drivers/net/pasemi_mac.c b/drivers/net/pasemi_mac.c
index 370c147..8ab6ae0 100644
--- a/drivers/net/pasemi_mac.c
+++ b/drivers/net/pasemi_mac.c
@@ -1472,8 +1472,6 @@ static void pasemi_mac_queue_csdesc(const struct sk_buff *skb,
 	txring->next_to_fill = fill;
 
 	write_dma_reg(PAS_DMA_TXCHAN_INCR(txring->chan.chno), 2);
-
-	return;
 }
 
 static int pasemi_mac_start_tx(struct sk_buff *skb, struct net_device *dev)
diff --git a/drivers/net/pcmcia/3c574_cs.c b/drivers/net/pcmcia/3c574_cs.c
index b6d9313..29d288e 100644
--- a/drivers/net/pcmcia/3c574_cs.c
+++ b/drivers/net/pcmcia/3c574_cs.c
@@ -622,8 +622,6 @@ static void mdio_write(unsigned int ioaddr, int phy_id, int location, int value)
 		outw(MDIO_ENB_IN, mdio_addr);
 		outw(MDIO_ENB_IN | MDIO_SHIFT_CLK, mdio_addr);
 	}
-
-	return;
 }
 
 /* Reset and restore all of the 3c574 registers. */
diff --git a/drivers/net/pcmcia/axnet_cs.c b/drivers/net/pcmcia/axnet_cs.c
index a1a6b08..d605db2 100644
--- a/drivers/net/pcmcia/axnet_cs.c
+++ b/drivers/net/pcmcia/axnet_cs.c
@@ -1510,8 +1510,6 @@ static void ei_receive(struct net_device *dev)
 		ei_local->current_page = next_frame;
 		outb_p(next_frame-1, e8390_base+EN0_BOUNDARY);
 	}
-
-	return;
 }
 
 /**
diff --git a/drivers/net/pcmcia/fmvj18x_cs.c b/drivers/net/pcmcia/fmvj18x_cs.c
index 16fc3e5..451a454 100644
--- a/drivers/net/pcmcia/fmvj18x_cs.c
+++ b/drivers/net/pcmcia/fmvj18x_cs.c
@@ -1081,8 +1081,6 @@ static void fjn_rx(struct net_device *dev)
 		  "%d ticks.\n", dev->name, inb(ioaddr + RX_MODE), i);
     }
 */
-
-    return;
 } /* fjn_rx */
 
 /*====================================================================*/
diff --git a/drivers/net/pcmcia/ibmtr_cs.c b/drivers/net/pcmcia/ibmtr_cs.c
index 37f4a6f..3b0754b 100644
--- a/drivers/net/pcmcia/ibmtr_cs.c
+++ b/drivers/net/pcmcia/ibmtr_cs.c
@@ -402,8 +402,6 @@ static void ibmtr_hw_setup(struct net_device *dev, u_int mmiobase)
 
     /* 0x40 will release the card for use */
     outb(0x40, dev->base_addr);
-
-    return;
 }
 
 static struct pcmcia_device_id ibmtr_ids[] = {
diff --git a/drivers/net/pcmcia/nmclan_cs.c b/drivers/net/pcmcia/nmclan_cs.c
index ca4efd2..89ba2f1 100644
--- a/drivers/net/pcmcia/nmclan_cs.c
+++ b/drivers/net/pcmcia/nmclan_cs.c
@@ -1313,8 +1313,6 @@ static void update_stats(unsigned int ioaddr, struct net_device *dev)
   lp->linux_stats.tx_fifo_errors = lp->mace_stats.uflo;
   lp->linux_stats.tx_heartbeat_errors = lp->mace_stats.cerr;
   /* lp->linux_stats.tx_window_errors; */
-
-  return;
 } /* update_stats */
 
 /* ----------------------------------------------------------------------------
diff --git a/drivers/net/pcmcia/smc91c92_cs.c b/drivers/net/pcmcia/smc91c92_cs.c
index b5c62db..7da544c 100644
--- a/drivers/net/pcmcia/smc91c92_cs.c
+++ b/drivers/net/pcmcia/smc91c92_cs.c
@@ -1239,7 +1239,6 @@ static void smc_hardware_send_packet(struct net_device * dev)
     dev_kfree_skb_irq(skb);
     dev->trans_start = jiffies;
     netif_start_queue(dev);
-    return;
 }
 
 /*====================================================================*/
@@ -1369,7 +1368,6 @@ static void smc_tx_err(struct net_device * dev)
     smc->packets_waiting--;
 
     outw(saved_packet, ioaddr + PNR_ARR);
-    return;
 }
 
 /*====================================================================*/
@@ -1589,8 +1587,6 @@ static void smc_rx(struct net_device *dev)
     }
     /* Let the MMU free the memory of this packet. */
     outw(MC_RELEASE, ioaddr + MMU_CMD);
-
-    return;
 }
 
 /*======================================================================
@@ -1640,8 +1636,6 @@ static void set_rx_mode(struct net_device *dev)
     outw(rx_cfg_setting, ioaddr + RCR);
     SMC_SELECT_BANK(2);
     spin_unlock_irqrestore(&smc->lock, flags);
-
-    return;
 }
 
 /*======================================================================
diff --git a/drivers/net/pcnet32.c b/drivers/net/pcnet32.c
index 566fd89..c200c28 100644
--- a/drivers/net/pcnet32.c
+++ b/drivers/net/pcnet32.c
@@ -647,7 +647,6 @@ free_new_rx_ring:
 			    (1 << size),
 			    new_rx_ring,
 			    new_ring_dma_addr);
-	return;
 }
 
 static void pcnet32_purge_rx_ring(struct net_device *dev)
@@ -1215,7 +1214,6 @@ static void pcnet32_rx_entry(struct net_device *dev,
 	skb->protocol = eth_type_trans(skb, dev);
 	netif_receive_skb(skb);
 	dev->stats.rx_packets++;
-	return;
 }
 
 static int pcnet32_rx(struct net_device *dev, int budget)
@@ -2623,7 +2621,6 @@ static void pcnet32_load_multicast(struct net_device *dev)
 	for (i = 0; i < 4; i++)
 		lp->a.write_csr(ioaddr, PCNET32_MC_FILTER + i,
 				le16_to_cpu(mcast_table[i]));
-	return;
 }
 
 /*
diff --git a/drivers/net/phy/national.c b/drivers/net/phy/national.c
index 729ab29..a73ba0b 100644
--- a/drivers/net/phy/national.c
+++ b/drivers/net/phy/national.c
@@ -97,7 +97,6 @@ static void ns_giga_speed_fallback(struct phy_device *phydev, int mode)
 	phy_write(phydev, NS_EXP_MEM_DATA, 0x0008);
 	phy_write(phydev, MII_BMCR, (bmcr & ~BMCR_PDOWN));
 	phy_write(phydev, LED_CTRL_REG, mode);
-	return;
 }
 
 static void ns_10_base_t_hdx_loopack(struct phy_device *phydev, int disable)
@@ -110,8 +109,6 @@ static void ns_10_base_t_hdx_loopack(struct phy_device *phydev, int disable)
 
 	printk(KERN_DEBUG "DP83865 PHY: 10BASE-T HDX loopback %s\n",
 	       (ns_exp_read(phydev, 0x1c0) & 0x0001) ? "off" : "on");
-
-	return;
 }
 
 static int ns_config_init(struct phy_device *phydev)
diff --git a/drivers/net/plip.c b/drivers/net/plip.c
index f4e1f9a..ec0349e 100644
--- a/drivers/net/plip.c
+++ b/drivers/net/plip.c
@@ -1191,8 +1191,6 @@ plip_wakeup(void *handle)
 		/* Clear the data port. */
 		write_data (dev, 0x00);
 	}
-
-	return;
 }
 
 static int
@@ -1308,7 +1306,6 @@ err_parport_unregister:
 	parport_unregister_device(nl->pardev);
 err_free_dev:
 	free_netdev(dev);
-	return;
 }
 
 /* plip_detach() is called (by the parport code) when a port is
diff --git a/drivers/net/ppp_mppe.c b/drivers/net/ppp_mppe.c
index 6d1a1b8..e5e9218 100644
--- a/drivers/net/ppp_mppe.c
+++ b/drivers/net/ppp_mppe.c
@@ -466,7 +466,6 @@ mppe_decomp_init(void *arg, unsigned char *options, int optlen, int unit,
 static void mppe_decomp_reset(void *arg)
 {
 	/* ARGSUSED */
-	return;
 }
 
 /*
diff --git a/drivers/net/ps3_gelic_wireless.c b/drivers/net/ps3_gelic_wireless.c
index d4ff627..a7bc406 100644
--- a/drivers/net/ps3_gelic_wireless.c
+++ b/drivers/net/ps3_gelic_wireless.c
@@ -301,7 +301,6 @@ static void gelic_wl_get_ch_info(struct gelic_wl_info *wl)
 			/* 16 bits of MSB has available channels */
 			wl->ch_info = ch_info_raw >> 48;
 	}
-	return;
 }
 
 /* SIOGIWRANGE */
diff --git a/drivers/net/qla3xxx.c b/drivers/net/qla3xxx.c
index 01a6ca3..54ebb65 100644
--- a/drivers/net/qla3xxx.c
+++ b/drivers/net/qla3xxx.c
@@ -222,7 +222,6 @@ static void ql_write_common_reg_l(struct ql3_adapter *qdev,
 	writel(value, reg);
 	readl(reg);
 	spin_unlock_irqrestore(&qdev->hw_lock, hw_flags);
-	return;
 }
 
 static void ql_write_common_reg(struct ql3_adapter *qdev,
@@ -230,7 +229,6 @@ static void ql_write_common_reg(struct ql3_adapter *qdev,
 {
 	writel(value, reg);
 	readl(reg);
-	return;
 }
 
 static void ql_write_nvram_reg(struct ql3_adapter *qdev,
@@ -239,7 +237,6 @@ static void ql_write_nvram_reg(struct ql3_adapter *qdev,
 	writel(value, reg);
 	readl(reg);
 	udelay(1);
-	return;
 }
 
 static void ql_write_page0_reg(struct ql3_adapter *qdev,
@@ -249,7 +246,6 @@ static void ql_write_page0_reg(struct ql3_adapter *qdev,
 		ql_set_register_page(qdev,0);
 	writel(value, reg);
 	readl(reg);
-	return;
 }
 
 /*
@@ -262,7 +258,6 @@ static void ql_write_page1_reg(struct ql3_adapter *qdev,
 		ql_set_register_page(qdev,1);
 	writel(value, reg);
 	readl(reg);
-	return;
 }
 
 /*
@@ -275,7 +270,6 @@ static void ql_write_page2_reg(struct ql3_adapter *qdev,
 		ql_set_register_page(qdev,2);
 	writel(value, reg);
 	readl(reg);
-	return;
 }
 
 static void ql_disable_interrupts(struct ql3_adapter *qdev)
diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index ee573fe..0a2d714 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -239,7 +239,6 @@ qlcnic_napi_disable(struct qlcnic_adapter *adapter)
 static void qlcnic_clear_stats(struct qlcnic_adapter *adapter)
 {
 	memset(&adapter->stats, 0, sizeof(adapter->stats));
-	return;
 }
 
 static int qlcnic_set_dma_mask(struct qlcnic_adapter *adapter)
@@ -2662,7 +2661,6 @@ qlcnic_config_indev_addr(struct net_device *dev, unsigned long event)
 	} endfor_ifa(indev);
 
 	in_dev_put(indev);
-	return;
 }
 
 static int qlcnic_netdev_event(struct notifier_block *this,
diff --git a/drivers/net/qlge/qlge_ethtool.c b/drivers/net/qlge/qlge_ethtool.c
index 7e09ff4..4892d64 100644
--- a/drivers/net/qlge/qlge_ethtool.c
+++ b/drivers/net/qlge/qlge_ethtool.c
@@ -181,8 +181,6 @@ quit:
 	spin_unlock(&qdev->stats_lock);
 
 	QL_DUMP_STAT(qdev);
-
-	return;
 }
 
 static char ql_stats_str_arr[][ETH_GSTRING_LEN] = {
diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index f155928..668327c 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -2943,7 +2943,6 @@ static void s2io_netpoll(struct net_device *dev)
 		}
 	}
 	enable_irq(dev->irq);
-	return;
 }
 #endif
 
@@ -4756,7 +4755,6 @@ reset:
 	s2io_stop_all_tx_queue(sp);
 	schedule_work(&sp->rst_timer_task);
 	sw_stat->soft_reset_cnt++;
-	return;
 }
 
 /**
@@ -8645,7 +8643,6 @@ static void lro_append_pkt(struct s2io_nic *sp, struct lro *lro,
 	first->truesize += skb->truesize;
 	lro->last_frag = skb;
 	swstats->clubbed_frms_cnt++;
-	return;
 }
 
 /**
diff --git a/drivers/net/sb1000.c b/drivers/net/sb1000.c
index abc8eef..a9ae505 100644
--- a/drivers/net/sb1000.c
+++ b/drivers/net/sb1000.c
@@ -426,7 +426,6 @@ sb1000_send_command(const int ioaddr[], const char* name,
 	if (sb1000_debug > 3)
 		printk(KERN_DEBUG "%s: sb1000_send_command out: %02x%02x%02x%02x"
 			"%02x%02x\n", name, out[0], out[1], out[2], out[3], out[4], out[5]);
-	return;
 }
 
 /* Card Read Status (to be used during frame rx) */
@@ -438,7 +437,6 @@ sb1000_read_status(const int ioaddr[], unsigned char in[])
 	in[3] = inb(ioaddr[0] + 3);
 	in[4] = inb(ioaddr[0] + 4);
 	in[0] = inb(ioaddr[0] + 5);
-	return;
 }
 
 /* Issue Read Command (to be used during frame rx) */
@@ -450,7 +448,6 @@ sb1000_issue_read_command(const int ioaddr[], const char* name)
 	sb1000_wait_for_ready_clear(ioaddr, name);
 	outb(0xa0, ioaddr[0] + 6);
 	sb1000_send_command(ioaddr, name, Command0);
-	return;
 }
 
 
@@ -733,7 +730,6 @@ sb1000_print_status_buffer(const char* name, unsigned char st[],
 			printk("\n");
 		}
 	}
-	return;
 }
 
 /*
@@ -926,7 +922,6 @@ sb1000_error_dpc(struct net_device *dev)
 	sb1000_read_status(ioaddr, st);
 	if (st[1] & 0x10)
 		lp->rx_error_dpc_count = ErrorDpcCounterInitialize;
-	return;
 }
 
 
diff --git a/drivers/net/seeq8005.c b/drivers/net/seeq8005.c
index 11ab32e..d2fce98 100644
--- a/drivers/net/seeq8005.c
+++ b/drivers/net/seeq8005.c
@@ -578,7 +578,6 @@ static void seeq8005_rx(struct net_device *dev)
 	/* If any worth-while packets have been received, netif_rx()
 	   has done a mark_bh(NET_BH) for us and will work on them
 	   when we get to the bottom-half routine. */
-	return;
 }
 
 /* The inverse routine to net_open(). */
diff --git a/drivers/net/sis900.c b/drivers/net/sis900.c
index 11f7ebe..bbbded7 100644
--- a/drivers/net/sis900.c
+++ b/drivers/net/sis900.c
@@ -858,7 +858,6 @@ static void mdio_reset(long mdio_addr)
 		outl(MDDIR | MDIO | MDC, mdio_addr);
 		mdio_delay();
 	}
-	return;
 }
 
 /**
@@ -953,8 +952,6 @@ static void mdio_write(struct net_device *net_dev, int phy_id, int location,
 		mdio_delay();
 	}
 	outl(0x00, mdio_addr);
-
-	return;
 }
 
 
@@ -1264,7 +1261,6 @@ static void sis630_set_eq(struct net_device *net_dev, u8 revision)
 			mdio_write(net_dev, sis_priv->cur_phy, MII_RESV,
 						(reg14h | 0x2000) & 0xBFFF);
 	}
-	return;
 }
 
 /**
@@ -1560,7 +1556,6 @@ static void sis900_tx_timeout(struct net_device *net_dev)
 
 	/* Enable all known interrupts by setting the interrupt mask. */
 	outl((RxSOVR|RxORN|RxERR|RxOK|TxURN|TxERR|TxIDLE), ioaddr + imr);
-	return;
 }
 
 /**
@@ -2330,8 +2325,6 @@ static void set_rx_mode(struct net_device *net_dev)
 		/* restore cr */
 		outl(cr_saved, ioaddr + cr);
 	}
-
-	return;
 }
 
 /**
diff --git a/drivers/net/skfp/skfddi.c b/drivers/net/skfp/skfddi.c
index 91adc38..31b2dab 100644
--- a/drivers/net/skfp/skfddi.c
+++ b/drivers/net/skfp/skfddi.c
@@ -844,7 +844,6 @@ static void skfp_ctl_set_multicast_list(struct net_device *dev)
 	spin_lock_irqsave(&bp->DriverLock, Flags);
 	skfp_ctl_set_multicast_list_wo_lock(dev);
 	spin_unlock_irqrestore(&bp->DriverLock, Flags);
-	return;
 }				// skfp_ctl_set_multicast_list
 
 
@@ -898,7 +897,6 @@ static void skfp_ctl_set_multicast_list_wo_lock(struct net_device *dev)
 		/* Update adapter filters */
 		mac_update_multicast(smc);
 	}
-	return;
 }				// skfp_ctl_set_multicast_list_wo_lock
 
 
diff --git a/drivers/net/slhc.c b/drivers/net/slhc.c
index 140d63f..ac279fa 100644
--- a/drivers/net/slhc.c
+++ b/drivers/net/slhc.c
@@ -731,7 +731,6 @@ void
 slhc_free(struct slcompress *comp)
 {
   printk(KERN_DEBUG "Called IP function on non IP-system: slhc_free");
-  return;
 }
 struct slcompress *
 slhc_init(int rslots, int tslots)
diff --git a/drivers/net/smc-mca.c b/drivers/net/smc-mca.c
index a93f122..d07c39c 100644
--- a/drivers/net/smc-mca.c
+++ b/drivers/net/smc-mca.c
@@ -460,7 +460,6 @@ static void ultramca_reset_8390(struct net_device *dev)
 
 	if (ei_debug > 1)
 		printk("reset done\n");
-	return;
 }
 
 /* Grab the 8390 specific header. Similar to the block_input routine, but
diff --git a/drivers/net/smc-ultra.c b/drivers/net/smc-ultra.c
index 0291ea0..d2dd8e6 100644
--- a/drivers/net/smc-ultra.c
+++ b/drivers/net/smc-ultra.c
@@ -421,7 +421,6 @@ ultra_reset_8390(struct net_device *dev)
 		outb(0x01, cmd_port + 6);		/* Enable interrupts and memory. */
 
 	if (ei_debug > 1) printk("reset done\n");
-	return;
 }
 
 /* Grab the 8390 specific header. Similar to the block_input routine, but
diff --git a/drivers/net/smc-ultra32.c b/drivers/net/smc-ultra32.c
index 7a554ad..e459c3b 100644
--- a/drivers/net/smc-ultra32.c
+++ b/drivers/net/smc-ultra32.c
@@ -352,7 +352,6 @@ static void ultra32_reset_8390(struct net_device *dev)
 	outb(0x84, ioaddr + 5);	/* Enable MEM16 & Disable Bus Master. */
 	outb(0x01, ioaddr + 6);	/* Enable Interrupts. */
 	if (ei_debug > 1) printk("reset done\n");
-	return;
 }
 
 /* Grab the 8390 specific header. Similar to the block_input routine, but
diff --git a/drivers/net/smc9194.c b/drivers/net/smc9194.c
index acb81a8..7486d09 100644
--- a/drivers/net/smc9194.c
+++ b/drivers/net/smc9194.c
@@ -691,8 +691,6 @@ static void smc_hardware_send_packet( struct net_device * dev )
 
 	/* we can send another packet */
 	netif_wake_queue(dev);
-
-	return;
 }
 
 /*-------------------------------------------------------------------------
@@ -1355,7 +1353,6 @@ static void smc_tx( struct net_device * dev )
 	lp->packets_waiting--;
 
 	outb( saved_packet, ioaddr + PNR_ARR );
-	return;
 }
 
 /*--------------------------------------------------------------------
diff --git a/drivers/net/spider_net.c b/drivers/net/spider_net.c
index 3dff280..1636a34 100644
--- a/drivers/net/spider_net.c
+++ b/drivers/net/spider_net.c
@@ -2095,8 +2095,6 @@ static void spider_net_link_phy(unsigned long data)
 		card->netdev->name, phy->speed,
 		phy->duplex == 1 ? "Full" : "Half",
 		phy->autoneg == 1 ? "" : "no ");
-
-	return;
 }
 
 /**
diff --git a/drivers/net/starfire.c b/drivers/net/starfire.c
index e19b5a1..74b7ae7 100644
--- a/drivers/net/starfire.c
+++ b/drivers/net/starfire.c
@@ -1221,8 +1221,6 @@ static void init_ring(struct net_device *dev)
 
 	for (i = 0; i < TX_RING_SIZE; i++)
 		memset(&np->tx_info[i], 0, sizeof(np->tx_info[i]));
-
-	return;
 }
 
 
diff --git a/drivers/net/stmmac/dwmac1000_core.c b/drivers/net/stmmac/dwmac1000_core.c
index 0aa89ae..917b4e1 100644
--- a/drivers/net/stmmac/dwmac1000_core.c
+++ b/drivers/net/stmmac/dwmac1000_core.c
@@ -48,7 +48,6 @@ static void dwmac1000_core_init(unsigned long ioaddr)
 	/* Tag detection without filtering */
 	writel(0x0, ioaddr + GMAC_VLAN_TAG);
 #endif
-	return;
 }
 
 static void dwmac1000_dump_regs(unsigned long ioaddr)
@@ -61,7 +60,6 @@ static void dwmac1000_dump_regs(unsigned long ioaddr)
 		pr_info("\tReg No. %d (offset 0x%x): 0x%08x\n", i,
 			offset, readl(ioaddr + offset));
 	}
-	return;
 }
 
 static void dwmac1000_set_umac_addr(unsigned long ioaddr, unsigned char *addr,
@@ -139,8 +137,6 @@ static void dwmac1000_set_filter(struct net_device *dev)
 	CHIP_DBG(KERN_INFO "\tFrame Filter reg: 0x%08x\n\tHash regs: "
 	    "HI 0x%08x, LO 0x%08x\n", readl(ioaddr + GMAC_FRAME_FILTER),
 	    readl(ioaddr + GMAC_HASH_HIGH), readl(ioaddr + GMAC_HASH_LOW));
-
-	return;
 }
 
 static void dwmac1000_flow_ctrl(unsigned long ioaddr, unsigned int duplex,
@@ -164,7 +160,6 @@ static void dwmac1000_flow_ctrl(unsigned long ioaddr, unsigned int duplex,
 	}
 
 	writel(flow, ioaddr + GMAC_FLOW_CTRL);
-	return;
 }
 
 static void dwmac1000_pmt(unsigned long ioaddr, unsigned long mode)
@@ -180,7 +175,6 @@ static void dwmac1000_pmt(unsigned long ioaddr, unsigned long mode)
 	}
 
 	writel(pmt, ioaddr + GMAC_PMT);
-	return;
 }
 
 
@@ -204,8 +198,6 @@ static void dwmac1000_irq_status(unsigned long ioaddr)
 		 * status register. */
 		readl(ioaddr + GMAC_PMT);
 	}
-
-	return;
 }
 
 struct stmmac_ops dwmac1000_ops = {
diff --git a/drivers/net/stmmac/dwmac1000_dma.c b/drivers/net/stmmac/dwmac1000_dma.c
index a547aa9..7f1f185 100644
--- a/drivers/net/stmmac/dwmac1000_dma.c
+++ b/drivers/net/stmmac/dwmac1000_dma.c
@@ -107,14 +107,12 @@ static void dwmac1000_dma_operation_mode(unsigned long ioaddr, int txmode,
 	}
 
 	writel(csr6, ioaddr + DMA_CONTROL);
-	return;
 }
 
 /* Not yet implemented --- no RMON module */
 static void dwmac1000_dma_diagnostic_fr(void *data,
 		  struct stmmac_extra_stats *x, unsigned long ioaddr)
 {
-	return;
 }
 
 static void dwmac1000_dump_dma_regs(unsigned long ioaddr)
@@ -129,7 +127,6 @@ static void dwmac1000_dump_dma_regs(unsigned long ioaddr)
 			       readl(ioaddr + DMA_BUS_MODE + offset));
 		}
 	}
-	return;
 }
 
 struct stmmac_dma_ops dwmac1000_dma_ops = {
diff --git a/drivers/net/stmmac/dwmac100_core.c b/drivers/net/stmmac/dwmac100_core.c
index fab14a4..f1b8c24 100644
--- a/drivers/net/stmmac/dwmac100_core.c
+++ b/drivers/net/stmmac/dwmac100_core.c
@@ -40,7 +40,6 @@ static void dwmac100_core_init(unsigned long ioaddr)
 #ifdef STMMAC_VLAN_TAG_USED
 	writel(ETH_P_8021Q, ioaddr + MAC_VLAN1);
 #endif
-	return;
 }
 
 static void dwmac100_dump_mac_regs(unsigned long ioaddr)
@@ -76,12 +75,10 @@ static void dwmac100_dump_mac_regs(unsigned long ioaddr)
 		MMC_HIGH_INTR_MASK, readl(ioaddr + MMC_HIGH_INTR_MASK));
 	pr_info("\t MMC Low Interrupt Mask (offset 0x%x): 0x%08x\n",
 		MMC_LOW_INTR_MASK, readl(ioaddr + MMC_LOW_INTR_MASK));
-	return;
 }
 
 static void dwmac100_irq_status(unsigned long ioaddr)
 {
-	return;
 }
 
 static void dwmac100_set_umac_addr(unsigned long ioaddr, unsigned char *addr,
@@ -145,7 +142,6 @@ static void dwmac100_set_filter(struct net_device *dev)
 	    "HI 0x%08x, LO 0x%08x\n",
 	    __func__, readl(ioaddr + MAC_CONTROL),
 	    readl(ioaddr + MAC_HASH_HIGH), readl(ioaddr + MAC_HASH_LOW));
-	return;
 }
 
 static void dwmac100_flow_ctrl(unsigned long ioaddr, unsigned int duplex,
@@ -156,8 +152,6 @@ static void dwmac100_flow_ctrl(unsigned long ioaddr, unsigned int duplex,
 	if (duplex)
 		flow |= (pause_time << MAC_FLOW_CTRL_PT_SHIFT);
 	writel(flow, ioaddr + MAC_FLOW_CTRL);
-
-	return;
 }
 
 /* No PMT module supported for this Ethernet Controller.
@@ -165,7 +159,6 @@ static void dwmac100_flow_ctrl(unsigned long ioaddr, unsigned int duplex,
  */
 static void dwmac100_pmt(unsigned long ioaddr, unsigned long mode)
 {
-	return;
 }
 
 struct stmmac_ops dwmac100_ops = {
diff --git a/drivers/net/stmmac/dwmac100_dma.c b/drivers/net/stmmac/dwmac100_dma.c
index 96d098d..2fece7b 100644
--- a/drivers/net/stmmac/dwmac100_dma.c
+++ b/drivers/net/stmmac/dwmac100_dma.c
@@ -71,8 +71,6 @@ static void dwmac100_dma_operation_mode(unsigned long ioaddr, int txmode,
 		csr6 |= DMA_CONTROL_TTC_128;
 
 	writel(csr6, ioaddr + DMA_CONTROL);
-
-	return;
 }
 
 static void dwmac100_dump_dma_regs(unsigned long ioaddr)
@@ -88,7 +86,6 @@ static void dwmac100_dump_dma_regs(unsigned long ioaddr)
 	    DMA_CUR_TX_BUF_ADDR, readl(ioaddr + DMA_CUR_TX_BUF_ADDR));
 	CHIP_DBG(KERN_DEBUG "\t CSR21 (offset 0x%x): 0x%08x\n",
 	    DMA_CUR_RX_BUF_ADDR, readl(ioaddr + DMA_CUR_RX_BUF_ADDR));
-	return;
 }
 
 /* DMA controller has two counters to track the number of
@@ -119,7 +116,6 @@ static void dwmac100_dma_diagnostic_fr(void *data, struct stmmac_extra_stats *x,
 			x->rx_missed_cntr += miss_f;
 		}
 	}
-	return;
 }
 
 struct stmmac_dma_ops dwmac100_dma_ops = {
diff --git a/drivers/net/stmmac/dwmac_lib.c b/drivers/net/stmmac/dwmac_lib.c
index 0a504ad..a854152 100644
--- a/drivers/net/stmmac/dwmac_lib.c
+++ b/drivers/net/stmmac/dwmac_lib.c
@@ -52,7 +52,6 @@ void dwmac_dma_start_tx(unsigned long ioaddr)
 	u32 value = readl(ioaddr + DMA_CONTROL);
 	value |= DMA_CONTROL_ST;
 	writel(value, ioaddr + DMA_CONTROL);
-	return;
 }
 
 void dwmac_dma_stop_tx(unsigned long ioaddr)
@@ -60,7 +59,6 @@ void dwmac_dma_stop_tx(unsigned long ioaddr)
 	u32 value = readl(ioaddr + DMA_CONTROL);
 	value &= ~DMA_CONTROL_ST;
 	writel(value, ioaddr + DMA_CONTROL);
-	return;
 }
 
 void dwmac_dma_start_rx(unsigned long ioaddr)
@@ -68,8 +66,6 @@ void dwmac_dma_start_rx(unsigned long ioaddr)
 	u32 value = readl(ioaddr + DMA_CONTROL);
 	value |= DMA_CONTROL_SR;
 	writel(value, ioaddr + DMA_CONTROL);
-
-	return;
 }
 
 void dwmac_dma_stop_rx(unsigned long ioaddr)
@@ -77,8 +73,6 @@ void dwmac_dma_stop_rx(unsigned long ioaddr)
 	u32 value = readl(ioaddr + DMA_CONTROL);
 	value &= ~DMA_CONTROL_SR;
 	writel(value, ioaddr + DMA_CONTROL);
-
-	return;
 }
 
 #ifdef DWMAC_DMA_DEBUG
@@ -111,7 +105,6 @@ static void show_tx_process_state(unsigned int status)
 	default:
 		break;
 	}
-	return;
 }
 
 static void show_rx_process_state(unsigned int status)
@@ -149,7 +142,6 @@ static void show_rx_process_state(unsigned int status)
 	default:
 		break;
 	}
-	return;
 }
 #endif
 
@@ -244,8 +236,6 @@ void stmmac_set_mac_addr(unsigned long ioaddr, u8 addr[6],
 	writel(data, ioaddr + high);
 	data = (addr[3] << 24) | (addr[2] << 16) | (addr[1] << 8) | addr[0];
 	writel(data, ioaddr + low);
-
-	return;
 }
 
 void stmmac_get_mac_addr(unsigned long ioaddr, unsigned char *addr,
@@ -264,7 +254,5 @@ void stmmac_get_mac_addr(unsigned long ioaddr, unsigned char *addr,
 	addr[3] = (lo_addr >> 24) & 0xff;
 	addr[4] = hi_addr & 0xff;
 	addr[5] = (hi_addr >> 8) & 0xff;
-
-	return;
 }
 
diff --git a/drivers/net/stmmac/enh_desc.c b/drivers/net/stmmac/enh_desc.c
index eb5684a..3c18ebe 100644
--- a/drivers/net/stmmac/enh_desc.c
+++ b/drivers/net/stmmac/enh_desc.c
@@ -241,7 +241,6 @@ static void enh_desc_init_rx_desc(struct dma_desc *p, unsigned int ring_size,
 			p->des01.erx.disable_ic = 1;
 		p++;
 	}
-	return;
 }
 
 static void enh_desc_init_tx_desc(struct dma_desc *p, unsigned int ring_size)
@@ -254,8 +253,6 @@ static void enh_desc_init_tx_desc(struct dma_desc *p, unsigned int ring_size)
 			p->des01.etx.end_ring = 1;
 		p++;
 	}
-
-	return;
 }
 
 static int enh_desc_get_tx_owner(struct dma_desc *p)
@@ -289,8 +286,6 @@ static void enh_desc_release_tx_desc(struct dma_desc *p)
 
 	memset(p, 0, sizeof(struct dma_desc));
 	p->des01.etx.end_ring = ter;
-
-	return;
 }
 
 static void enh_desc_prepare_tx_desc(struct dma_desc *p, int is_fs, int len,
diff --git a/drivers/net/stmmac/norm_desc.c b/drivers/net/stmmac/norm_desc.c
index ecfcc00..31ad536 100644
--- a/drivers/net/stmmac/norm_desc.c
+++ b/drivers/net/stmmac/norm_desc.c
@@ -132,7 +132,6 @@ static void ndesc_init_rx_desc(struct dma_desc *p, unsigned int ring_size,
 			p->des01.rx.disable_ic = 1;
 		p++;
 	}
-	return;
 }
 
 static void ndesc_init_tx_desc(struct dma_desc *p, unsigned int ring_size)
@@ -144,7 +143,6 @@ static void ndesc_init_tx_desc(struct dma_desc *p, unsigned int ring_size)
 			p->des01.tx.end_ring = 1;
 		p++;
 	}
-	return;
 }
 
 static int ndesc_get_tx_owner(struct dma_desc *p)
@@ -194,8 +192,6 @@ static void ndesc_release_tx_desc(struct dma_desc *p)
 
 	/* set termination field */
 	p->des01.tx.end_ring = ter;
-
-	return;
 }
 
 static void ndesc_prepare_tx_desc(struct dma_desc *p, int is_fs, int len,
diff --git a/drivers/net/stmmac/stmmac_ethtool.c b/drivers/net/stmmac/stmmac_ethtool.c
index c021eaa..f080509 100644
--- a/drivers/net/stmmac/stmmac_ethtool.c
+++ b/drivers/net/stmmac/stmmac_ethtool.c
@@ -102,7 +102,6 @@ void stmmac_ethtool_getdrvinfo(struct net_device *dev,
 	strcpy(info->version, DRV_MODULE_VERSION);
 	info->fw_version[0] = '\0';
 	info->n_stats = STMMAC_STATS_LEN;
-	return;
 }
 
 int stmmac_ethtool_getsettings(struct net_device *dev, struct ethtool_cmd *cmd)
@@ -194,8 +193,6 @@ void stmmac_ethtool_gregs(struct net_device *dev,
 			reg_space[i + 55] =
 			    readl(dev->base_addr + (DMA_BUS_MODE + (i * 4)));
 	}
-
-	return;
 }
 
 int stmmac_ethtool_set_tx_csum(struct net_device *netdev, u32 data)
@@ -233,7 +230,6 @@ stmmac_get_pauseparam(struct net_device *netdev,
 		pause->tx_pause = 1;
 
 	spin_unlock(&priv->lock);
-	return;
 }
 
 static int
@@ -292,8 +288,6 @@ static void stmmac_get_ethtool_stats(struct net_device *dev,
 		data[i] = (stmmac_gstrings_stats[i].sizeof_stat ==
 		sizeof(u64)) ? (*(u64 *)p) : (*(u32 *)p);
 	}
-
-	return;
 }
 
 static int stmmac_get_sset_count(struct net_device *netdev, int sset)
@@ -323,7 +317,6 @@ static void stmmac_get_strings(struct net_device *dev, u32 stringset, u8 *data)
 		WARN_ON(1);
 		break;
 	}
-	return;
 }
 
 /* Currently only support WOL through Magic packet. */
diff --git a/drivers/net/stmmac/stmmac_main.c b/drivers/net/stmmac/stmmac_main.c
index 7ac6dde..a31d580 100644
--- a/drivers/net/stmmac/stmmac_main.c
+++ b/drivers/net/stmmac/stmmac_main.c
@@ -169,8 +169,6 @@ static void stmmac_verify_args(void)
 		flow_ctrl = FLOW_OFF;
 	if (unlikely((pause < 0) || (pause > 0xffff)))
 		pause = PAUSE_TIME;
-
-	return;
 }
 
 #if defined(STMMAC_XMIT_DEBUG) || defined(STMMAC_RX_DEBUG)
@@ -184,7 +182,6 @@ static void print_pkt(unsigned char *buf, int len)
 		pr_info(" %02x", buf[j]);
 	}
 	pr_info("\n");
-	return;
 }
 #endif
 
@@ -514,7 +511,6 @@ static void init_dma_desc_rings(struct net_device *dev)
 		pr_info("TX descriptor ring:\n");
 		display_ring(priv->dma_tx, txsize);
 	}
-	return;
 }
 
 static void dma_free_rx_skbufs(struct stmmac_priv *priv)
@@ -529,7 +525,6 @@ static void dma_free_rx_skbufs(struct stmmac_priv *priv)
 		}
 		priv->rx_skbuff[i] = NULL;
 	}
-	return;
 }
 
 static void dma_free_tx_skbufs(struct stmmac_priv *priv)
@@ -547,7 +542,6 @@ static void dma_free_tx_skbufs(struct stmmac_priv *priv)
 			priv->tx_skbuff[i] = NULL;
 		}
 	}
-	return;
 }
 
 static void free_dma_desc_resources(struct stmmac_priv *priv)
@@ -567,8 +561,6 @@ static void free_dma_desc_resources(struct stmmac_priv *priv)
 	kfree(priv->rx_skbuff_dma);
 	kfree(priv->rx_skbuff);
 	kfree(priv->tx_skbuff);
-
-	return;
 }
 
 /**
@@ -598,8 +590,6 @@ static void stmmac_dma_operation_mode(struct stmmac_priv *priv)
 		}
 	}
 	tx_coe = priv->tx_coe;
-
-	return;
 }
 
 /**
@@ -675,7 +665,6 @@ static void stmmac_tx(struct stmmac_priv *priv)
 		}
 		netif_tx_unlock(priv->dev);
 	}
-	return;
 }
 
 static inline void stmmac_enable_irq(struct stmmac_priv *priv)
@@ -731,8 +720,6 @@ void stmmac_schedule(struct net_device *dev)
 	priv->xstats.sched_timer_n++;
 
 	_stmmac_schedule(priv);
-
-	return;
 }
 
 static void stmmac_no_timer_started(unsigned int x)
@@ -763,8 +750,6 @@ static void stmmac_tx_err(struct stmmac_priv *priv)
 
 	priv->dev->stats.tx_errors++;
 	netif_wake_queue(priv->dev);
-
-	return;
 }
 
 
@@ -788,8 +773,6 @@ static void stmmac_dma_interrupt(struct stmmac_priv *priv)
 		stmmac_tx_err(priv);
 	} else if (unlikely(status == tx_hard_error))
 		stmmac_tx_err(priv);
-
-	return;
 }
 
 /**
@@ -1197,7 +1180,6 @@ static inline void stmmac_rx_refill(struct stmmac_priv *priv)
 		}
 		priv->hw->desc->set_rx_owner(p + entry);
 	}
-	return;
 }
 
 static int stmmac_rx(struct stmmac_priv *priv, int limit)
@@ -1331,7 +1313,6 @@ static void stmmac_tx_timeout(struct net_device *dev)
 
 	/* Clear Tx resources and restart transmitting again */
 	stmmac_tx_err(priv);
-	return;
 }
 
 /* Configuration changes (passed on by ifconfig) */
@@ -1373,7 +1354,6 @@ static void stmmac_multicast_list(struct net_device *dev)
 	spin_lock(&priv->lock);
 	priv->hw->mac->set_filter(dev);
 	spin_unlock(&priv->lock);
-	return;
 }
 
 /**
@@ -1489,8 +1469,6 @@ static void stmmac_vlan_rx_register(struct net_device *dev,
 	spin_lock(&priv->lock);
 	priv->vlgrp = grp;
 	spin_unlock(&priv->lock);
-
-	return;
 }
 #endif
 
diff --git a/drivers/net/stmmac/stmmac_timer.c b/drivers/net/stmmac/stmmac_timer.c
index 679f61f..2a0e1ab 100644
--- a/drivers/net/stmmac/stmmac_timer.c
+++ b/drivers/net/stmmac/stmmac_timer.c
@@ -31,8 +31,6 @@ static void stmmac_timer_handler(void *data)
 	struct net_device *dev = (struct net_device *)data;
 
 	stmmac_schedule(dev);
-
-	return;
 }
 
 #define STMMAC_TIMER_MSG(timer, freq) \
@@ -47,13 +45,11 @@ static void stmmac_rtc_start(unsigned int new_freq)
 {
 	rtc_irq_set_freq(stmmac_rtc, &stmmac_task, new_freq);
 	rtc_irq_set_state(stmmac_rtc, &stmmac_task, 1);
-	return;
 }
 
 static void stmmac_rtc_stop(void)
 {
 	rtc_irq_set_state(stmmac_rtc, &stmmac_task, 0);
-	return;
 }
 
 int stmmac_open_ext_timer(struct net_device *dev, struct stmmac_timer *tm)
@@ -102,13 +98,11 @@ static void stmmac_tmu_start(unsigned int new_freq)
 {
 	clk_set_rate(timer_clock, new_freq);
 	clk_enable(timer_clock);
-	return;
 }
 
 static void stmmac_tmu_stop(void)
 {
 	clk_disable(timer_clock);
-	return;
 }
 
 int stmmac_open_ext_timer(struct net_device *dev, struct stmmac_timer *tm)
diff --git a/drivers/net/stnic.c b/drivers/net/stnic.c
index 87a6b8e..d85f0a8 100644
--- a/drivers/net/stnic.c
+++ b/drivers/net/stnic.c
@@ -280,7 +280,6 @@ stnic_init (struct net_device *dev)
 {
   stnic_reset (dev);
   NS8390_init (dev, 0);
-  return;
 }
 
 static void __exit stnic_cleanup(void)
diff --git a/drivers/net/sundance.c b/drivers/net/sundance.c
index 1680325..2678588 100644
--- a/drivers/net/sundance.c
+++ b/drivers/net/sundance.c
@@ -788,7 +788,6 @@ static void mdio_write(struct net_device *dev, int phy_id, int location, int val
 		iowrite8(MDIO_EnbIn | MDIO_ShiftClk, mdio_addr);
 		mdio_delay();
 	}
-	return;
 }
 
 static int mdio_wait_link(struct net_device *dev, int wait)
@@ -1022,7 +1021,6 @@ static void init_ring(struct net_device *dev)
 		np->tx_skbuff[i] = NULL;
 		np->tx_ring[i].status = 0;
 	}
-	return;
 }
 
 static void tx_poll (unsigned long data)
@@ -1049,7 +1047,6 @@ static void tx_poll (unsigned long data)
 	if (ioread32 (np->base + TxListPtr) == 0)
 		iowrite32 (np->tx_ring_dma + head * sizeof(struct netdev_desc),
 			np->base + TxListPtr);
-	return;
 }
 
 static netdev_tx_t
@@ -1378,7 +1375,6 @@ not_done:
 	if (np->budget <= 0)
 		np->budget = RX_BUDGET;
 	tasklet_schedule(&np->rx_tasklet);
-	return;
 }
 
 static void refill_rx (struct net_device *dev)
@@ -1409,7 +1405,6 @@ static void refill_rx (struct net_device *dev)
 		np->rx_ring[entry].status = 0;
 		cnt++;
 	}
-	return;
 }
 static void netdev_error(struct net_device *dev, int intr_status)
 {
diff --git a/drivers/net/sungem.c b/drivers/net/sungem.c
index 5bc786f..434f9d7 100644
--- a/drivers/net/sungem.c
+++ b/drivers/net/sungem.c
@@ -2923,7 +2923,6 @@ static void get_gem_mac_nonobp(struct pci_dev *pdev, unsigned char *dev_addr)
 	dev_addr[1] = 0x00;
 	dev_addr[2] = 0x20;
 	get_random_bytes(dev_addr + 3, 3);
-	return;
 }
 #endif /* not Sparc and not PPC */
 
diff --git a/drivers/net/sunhme.c b/drivers/net/sunhme.c
index 377c0b5..30826eb 100644
--- a/drivers/net/sunhme.c
+++ b/drivers/net/sunhme.c
@@ -2943,7 +2943,6 @@ static void get_hme_mac_nonsparc(struct pci_dev *pdev, unsigned char *dev_addr)
 	dev_addr[1] = 0x00;
 	dev_addr[2] = 0x20;
 	get_random_bytes(&dev_addr[3], 3);
-	return;
 }
 #endif /* !(CONFIG_SPARC) */
 
diff --git a/drivers/net/tokenring/madgemc.c b/drivers/net/tokenring/madgemc.c
index 53f631e..785ad1a 100644
--- a/drivers/net/tokenring/madgemc.c
+++ b/drivers/net/tokenring/madgemc.c
@@ -109,7 +109,6 @@ static void madgemc_sifwriteb(struct net_device *dev, unsigned short val, unsign
 		SIFWRITEB(val, reg);
 		madgemc_setregpage(dev, 0);
 	}
-	return;
 }
 
 /*
@@ -140,7 +139,6 @@ static void madgemc_sifwritew(struct net_device *dev, unsigned short val, unsign
 		SIFWRITEW(val, reg);
 		madgemc_setregpage(dev, 0);
 	}
-	return;
 }
 
 static struct net_device_ops madgemc_netdev_ops __read_mostly;
@@ -505,8 +503,6 @@ static void madgemc_setregpage(struct net_device *dev, int page)
 		     dev->base_addr + MC_CONTROL_REG1);
 	}
 	reg1 = inb(dev->base_addr + MC_CONTROL_REG1);
-
-	return;
 }
 
 /*
@@ -527,8 +523,6 @@ static void madgemc_setsifsel(struct net_device *dev, int val)
 		     dev->base_addr + MC_CONTROL_REG0);
 	}	
 	reg0 = inb(dev->base_addr + MC_CONTROL_REG0);
-
-	return;
 }
 
 /*
@@ -550,8 +544,6 @@ static void madgemc_setint(struct net_device *dev, int val)
 		outb(reg1 | MC_CONTROL_REG1_SINTEN, 
 		     dev->base_addr + MC_CONTROL_REG1);
 	}
-
-	return;
 }
 
 /*
@@ -594,8 +586,6 @@ static void madgemc_chipset_close(struct net_device *dev)
 	madgemc_setint(dev, 0);
 	/* unmap SIF registers */
 	madgemc_setsifsel(dev, 0);
-
-	return;
 }
 
 /*
@@ -656,8 +646,6 @@ static void madgemc_read_rom(struct net_device *dev, struct card_info *card)
 	/* Restore original register values */
 	outb(reg0, ioaddr + MC_CONTROL_REG0);
 	outb(reg1, ioaddr + MC_CONTROL_REG1);
-	
-	return;
 }
 
 static int madgemc_open(struct net_device *dev)
diff --git a/drivers/net/tokenring/smctr.c b/drivers/net/tokenring/smctr.c
index 213b9af..0929fff 100644
--- a/drivers/net/tokenring/smctr.c
+++ b/drivers/net/tokenring/smctr.c
@@ -5147,8 +5147,6 @@ static void smctr_set_multicast_list(struct net_device *dev)
 {
         if(smctr_debug > 10)
                 printk(KERN_DEBUG "%s: smctr_set_multicast_list\n", dev->name);
-
-        return;
 }
 
 static int smctr_set_page(struct net_device *dev, __u8 *buf)
diff --git a/drivers/net/tokenring/tms380tr.c b/drivers/net/tokenring/tms380tr.c
index 8cb126a..435ef7d 100644
--- a/drivers/net/tokenring/tms380tr.c
+++ b/drivers/net/tokenring/tms380tr.c
@@ -325,8 +325,6 @@ static void tms380tr_timer_end_wait(unsigned long data)
 		tp->Sleeping = 0;
 		wake_up_interruptible(&tp->wait_for_tok_int);
 	}
-
-	return;
 }
 
 /*
@@ -460,8 +458,6 @@ static void tms380tr_init_net_local(struct net_device *dev)
 	tp->RplHead = &tp->Rpl[0];
 	tp->RplTail = &tp->Rpl[RPL_NUM-1];
 	tp->RplTail->Status = (RX_START_FRAME | RX_END_FRAME | RX_FRAME_IRQ);
-
-	return;
 }
 
 /*
@@ -481,8 +477,6 @@ static void tms380tr_init_ipb(struct net_local *tp)
 	tp->ipb.DMA_Abort_Thrhld = DMA_RETRIES;
 	tp->ipb.SCB_Addr	= 0;
 	tp->ipb.SSB_Addr	= 0;
-
-	return;
 }
 
 /*
@@ -527,8 +521,6 @@ static void tms380tr_init_opb(struct net_device *dev)
 
 	tp->ocpl.ProdIDAddr[0]	 = LOWORD(Addr);
 	tp->ocpl.ProdIDAddr[1]	 = HIWORD(Addr);
-
-	return;
 }
 
 /*
@@ -543,8 +535,6 @@ static void tms380tr_open_adapter(struct net_device *dev)
 
 	tp->OpenCommandIssued = 1;
 	tms380tr_exec_cmd(dev, OC_OPEN);
-
-	return;
 }
 
 /*
@@ -554,8 +544,6 @@ static void tms380tr_open_adapter(struct net_device *dev)
 static void tms380tr_disable_interrupts(struct net_device *dev)
 {
 	SIFWRITEB(0, SIFACL);
-
-	return;
 }
 
 /*
@@ -565,8 +553,6 @@ static void tms380tr_disable_interrupts(struct net_device *dev)
 static void tms380tr_enable_interrupts(struct net_device *dev)
 {
 	SIFWRITEB(ACL_SINTEN, SIFACL);
-
-	return;
 }
 
 /*
@@ -578,8 +564,6 @@ static void tms380tr_exec_cmd(struct net_device *dev, unsigned short Command)
 
 	tp->CMDqueue |= Command;
 	tms380tr_chk_outstanding_cmds(dev);
-
-	return;
 }
 
 static void tms380tr_timeout(struct net_device *dev)
@@ -712,8 +696,6 @@ static void tms380tr_chk_src_addr(unsigned char *frame, unsigned char *hw_addr)
 	SRBit = frame[8] & 0x80;
 	memcpy(&frame[8], hw_addr, 6);
 	frame[8] |= SRBit;
-
-	return;
 }
 
 /*
@@ -743,8 +725,6 @@ static void tms380tr_timer_chk(unsigned long data)
 		return;
 	tp->ReOpenInProgress = 1;
 	tms380tr_open_adapter(dev);
-
-	return;
 }
 
 /*
@@ -863,8 +843,6 @@ static void tms380tr_reset_interrupt(struct net_device *dev)
 	 * and clear STS_SYSTEM_IRQ bit: enable adapter for further interrupts.
 	 */
 	tms380tr_exec_sifcmd(dev, CMD_SSB_CLEAR | CMD_CLEAR_SYSTEM_IRQ);
-
-	return;
 }
 
 /*
@@ -1119,8 +1097,6 @@ static void tms380tr_cmd_status_irq(struct net_device *dev)
 		tp->MacStat.frequency_errors += tp->errorlogtable.Frequency_Error;
 		tp->MacStat.internal_errors += tp->errorlogtable.Internal_Error;
 	}
-
-	return;
 }
 
 /*
@@ -1229,7 +1205,6 @@ static void tms380tr_set_multicast_list(struct net_device *dev)
 	
 	tp->ocpl.OPENOptions = OpenOptions;
 	tms380tr_exec_cmd(dev, OC_MODIFY_OPEN_PARMS);
-	return;
 }
 
 /*
@@ -1247,7 +1222,6 @@ void tms380tr_wait(unsigned long time)
 #else
 	udelay(time);
 #endif
-	return;
 }
 
 /*
@@ -1266,8 +1240,6 @@ static void tms380tr_exec_sifcmd(struct net_device *dev, unsigned int WriteValue
 		SifStsValue = SIFREADW(SIFSTS);
 	} while((SifStsValue & CMD_INTERRUPT_ADAPTER) && loop_counter--);
 	SIFWRITEW(cmd, SIFCMD);
-
-	return;
 }
 
 /*
@@ -1700,8 +1672,6 @@ static void tms380tr_chk_outstanding_cmds(struct net_device *dev)
 
 	/* Execute SCB and generate IRQ when done. */
 	tms380tr_exec_sifcmd(dev, CMD_EXECUTE | CMD_SCB_REQUEST);
-
-	return;
 }
 
 /*
@@ -1774,8 +1744,6 @@ static void tms380tr_ring_status_irq(struct net_device *dev)
 		tp->AdapterOpenFlag = 0;
 		tms380tr_open_adapter(dev);
 	}
-
-	return;
 }
 
 /*
@@ -1932,8 +1900,6 @@ static void tms380tr_chk_irq(struct net_device *dev)
 		/* Restart of firmware successful */
 		tp->AdapterOpenFlag = 1;
 	}
-
-	return;
 }
 
 /*
@@ -1988,8 +1954,6 @@ static void tms380tr_read_ram(struct net_device *dev, unsigned char *Data,
 	/* Restore original values */
 	SIFWRITEW(old_sifadx, SIFADX);
 	SIFWRITEW(old_sifadr, SIFADR);
-
-	return;
 }
 
 /*
@@ -2021,8 +1985,6 @@ static void tms380tr_cancel_tx_queue(struct net_local* tp)
 			dma_unmap_single(tp->pdev, tpl->DMABuff, tpl->Skb->len, DMA_TO_DEVICE);
 		dev_kfree_skb_any(tpl->Skb);
 	}
-
-	return;
 }
 
 /*
@@ -2094,7 +2056,6 @@ static void tms380tr_tx_status_irq(struct net_device *dev)
 
 	if(!tp->TplFree->NextTPLPtr->BusyFlag)
 		netif_wake_queue(dev);
-	return;
 }
 
 /*
@@ -2255,8 +2216,6 @@ static void tms380tr_rcv_status_irq(struct net_device *dev)
 		/* Inform adapter about RPL valid. */
 		tms380tr_exec_sifcmd(dev, CMD_RX_VALID);
 	}
-
-	return;
 }
 
 /*
@@ -2269,8 +2228,6 @@ static void tms380tr_rcv_status_irq(struct net_device *dev)
 static void tms380tr_write_rpl_status(RPL *rpl, unsigned int Status)
 {
 	rpl->Status = Status;
-
-	return;
 }
 
 /*
@@ -2287,8 +2244,6 @@ static void tms380tr_update_rcv_stats(struct net_local *tp, unsigned char DataPt
 	/* Test functional bit */
 	if(DataPtr[2] & GROUP_BIT)
 		tp->MacStat.multicast++;
-
-	return;
 }
 
 static int tms380tr_set_mac_address(struct net_device *dev, void *addr)
@@ -2318,8 +2273,6 @@ static void tms380tr_dump(unsigned char *Data, int length)
 		       Data[j+0],Data[j+1],Data[j+2],Data[j+3],
 		       Data[j+4],Data[j+5],Data[j+6],Data[j+7]);
 	}
-
-	return;
 }
 #endif
 
diff --git a/drivers/net/tulip/de4x5.c b/drivers/net/tulip/de4x5.c
index 9522baf..75a64c8 100644
--- a/drivers/net/tulip/de4x5.c
+++ b/drivers/net/tulip/de4x5.c
@@ -1883,8 +1883,6 @@ de4x5_local_stats(struct net_device *dev, char *buf, int pkt_len)
     if (lp->pktStats.bins[0] == 0) { /* Reset counters */
         memset((char *)&lp->pktStats, 0, sizeof(lp->pktStats));
     }
-
-    return;
 }
 
 /*
@@ -1991,8 +1989,6 @@ SetMulticastFilter(struct net_device *dev)
 	}
     }
     outl(omr, DE4X5_OMR);
-
-    return;
 }
 
 #ifdef CONFIG_EISA
@@ -2187,8 +2183,6 @@ srom_search(struct net_device *dev, struct pci_dev *pdev)
 	    return;
 	}
     }
-
-    return;
 }
 
 /*
@@ -3291,8 +3285,6 @@ de4x5_init_connection(struct net_device *dev)
     outl(POLL_DEMAND, DE4X5_TPD);
 
     netif_wake_queue(dev);
-
-    return;
 }
 
 /*
@@ -3664,8 +3656,6 @@ de4x5_free_rx_buffs(struct net_device *dev)
 	lp->rx_ring[i].status = 0;
 	lp->rx_skb[i] = (struct sk_buff *)1;    /* Dummy entry */
     }
-
-    return;
 }
 
 static void
@@ -3708,8 +3698,6 @@ de4x5_save_skbs(struct net_device *dev)
 	lp->cache.save_cnt++;
 	START_DE4X5;
     }
-
-    return;
 }
 
 static void
@@ -3741,8 +3729,6 @@ de4x5_rst_desc_ring(struct net_device *dev)
 	lp->cache.save_cnt--;
 	START_DE4X5;
     }
-
-    return;
 }
 
 static void
@@ -3771,8 +3757,6 @@ de4x5_cache_state(struct net_device *dev, int flag)
 	}
 	break;
     }
-
-    return;
 }
 
 static void
@@ -3845,8 +3829,6 @@ de4x5_setup_intr(struct net_device *dev)
 	outl(sts, DE4X5_STS);
 	ENABLE_IRQs;
     }
-
-    return;
 }
 
 /*
@@ -3879,8 +3861,6 @@ reset_init_sia(struct net_device *dev, s32 csr13, s32 csr14, s32 csr15)
     outl(csr13, DE4X5_SICR);
 
     mdelay(10);
-
-    return;
 }
 
 /*
@@ -3901,8 +3881,6 @@ create_packet(struct net_device *dev, char *frame, int len)
 
     *buf++ = 0;                              /* Packet length (2 bytes) */
     *buf++ = 1;
-
-    return;
 }
 
 /*
@@ -4006,8 +3984,6 @@ DevicePresent(struct net_device *dev, u_long aprom_addr)
 	}
 	de4x5_dbg_srom((struct de4x5_srom *)&lp->srom);
     }
-
-    return;
 }
 
 /*
@@ -4045,8 +4021,6 @@ enet_addr_rst(u_long aprom_addr)
 	    }
 	}
     }
-
-    return;
 }
 
 /*
@@ -4186,8 +4160,6 @@ srom_repair(struct net_device *dev, int card)
 	lp->useSROM = true;
 	break;
     }
-
-    return;
 }
 
 /*
@@ -4261,8 +4233,6 @@ srom_latch(u_int command, u_long addr)
     sendto_srom(command, addr);
     sendto_srom(command | DT_CLK, addr);
     sendto_srom(command, addr);
-
-    return;
 }
 
 static void
@@ -4271,8 +4241,6 @@ srom_command(u_int command, u_long addr)
     srom_latch(command, addr);
     srom_latch(command, addr);
     srom_latch((command & 0x0000ff00) | DT_CS, addr);
-
-    return;
 }
 
 static void
@@ -4287,8 +4255,6 @@ srom_address(u_int command, u_long addr, u_char offset)
     udelay(1);
 
     i = (getfrom_srom(addr) >> 3) & 0x01;
-
-    return;
 }
 
 static short
@@ -4322,8 +4288,6 @@ srom_busy(u_int command, u_long addr)
    }
 
    sendto_srom(command & 0x0000ff00, addr);
-
-   return;
 }
 */
 
@@ -4332,8 +4296,6 @@ sendto_srom(u_int command, u_long addr)
 {
     outl(command, addr);
     udelay(1);
-
-    return;
 }
 
 static int
@@ -4432,8 +4394,6 @@ srom_init(struct net_device *dev)
 	    p += ((*p & BLOCK_LEN) + 1);
 	}
     }
-
-    return;
 }
 
 /*
@@ -4462,8 +4422,6 @@ srom_exec(struct net_device *dev, u_char *p)
 	outl(lp->cache.csr14, DE4X5_STRR);
 	outl(lp->cache.csr13, DE4X5_SICR);
     }
-
-    return;
 }
 
 /*
@@ -4888,8 +4846,6 @@ mii_wr(int data, u_char phyreg, u_char phyaddr, u_long ioaddr)
     mii_ta(MII_STWR, ioaddr);              /* Turn around time - 2 MDC       */
     data = mii_swap(data, 16);             /* Swap data bit ordering         */
     mii_wdata(data, 16, ioaddr);           /* Write data                     */
-
-    return;
 }
 
 static int
@@ -4915,8 +4871,6 @@ mii_wdata(int data, int len, u_long ioaddr)
 	sendto_mii(MII_MWR | MII_WR, data, ioaddr);
 	data >>= 1;
     }
-
-    return;
 }
 
 static void
@@ -4929,8 +4883,6 @@ mii_address(u_char addr, u_long ioaddr)
 	sendto_mii(MII_MWR | MII_WR, addr, ioaddr);
 	addr >>= 1;
     }
-
-    return;
 }
 
 static void
@@ -4942,8 +4894,6 @@ mii_ta(u_long rw, u_long ioaddr)
     } else {
 	getfrom_mii(MII_MRD | MII_RD, ioaddr);        /* Tri-state MDIO */
     }
-
-    return;
 }
 
 static int
@@ -4970,8 +4920,6 @@ sendto_mii(u32 command, int data, u_long ioaddr)
     udelay(1);
     outl(command | MII_MDC | j, ioaddr);
     udelay(1);
-
-    return;
 }
 
 static int
@@ -5185,8 +5133,6 @@ gep_wr(s32 data, struct net_device *dev)
     } else if ((lp->chipset & ~0x00ff) == DC2114x) {
 	outl((data<<16) | lp->cache.csr15, DE4X5_SIGR);
     }
-
-    return;
 }
 
 static int
@@ -5246,8 +5192,6 @@ yawn(struct net_device *dev, int state)
 	    break;
 	}
     }
-
-    return;
 }
 
 static void
@@ -5289,8 +5233,6 @@ de4x5_parse_params(struct net_device *dev)
 	}
 	*q = t;
     }
-
-    return;
 }
 
 static void
@@ -5340,8 +5282,6 @@ de4x5_dbg_open(struct net_device *dev)
 	       (short)lp->rxRingSize,
 	       (short)lp->txRingSize);
     }
-
-    return;
 }
 
 static void
@@ -5368,8 +5308,6 @@ de4x5_dbg_mii(struct net_device *dev, int k)
 	    printk("MII 20:  %x\n",mii_rd(0x14,lp->phy[k].addr,DE4X5_MII));
 	}
     }
-
-    return;
 }
 
 static void
@@ -5394,8 +5332,6 @@ de4x5_dbg_media(struct net_device *dev)
 	}
 	lp->c_media = lp->media;
     }
-
-    return;
 }
 
 static void
@@ -5416,8 +5352,6 @@ de4x5_dbg_srom(struct de4x5_srom *p)
 	    printk("%3d %04x\n", i<<1, (u_short)*((u_short *)p+i));
 	}
     }
-
-    return;
 }
 
 static void
@@ -5439,8 +5373,6 @@ de4x5_dbg_rx(struct sk_buff *skb, int len)
 	  printk("\n");
 	}
     }
-
-    return;
 }
 
 /*
diff --git a/drivers/net/tulip/dmfe.c b/drivers/net/tulip/dmfe.c
index bdb25b8..29e6c63 100644
--- a/drivers/net/tulip/dmfe.c
+++ b/drivers/net/tulip/dmfe.c
@@ -1118,7 +1118,6 @@ static void dmfe_ethtool_get_wol(struct net_device *dev,
 
 	wolinfo->supported = WAKE_PHY | WAKE_MAGIC;
 	wolinfo->wolopts = db->wol_mode;
-	return;
 }
 
 
diff --git a/drivers/net/tulip/media.c b/drivers/net/tulip/media.c
index 68b170a..a0c770e 100644
--- a/drivers/net/tulip/media.c
+++ b/drivers/net/tulip/media.c
@@ -396,8 +396,6 @@ void tulip_select_media(struct net_device *dev, int startup)
 	tp->csr6 = new_csr6 | (tp->csr6 & 0xfdff) | (tp->full_duplex ? 0x0200 : 0);
 
 	mdelay(1);
-
-	return;
 }
 
 /*
diff --git a/drivers/net/tulip/winbond-840.c b/drivers/net/tulip/winbond-840.c
index 60a8754..608b279 100644
--- a/drivers/net/tulip/winbond-840.c
+++ b/drivers/net/tulip/winbond-840.c
@@ -626,7 +626,6 @@ static void mdio_write(struct net_device *dev, int phy_id, int location, int val
 		iowrite32(MDIO_EnbIn | MDIO_ShiftClk, mdio_addr);
 		mdio_delay(mdio_addr);
 	}
-	return;
 }
 
 
@@ -971,7 +970,6 @@ static void tx_timeout(struct net_device *dev)
 	netif_wake_queue(dev);
 	dev->trans_start = jiffies; /* prevent tx timeout */
 	np->stats.tx_errors++;
-	return;
 }
 
 /* Initialize the Rx and Tx rings, along with various 'dev' bits. */
diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index dbdfb1f..01b5cfc 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -417,7 +417,6 @@ static void tun_net_mclist(struct net_device *dev)
 	 * _rx_ path and has nothing to do with the _tx_ path.
 	 * In rx path we always accept everything userspace gives us.
 	 */
-	return;
 }
 
 #define MIN_MTU 68
diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c
index a6227f8..9964df1 100644
--- a/drivers/net/usb/hso.c
+++ b/drivers/net/usb/hso.c
@@ -1472,7 +1472,6 @@ static void hso_serial_set_termios(struct tty_struct *tty, struct ktermios *old)
 	spin_unlock_irqrestore(&serial->serial_lock, flags);
 
 	/* done */
-	return;
 }
 
 /* how many characters in the buffer */
@@ -1992,7 +1991,6 @@ static void hso_std_serial_write_bulk_callback(struct urb *urb)
 	hso_kick_transmit(serial);
 
 	D1(" ");
-	return;
 }
 
 /* called for writing diag or CS serial port */
diff --git a/drivers/net/vxge/vxge-config.c b/drivers/net/vxge/vxge-config.c
index a5fc816..297f0d2 100644
--- a/drivers/net/vxge/vxge-config.c
+++ b/drivers/net/vxge/vxge-config.c
@@ -183,8 +183,6 @@ __vxge_hw_device_pci_e_init(struct __vxge_hw_device *hldev)
 	pci_write_config_word(hldev->pdev, PCI_COMMAND, cmd);
 
 	pci_save_state(hldev->pdev);
-
-	return;
 }
 
 /*
@@ -342,8 +340,6 @@ void __vxge_hw_device_id_get(struct __vxge_hw_device *hldev)
 
 	hldev->minor_revision =
 		(u8)VXGE_HW_TITAN_ASIC_ID_GET_INITIAL_MINOR_REVISION(val64);
-
-	return;
 }
 
 /*
@@ -428,8 +424,6 @@ void __vxge_hw_device_host_info_get(struct __vxge_hw_device *hldev)
 		hldev->first_vp_id = i;
 		break;
 	}
-
-	return;
 }
 
 /*
@@ -1217,8 +1211,6 @@ __vxge_hw_ring_mempool_item_alloc(struct vxge_hw_mempool *mempoolh,
 		/* link this RxD block with previous one */
 		__vxge_hw_ring_rxdblock_link(mempoolh, ring, index - 1, index);
 	}
-
-	return;
 }
 
 /*
@@ -2318,8 +2310,6 @@ __vxge_hw_fifo_mempool_item_alloc(
 	txdl_priv->first_txdp = txdp;
 	txdl_priv->next_txdl_priv = NULL;
 	txdl_priv->alloc_frags = 0;
-
-	return;
 }
 
 /*
@@ -2576,7 +2566,6 @@ __vxge_hw_read_rts_ds(struct vxge_hw_vpath_reg __iomem *vpath_reg,
 	writeq(dta_struct_sel, &vpath_reg->rts_access_steer_data0);
 	writeq(0, &vpath_reg->rts_access_steer_data1);
 	wmb();
-	return;
 }
 
 
@@ -3484,7 +3473,6 @@ __vxge_hw_vpath_prc_configure(struct __vxge_hw_device *hldev, u32 vp_id)
 		val64 &= ~VXGE_HW_PRC_CFG4_RTH_DISABLE;
 
 	writeq(val64, &vp_reg->prc_cfg4);
-	return;
 }
 
 /*
@@ -3903,7 +3891,6 @@ vxge_hw_vpath_tti_ci_set(struct __vxge_hw_device *hldev, u32 vp_id)
 			&vp_reg->tim_cfg1_int_num[VXGE_HW_VPATH_INTR_TX]);
 		}
 	}
-	return;
 }
 /*
  * __vxge_hw_vpath_initialize
@@ -5037,8 +5024,6 @@ __vxge_hw_blockpool_free(struct __vxge_hw_device *devh,
 		if (status == VXGE_HW_OK)
 			__vxge_hw_blockpool_blocks_remove(blockpool);
 	}
-
-	return;
 }
 
 /*
@@ -5094,6 +5079,4 @@ __vxge_hw_blockpool_block_free(struct __vxge_hw_device *devh,
 	}
 
 	__vxge_hw_blockpool_blocks_remove(blockpool);
-
-	return;
 }
diff --git a/drivers/net/vxge/vxge-main.c b/drivers/net/vxge/vxge-main.c
index 2bab364..b504bd5 100644
--- a/drivers/net/vxge/vxge-main.c
+++ b/drivers/net/vxge/vxge-main.c
@@ -1764,7 +1764,6 @@ static void vxge_netpoll(struct net_device *dev)
 
 	vxge_debug_entryexit(VXGE_TRACE,
 		"%s:%d  Exiting...", __func__, __LINE__);
-	return;
 }
 #endif
 
@@ -2815,7 +2814,6 @@ static void vxge_napi_del_all(struct vxgedev *vdev)
 		for (i = 0; i < vdev->no_of_vpath; i++)
 			netif_napi_del(&vdev->vpaths[i].ring.napi);
 	}
-	return;
 }
 
 int do_vxge_close(struct net_device *dev, int do_io)
@@ -3500,8 +3498,6 @@ static void verify_bandwidth(void)
 		for (i = 1; i < VXGE_HW_MAX_VIRTUAL_PATHS; i++)
 			bw_percentage[i] = bw_percentage[0];
 	}
-
-	return;
 }
 
 /*
diff --git a/drivers/net/vxge/vxge-traffic.c b/drivers/net/vxge/vxge-traffic.c
index f83e6ae..6cc1dd7 100644
--- a/drivers/net/vxge/vxge-traffic.c
+++ b/drivers/net/vxge/vxge-traffic.c
@@ -233,8 +233,6 @@ void vxge_hw_channel_msix_mask(struct __vxge_hw_channel *channel, int msix_id)
 	__vxge_hw_pio_mem_write32_upper(
 		(u32)vxge_bVALn(vxge_mBIT(msix_id >> 2), 0, 32),
 		&channel->common_reg->set_msix_mask_vect[msix_id%4]);
-
-	return;
 }
 
 /**
@@ -253,8 +251,6 @@ vxge_hw_channel_msix_unmask(struct __vxge_hw_channel *channel, int msix_id)
 	__vxge_hw_pio_mem_write32_upper(
 		(u32)vxge_bVALn(vxge_mBIT(msix_id >> 2), 0, 32),
 		&channel->common_reg->clear_msix_mask_vect[msix_id%4]);
-
-	return;
 }
 
 /**
@@ -329,8 +325,6 @@ void vxge_hw_device_intr_enable(struct __vxge_hw_device *hldev)
 	val64 = readq(&hldev->common_reg->titan_general_int_status);
 
 	vxge_hw_device_unmask_all(hldev);
-
-	return;
 }
 
 /**
@@ -362,8 +356,6 @@ void vxge_hw_device_intr_disable(struct __vxge_hw_device *hldev)
 		vxge_hw_vpath_intr_disable(
 			VXGE_HW_VIRTUAL_PATH_HANDLE(&hldev->virtual_paths[i]));
 	}
-
-	return;
 }
 
 /**
@@ -383,8 +375,6 @@ void vxge_hw_device_mask_all(struct __vxge_hw_device *hldev)
 
 	__vxge_hw_pio_mem_write32_upper((u32)vxge_bVALn(val64, 0, 32),
 				&hldev->common_reg->titan_mask_all_int);
-
-	return;
 }
 
 /**
@@ -404,8 +394,6 @@ void vxge_hw_device_unmask_all(struct __vxge_hw_device *hldev)
 
 	__vxge_hw_pio_mem_write32_upper((u32)vxge_bVALn(val64, 0, 32),
 			&hldev->common_reg->titan_mask_all_int);
-
-	return;
 }
 
 /**
@@ -647,8 +635,6 @@ void vxge_hw_device_clear_tx_rx(struct __vxge_hw_device *hldev)
 				 hldev->tim_int_mask1[VXGE_HW_VPATH_INTR_RX]),
 				&hldev->common_reg->tim_int_status1);
 	}
-
-	return;
 }
 
 /*
@@ -2255,8 +2241,6 @@ vxge_hw_vpath_msix_set(struct __vxge_hw_vpath_handle *vp, int *tim_msix_id,
 				VXGE_HW_ONE_SHOT_VECT3_EN_ONE_SHOT_VECT3_EN,
 				0, 32), &vp_reg->one_shot_vect3_en);
 	}
-
-	return;
 }
 
 /**
@@ -2278,8 +2262,6 @@ vxge_hw_vpath_msix_mask(struct __vxge_hw_vpath_handle *vp, int msix_id)
 	__vxge_hw_pio_mem_write32_upper(
 		(u32) vxge_bVALn(vxge_mBIT(msix_id  >> 2), 0, 32),
 		&hldev->common_reg->set_msix_mask_vect[msix_id % 4]);
-
-	return;
 }
 
 /**
@@ -2310,8 +2292,6 @@ vxge_hw_vpath_msix_clear(struct __vxge_hw_vpath_handle *vp, int msix_id)
 				&hldev->common_reg->
 					clear_msix_mask_vect[msix_id%4]);
 	}
-
-	return;
 }
 
 /**
@@ -2333,8 +2313,6 @@ vxge_hw_vpath_msix_unmask(struct __vxge_hw_vpath_handle *vp, int msix_id)
 	__vxge_hw_pio_mem_write32_upper(
 			(u32)vxge_bVALn(vxge_mBIT(msix_id >> 2), 0, 32),
 			&hldev->common_reg->clear_msix_mask_vect[msix_id%4]);
-
-	return;
 }
 
 /**
@@ -2351,8 +2329,6 @@ vxge_hw_vpath_msix_mask_all(struct __vxge_hw_vpath_handle *vp)
 	__vxge_hw_pio_mem_write32_upper(
 		(u32)vxge_bVALn(vxge_mBIT(vp->vpath->vp_id), 0, 32),
 		&vp->vpath->hldev->common_reg->set_msix_mask_all_vect);
-
-	return;
 }
 
 /**
@@ -2391,8 +2367,6 @@ void vxge_hw_vpath_inta_mask_tx_rx(struct __vxge_hw_vpath_handle *vp)
 			tim_int_mask1[VXGE_HW_VPATH_INTR_RX] | val64),
 			&hldev->common_reg->tim_int_mask1);
 	}
-
-	return;
 }
 
 /**
@@ -2429,8 +2403,6 @@ void vxge_hw_vpath_inta_unmask_tx_rx(struct __vxge_hw_vpath_handle *vp)
 			  tim_int_mask1[VXGE_HW_VPATH_INTR_RX])) & val64,
 			&hldev->common_reg->tim_int_mask1);
 	}
-
-	return;
 }
 
 /**
diff --git a/drivers/net/wd.c b/drivers/net/wd.c
index d8322d2..746a5ee 100644
--- a/drivers/net/wd.c
+++ b/drivers/net/wd.c
@@ -395,7 +395,6 @@ wd_reset_8390(struct net_device *dev)
 		outb(NIC16 | ((dev->mem_start>>19) & 0x1f), wd_cmd_port+WD_CMDREG5);
 
 	if (ei_debug > 1) printk("reset done\n");
-	return;
 }
 
 /* Grab the 8390 specific header. Similar to the block_input routine, but
diff --git a/drivers/net/wimax/i2400m/control.c b/drivers/net/wimax/i2400m/control.c
index 6180772..f8a9734 100644
--- a/drivers/net/wimax/i2400m/control.c
+++ b/drivers/net/wimax/i2400m/control.c
@@ -568,7 +568,6 @@ void i2400m_msg_ack_hook(struct i2400m *i2400m,
 		}
 		break;
 	};
-	return;
 }
 
 
@@ -1419,5 +1418,4 @@ void i2400m_dev_shutdown(struct i2400m *i2400m)
 
 	d_fnstart(3, dev, "(i2400m %p)\n", i2400m);
 	d_fnend(3, dev, "(i2400m %p) = void\n", i2400m);
-	return;
 }
diff --git a/drivers/net/wimax/i2400m/driver.c b/drivers/net/wimax/i2400m/driver.c
index 94dc83c..0043cc1 100644
--- a/drivers/net/wimax/i2400m/driver.c
+++ b/drivers/net/wimax/i2400m/driver.c
@@ -711,7 +711,6 @@ out:
 	kfree(iw);
 	d_fnend(3, dev, "(ws %p i2400m %p reason %s) = void\n",
 		ws, i2400m, reason);
-	return;
 }
 
 
@@ -996,7 +995,6 @@ void __exit i2400m_driver_exit(void)
 	/* for scheds i2400m_dev_reset_handle() */
 	flush_scheduled_work();
 	i2400m_barker_db_exit();
-	return;
 }
 module_exit(i2400m_driver_exit);
 
diff --git a/drivers/net/wimax/i2400m/netdev.c b/drivers/net/wimax/i2400m/netdev.c
index b811c2f..149b9f5 100644
--- a/drivers/net/wimax/i2400m/netdev.c
+++ b/drivers/net/wimax/i2400m/netdev.c
@@ -255,7 +255,6 @@ void i2400m_net_wake_stop(struct i2400m *i2400m)
 		kfree_skb(wake_tx_skb);
 	}
 	d_fnend(3, dev, "(i2400m %p) = void\n", i2400m);
-	return;
 }
 
 
@@ -434,7 +433,6 @@ void i2400m_tx_timeout(struct net_device *net_dev)
 	 * this, there might be data pending to be sent or not...
 	 */
 	net_dev->stats.tx_errors++;
-	return;
 }
 
 
diff --git a/drivers/net/wimax/i2400m/rx.c b/drivers/net/wimax/i2400m/rx.c
index fa2e11e..5fa841d 100644
--- a/drivers/net/wimax/i2400m/rx.c
+++ b/drivers/net/wimax/i2400m/rx.c
@@ -313,7 +313,6 @@ error_waiter_cancelled:
 	kfree_skb(ack_skb);
 error_no_waiter:
 	spin_unlock_irqrestore(&i2400m->rx_lock, flags);
-	return;
 }
 
 
@@ -718,7 +717,6 @@ void __i2400m_roq_queue(struct i2400m *i2400m, struct i2400m_roq *roq,
 out:
 	d_fnend(4, dev, "(i2400m %p roq %p skb %p sn %u nsn %d) = void\n",
 		i2400m, roq, skb, sn, nsn);
-	return;
 }
 
 
@@ -798,7 +796,6 @@ void i2400m_roq_reset(struct i2400m *i2400m, struct i2400m_roq *roq)
 	}
 	roq->ws = 0;
 	d_fnend(2, dev, "(i2400m %p roq %p) = void\n", i2400m, roq);
-	return;
 }
 
 
@@ -837,7 +834,6 @@ void i2400m_roq_queue(struct i2400m *i2400m, struct i2400m_roq *roq,
 	}
 	d_fnend(2, dev, "(i2400m %p roq %p skb %p lbn %u) = void\n",
 		i2400m, roq, skb, lbn);
-	return;
 }
 
 
@@ -863,7 +859,6 @@ void i2400m_roq_update_ws(struct i2400m *i2400m, struct i2400m_roq *roq,
 	i2400m_roq_log_add(i2400m, roq, I2400M_RO_TYPE_WS,
 			     old_ws, len, sn, nsn, roq->ws);
 	d_fnstart(2, dev, "(i2400m %p roq %p sn %u) = void\n", i2400m, roq, sn);
-	return;
 }
 
 
@@ -912,7 +907,6 @@ void i2400m_roq_queue_update_ws(struct i2400m *i2400m, struct i2400m_roq *roq,
 	}
 	d_fnend(2, dev, "(i2400m %p roq %p skb %p sn %u) = void\n",
 		i2400m, roq, skb, sn);
-	return;
 }
 
 
@@ -1041,7 +1035,6 @@ error_skb_clone:
 error:
 	d_fnend(2, dev, "(i2400m %p skb_rx %p single %u payload %p "
 		"size %zu) = void\n", i2400m, skb_rx, single_last, payload, size);
-	return;
 }
 
 
diff --git a/drivers/net/wimax/i2400m/sdio-rx.c b/drivers/net/wimax/i2400m/sdio-rx.c
index d619da3..8b809c2 100644
--- a/drivers/net/wimax/i2400m/sdio-rx.c
+++ b/drivers/net/wimax/i2400m/sdio-rx.c
@@ -197,7 +197,6 @@ error_alloc_skb:
 error_get_size:
 error_bad_size:
 	d_fnend(7, dev, "(i2400ms %p) = %d\n", i2400ms, ret);
-	return;
 }
 
 
@@ -229,7 +228,6 @@ void i2400ms_irq(struct sdio_func *func)
 	i2400ms_rx(i2400ms);
 error_no_irq:
 	d_fnend(6, dev, "(i2400ms %p) = void\n", i2400ms);
-	return;
 }
 
 
diff --git a/drivers/net/wimax/i2400m/usb-notif.c b/drivers/net/wimax/i2400m/usb-notif.c
index 7b6a1d9..d44b545 100644
--- a/drivers/net/wimax/i2400m/usb-notif.c
+++ b/drivers/net/wimax/i2400m/usb-notif.c
@@ -178,7 +178,6 @@ error_submit:
 out:
 	d_fnend(4, dev, "(urb %p status %d actual_length %d) = void\n",
 		urb, urb->status, urb->actual_length);
-	return;
 }
 
 
diff --git a/drivers/net/wireless/at76c50x-usb.c b/drivers/net/wireless/at76c50x-usb.c
index 7a626d4..8a2d4af 100644
--- a/drivers/net/wireless/at76c50x-usb.c
+++ b/drivers/net/wireless/at76c50x-usb.c
@@ -1223,7 +1223,6 @@ static void at76_rx_callback(struct urb *urb)
 
 	priv->rx_tasklet.data = (unsigned long)urb;
 	tasklet_schedule(&priv->rx_tasklet);
-	return;
 }
 
 static int at76_submit_rx_urb(struct at76_priv *priv)
diff --git a/drivers/net/wireless/ath/ath5k/phy.c b/drivers/net/wireless/ath/ath5k/phy.c
index 3ce9afb..1b81c47 100644
--- a/drivers/net/wireless/ath/ath5k/phy.c
+++ b/drivers/net/wireless/ath/ath5k/phy.c
@@ -2145,8 +2145,6 @@ ath5k_get_chan_pcal_surrounding_piers(struct ath5k_hw *ah,
 done:
 	*pcinfo_l = &pcinfo[idx_l];
 	*pcinfo_r = &pcinfo[idx_r];
-
-	return;
 }
 
 /*
diff --git a/drivers/net/wireless/ath/ath5k/reset.c b/drivers/net/wireless/ath/ath5k/reset.c
index 44bbbf2..307f80e 100644
--- a/drivers/net/wireless/ath/ath5k/reset.c
+++ b/drivers/net/wireless/ath/ath5k/reset.c
@@ -627,7 +627,6 @@ static void ath5k_hw_set_sleep_clock(struct ath5k_hw *ah, bool enable)
 
 		AR5K_REG_WRITE_BITS(ah, AR5K_TSF_PARM, AR5K_TSF_PARM_INC, 1);
 	}
-	return;
 }
 
 /* TODO: Half/Quarter rate */
@@ -883,8 +882,6 @@ static void ath5k_hw_commit_eeprom_settings(struct ath5k_hw *ah,
 	/* Heavy clipping -disable for now */
 	if (ah->ah_ee_version >= AR5K_EEPROM_VERSION_5_1)
 		ath5k_hw_reg_write(ah, 0, AR5K_PHY_HEAVY_CLIP_ENABLE);
-
-	return;
 }
 
 /*
diff --git a/drivers/net/wireless/ath/ath9k/ar9003_calib.c b/drivers/net/wireless/ath/ath9k/ar9003_calib.c
index 5fcafb4..56a9e5f 100644
--- a/drivers/net/wireless/ath/ath9k/ar9003_calib.c
+++ b/drivers/net/wireless/ath/ath9k/ar9003_calib.c
@@ -726,7 +726,6 @@ static void ar9003_hw_tx_iq_cal(struct ath_hw *ah)
 
 TX_IQ_CAL_FAILED:
 	ath_print(common, ATH_DBG_CALIBRATE, "Tx IQ Cal failed\n");
-	return;
 }
 
 static bool ar9003_hw_init_cal(struct ath_hw *ah,
diff --git a/drivers/net/wireless/ath/ath9k/calib.c b/drivers/net/wireless/ath/ath9k/calib.c
index 6982577..07b8fa6 100644
--- a/drivers/net/wireless/ath/ath9k/calib.c
+++ b/drivers/net/wireless/ath/ath9k/calib.c
@@ -86,7 +86,6 @@ static void ath9k_hw_update_nfcal_hist_buffer(struct ath9k_nfcal_hist *h,
 				ath9k_hw_get_nf_hist_mid(h[i].nfCalBuffer);
 		}
 	}
-	return;
 }
 
 static bool ath9k_hw_get_nf_thresh(struct ath_hw *ah,
diff --git a/drivers/net/wireless/ath/ath9k/common.c b/drivers/net/wireless/ath/ath9k/common.c
index b4424a6..c9b2595 100644
--- a/drivers/net/wireless/ath/ath9k/common.c
+++ b/drivers/net/wireless/ath/ath9k/common.c
@@ -633,6 +633,5 @@ module_init(ath9k_cmn_init);
 
 static void __exit ath9k_cmn_exit(void)
 {
-	return;
 }
 module_exit(ath9k_cmn_exit);
diff --git a/drivers/net/wireless/ath/ath9k/eeprom.c b/drivers/net/wireless/ath/ath9k/eeprom.c
index bd9dff3..ca8704a 100644
--- a/drivers/net/wireless/ath/ath9k/eeprom.c
+++ b/drivers/net/wireless/ath/ath9k/eeprom.c
@@ -36,8 +36,6 @@ void ath9k_hw_analog_shift_rmw(struct ath_hw *ah, u32 reg, u32 mask,
 
 	if (ah->config.analog_shiftreg)
 		udelay(100);
-
-	return;
 }
 
 int16_t ath9k_hw_interpolate(u16 target, u16 srcLeft, u16 srcRight,
diff --git a/drivers/net/wireless/ath/ath9k/eeprom_def.c b/drivers/net/wireless/ath/ath9k/eeprom_def.c
index e591ad6..7e1ed78 100644
--- a/drivers/net/wireless/ath/ath9k/eeprom_def.c
+++ b/drivers/net/wireless/ath/ath9k/eeprom_def.c
@@ -50,7 +50,6 @@ static void ath9k_get_txgain_index(struct ath_hw *ah,
 		i++;
 
 	*pcdacIdx = i;
-	return;
 }
 
 static void ath9k_olc_get_pdadcs(struct ath_hw *ah,
@@ -751,8 +750,6 @@ static void ath9k_hw_get_def_gain_boundaries_pdadcs(struct ath_hw *ah,
 		pPDADCValues[k] = pPDADCValues[k - 1];
 		k++;
 	}
-
-	return;
 }
 
 static int16_t ath9k_change_gain_boundary_setting(struct ath_hw *ah,
diff --git a/drivers/net/wireless/ath/ath9k/htc_drv_txrx.c b/drivers/net/wireless/ath/ath9k/htc_drv_txrx.c
index 28abc7d..2571b44 100644
--- a/drivers/net/wireless/ath/ath9k/htc_drv_txrx.c
+++ b/drivers/net/wireless/ath/ath9k/htc_drv_txrx.c
@@ -663,7 +663,6 @@ void ath9k_htc_rxep(void *drv_priv, struct sk_buff *skb,
 	return;
 err:
 	dev_kfree_skb_any(skb);
-	return;
 }
 
 /* FIXME: Locking for cleanup/init */
diff --git a/drivers/net/wireless/ath/ath9k/hw.c b/drivers/net/wireless/ath/ath9k/hw.c
index 5590192..0428cf6 100644
--- a/drivers/net/wireless/ath/ath9k/hw.c
+++ b/drivers/net/wireless/ath/ath9k/hw.c
@@ -43,7 +43,6 @@ module_init(ath9k_init);
 
 static void __exit ath9k_exit(void)
 {
-	return;
 }
 module_exit(ath9k_exit);
 
diff --git a/drivers/net/wireless/ath/ath9k/rc.c b/drivers/net/wireless/ath/ath9k/rc.c
index 8519452..9d5d1f5 100644
--- a/drivers/net/wireless/ath/ath9k/rc.c
+++ b/drivers/net/wireless/ath/ath9k/rc.c
@@ -1390,7 +1390,6 @@ static void *ath_rate_alloc(struct ieee80211_hw *hw, struct dentry *debugfsdir)
 
 static void ath_rate_free(void *priv)
 {
-	return;
 }
 
 static void *ath_rate_alloc_sta(void *priv, struct ieee80211_sta *sta, gfp_t gfp)
diff --git a/drivers/net/wireless/ath/regd.c b/drivers/net/wireless/ath/regd.c
index 24d5988..3f4244f 100644
--- a/drivers/net/wireless/ath/regd.c
+++ b/drivers/net/wireless/ath/regd.c
@@ -333,7 +333,6 @@ static void ath_reg_apply_world_flags(struct wiphy *wiphy,
 		ath_reg_apply_active_scan_flags(wiphy, initiator);
 		break;
 	}
-	return;
 }
 
 int ath_reg_notifier_apply(struct wiphy *wiphy,
diff --git a/drivers/net/wireless/ipw2x00/ipw2100.c b/drivers/net/wireless/ipw2x00/ipw2100.c
index 2088ac0..a59ceb2 100644
--- a/drivers/net/wireless/ipw2x00/ipw2100.c
+++ b/drivers/net/wireless/ipw2x00/ipw2100.c
@@ -3239,7 +3239,6 @@ static void ipw2100_tx_send_data(struct ipw2100_priv *priv)
 			       IPW_MEM_HOST_SHARED_TX_QUEUE_WRITE_INDEX,
 			       txq->next);
 	}
-	return;
 }
 
 static void ipw2100_irq_tasklet(struct ipw2100_priv *priv)
diff --git a/drivers/net/wireless/ipw2x00/ipw2200.c b/drivers/net/wireless/ipw2x00/ipw2200.c
index 82de71a..3aa3bb1 100644
--- a/drivers/net/wireless/ipw2x00/ipw2200.c
+++ b/drivers/net/wireless/ipw2x00/ipw2200.c
@@ -2607,8 +2607,6 @@ static inline void eeprom_write_reg(struct ipw_priv *p, u32 data)
 
 	/* the eeprom requires some time to complete the operation */
 	udelay(p->eeprom_delay);
-
-	return;
 }
 
 /* perform a chip select operation */
diff --git a/drivers/net/wireless/ipw2x00/libipw_rx.c b/drivers/net/wireless/ipw2x00/libipw_rx.c
index 39a34da..0de1b18 100644
--- a/drivers/net/wireless/ipw2x00/libipw_rx.c
+++ b/drivers/net/wireless/ipw2x00/libipw_rx.c
@@ -918,7 +918,6 @@ void libipw_rx_any(struct libipw_device *ieee,
 drop_free:
 	dev_kfree_skb_irq(skb);
 	ieee->dev->stats.rx_dropped++;
-	return;
 }
 
 #define MGMT_FRAME_FIXED_PART_LENGTH		0x24
diff --git a/drivers/net/wireless/iwlwifi/iwl-3945-rs.c b/drivers/net/wireless/iwlwifi/iwl-3945-rs.c
index 32eb470..db6b208 100644
--- a/drivers/net/wireless/iwlwifi/iwl-3945-rs.c
+++ b/drivers/net/wireless/iwlwifi/iwl-3945-rs.c
@@ -402,7 +402,6 @@ static void *rs_alloc(struct ieee80211_hw *hw, struct dentry *debugfsdir)
 /* rate scale requires free function to be implemented */
 static void rs_free(void *priv)
 {
-	return;
 }
 
 static void *rs_alloc_sta(void *iwl_priv, struct ieee80211_sta *sta, gfp_t gfp)
@@ -545,8 +544,6 @@ static void rs_tx_status(void *priv_rate, struct ieee80211_supported_band *sband
 	spin_unlock_irqrestore(&rs_sta->lock, flags);
 
 	IWL_DEBUG_RATE(priv, "leave\n");
-
-	return;
 }
 
 static u16 iwl3945_get_adjacent_rate(struct iwl3945_rs_sta *rs_sta,
diff --git a/drivers/net/wireless/iwlwifi/iwl-3945.c b/drivers/net/wireless/iwlwifi/iwl-3945.c
index 17197a7..5e620b8 100644
--- a/drivers/net/wireless/iwlwifi/iwl-3945.c
+++ b/drivers/net/wireless/iwlwifi/iwl-3945.c
@@ -2608,7 +2608,6 @@ static int iwl3945_eeprom_acquire_semaphore(struct iwl_priv *priv)
 
 static void iwl3945_eeprom_release_semaphore(struct iwl_priv *priv)
 {
-	return;
 }
 
  /**
diff --git a/drivers/net/wireless/iwlwifi/iwl-agn-rs.c b/drivers/net/wireless/iwlwifi/iwl-agn-rs.c
index bfcac56..969c9f1 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn-rs.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn-rs.c
@@ -2337,8 +2337,6 @@ out:
 	tbl->current_rate = rate_n_flags_from_tbl(priv, tbl, index, is_green);
 	i = index;
 	lq_sta->last_txrate_idx = i;
-
-	return;
 }
 
 /**
@@ -2712,7 +2710,6 @@ static void *rs_alloc(struct ieee80211_hw *hw, struct dentry *debugfsdir)
 /* rate scale requires free function to be implemented */
 static void rs_free(void *priv_rate)
 {
-	return;
 }
 
 static void rs_free_sta(void *priv_r, struct ieee80211_sta *sta,
diff --git a/drivers/net/wireless/iwlwifi/iwl-agn.c b/drivers/net/wireless/iwlwifi/iwl-agn.c
index a672d33..cc15e92 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn.c
@@ -2494,7 +2494,6 @@ static void iwl_bg_run_time_calib_work(struct work_struct *work)
 	}
 
 	mutex_unlock(&priv->mutex);
-	return;
 }
 
 static void iwl_bg_restart(struct work_struct *data)
diff --git a/drivers/net/wireless/iwlwifi/iwl-calib.c b/drivers/net/wireless/iwlwifi/iwl-calib.c
index f1fd00b..7e82277 100644
--- a/drivers/net/wireless/iwlwifi/iwl-calib.c
+++ b/drivers/net/wireless/iwlwifi/iwl-calib.c
@@ -638,8 +638,6 @@ void iwl_sensitivity_calibration(struct iwl_priv *priv,
 	iwl_sens_auto_corr_ofdm(priv, norm_fa_ofdm, rx_enable_time);
 	iwl_sens_energy_cck(priv, norm_fa_cck, rx_enable_time, &statis);
 	iwl_sensitivity_write(priv);
-
-	return;
 }
 EXPORT_SYMBOL(iwl_sensitivity_calibration);
 
diff --git a/drivers/net/wireless/iwlwifi/iwl-core.c b/drivers/net/wireless/iwlwifi/iwl-core.c
index 4cdf4d3..87eb89f 100644
--- a/drivers/net/wireless/iwlwifi/iwl-core.c
+++ b/drivers/net/wireless/iwlwifi/iwl-core.c
@@ -769,7 +769,6 @@ void iwl_set_rxon_ht(struct iwl_priv *priv, struct iwl_ht_config *ht_conf)
 			"extension channel offset 0x%x\n",
 			le32_to_cpu(rxon->flags), ht_conf->ht_protection,
 			ht_conf->extension_chan_offset);
-	return;
 }
 EXPORT_SYMBOL(iwl_set_rxon_ht);
 
diff --git a/drivers/net/wireless/iwlwifi/iwl3945-base.c b/drivers/net/wireless/iwlwifi/iwl3945-base.c
index c7e1d7d..1beb81c 100644
--- a/drivers/net/wireless/iwlwifi/iwl3945-base.c
+++ b/drivers/net/wireless/iwlwifi/iwl3945-base.c
@@ -848,7 +848,6 @@ static void iwl3945_rx_reply_add_sta(struct iwl_priv *priv,
 #endif
 
 	IWL_DEBUG_RX(priv, "Received REPLY_ADD_STA: 0x%02X\n", pkt->u.status);
-	return;
 }
 
 static void iwl3945_bg_beacon_update(struct work_struct *work)
diff --git a/drivers/net/wireless/iwmc3200wifi/sdio.c b/drivers/net/wireless/iwmc3200wifi/sdio.c
index 1acea37..edcb523 100644
--- a/drivers/net/wireless/iwmc3200wifi/sdio.c
+++ b/drivers/net/wireless/iwmc3200wifi/sdio.c
@@ -479,8 +479,6 @@ static void iwm_sdio_remove(struct sdio_func *func)
 	sdio_set_drvdata(func, NULL);
 
 	dev_info(dev, "IWM SDIO remove\n");
-
-	return;
 }
 
 static const struct sdio_device_id iwm_sdio_ids[] = {
diff --git a/drivers/net/wireless/libertas/debugfs.c b/drivers/net/wireless/libertas/debugfs.c
index 6f5b843..de2caac 100644
--- a/drivers/net/wireless/libertas/debugfs.c
+++ b/drivers/net/wireless/libertas/debugfs.c
@@ -757,15 +757,12 @@ void lbs_debugfs_init(void)
 {
 	if (!lbs_dir)
 		lbs_dir = debugfs_create_dir("lbs_wireless", NULL);
-
-	return;
 }
 
 void lbs_debugfs_remove(void)
 {
 	if (lbs_dir)
 		 debugfs_remove(lbs_dir);
-	return;
 }
 
 void lbs_debugfs_init_one(struct lbs_private *priv, struct net_device *dev)
diff --git a/drivers/net/wireless/libertas/if_usb.c b/drivers/net/wireless/libertas/if_usb.c
index fcea574..f41594c 100644
--- a/drivers/net/wireless/libertas/if_usb.c
+++ b/drivers/net/wireless/libertas/if_usb.c
@@ -133,8 +133,6 @@ static void if_usb_write_bulk_callback(struct urb *urb)
 		/* print the failure status number for debug */
 		lbs_pr_info("URB in failure status: %d\n", urb->status);
 	}
-
-	return;
 }
 
 /**
@@ -651,8 +649,6 @@ static void if_usb_receive_fwload(struct urb *urb)
 	if_usb_submit_rx_urb_fwload(cardp);
 
 	kfree(syncfwheader);
-
-	return;
 }
 
 #define MRVDRV_MIN_PKT_LEN	30
diff --git a/drivers/net/wireless/libertas/rx.c b/drivers/net/wireless/libertas/rx.c
index e2b8d88..a115bfa 100644
--- a/drivers/net/wireless/libertas/rx.c
+++ b/drivers/net/wireless/libertas/rx.c
@@ -90,7 +90,6 @@ static void lbs_save_rawSNRNF(struct lbs_private *priv, struct rxpd *p_rx_pd)
 	priv->nextSNRNF++;
 	if (priv->nextSNRNF >= DEFAULT_DATA_AVG_FACTOR)
 		priv->nextSNRNF = 0;
-	return;
 }
 
 /**
diff --git a/drivers/net/wireless/libertas_tf/if_usb.c b/drivers/net/wireless/libertas_tf/if_usb.c
index 4412c27..c445500 100644
--- a/drivers/net/wireless/libertas_tf/if_usb.c
+++ b/drivers/net/wireless/libertas_tf/if_usb.c
@@ -576,7 +576,6 @@ static void if_usb_receive_fwload(struct urb *urb)
 	kfree(syncfwheader);
 
 	lbtf_deb_leave(LBTF_DEB_USB);
-	return;
 }
 
 #define MRVDRV_MIN_PKT_LEN	30
diff --git a/drivers/net/wireless/libertas_tf/main.c b/drivers/net/wireless/libertas_tf/main.c
index 60787de..6a04c21 100644
--- a/drivers/net/wireless/libertas_tf/main.c
+++ b/drivers/net/wireless/libertas_tf/main.c
@@ -360,7 +360,6 @@ static void lbtf_op_stop(struct ieee80211_hw *hw)
 	lbtf_set_radio_control(priv);
 
 	lbtf_deb_leave(LBTF_DEB_MACOPS);
-	return;
 }
 
 static int lbtf_op_add_interface(struct ieee80211_hw *hw,
diff --git a/drivers/net/wireless/orinoco/main.c b/drivers/net/wireless/orinoco/main.c
index 884a777..9fc927f 100644
--- a/drivers/net/wireless/orinoco/main.c
+++ b/drivers/net/wireless/orinoco/main.c
@@ -1575,8 +1575,6 @@ void __orinoco_ev_info(struct net_device *dev, hermes_t *hw)
 		/* We don't actually do anything about it */
 		break;
 	}
-
-	return;
 }
 EXPORT_SYMBOL(__orinoco_ev_info);
 
diff --git a/drivers/net/wireless/p54/p54usb.c b/drivers/net/wireless/p54/p54usb.c
index 743a6c6..d5b197b 100644
--- a/drivers/net/wireless/p54/p54usb.c
+++ b/drivers/net/wireless/p54/p54usb.c
@@ -875,7 +875,6 @@ static void p54u_stop(struct ieee80211_hw *dev)
 	   the hardware is still usable next time we want to start it.
 	   until then, we just stop listening to the hardware.. */
 	p54u_free_urbs(dev);
-	return;
 }
 
 static int __devinit p54u_probe(struct usb_interface *intf,
diff --git a/drivers/net/wireless/prism54/isl_ioctl.c b/drivers/net/wireless/prism54/isl_ioctl.c
index a45818e..8d1190c 100644
--- a/drivers/net/wireless/prism54/isl_ioctl.c
+++ b/drivers/net/wireless/prism54/isl_ioctl.c
@@ -210,8 +210,6 @@ prism54_update_stats(struct work_struct *work)
 	priv->local_iwstatistics.discard.retries = r.u;
 
 	mutex_unlock(&priv->stats_lock);
-
-	return;
 }
 
 struct iw_statistics *
diff --git a/drivers/net/wireless/ray_cs.c b/drivers/net/wireless/ray_cs.c
index 73972ee..3886b21 100644
--- a/drivers/net/wireless/ray_cs.c
+++ b/drivers/net/wireless/ray_cs.c
@@ -735,8 +735,6 @@ static void verify_dl_startup(u_long data)
 		start_net((u_long) local);
 	else
 		join_net((u_long) local);
-
-	return;
 } /* end verify_dl_startup */
 
 /*===========================================================================*/
@@ -764,7 +762,6 @@ static void start_net(u_long data)
 		return;
 	}
 	local->card_status = CARD_DOING_ACQ;
-	return;
 } /* end start_net */
 
 /*===========================================================================*/
@@ -795,7 +792,6 @@ static void join_net(u_long data)
 		return;
 	}
 	local->card_status = CARD_DOING_ACQ;
-	return;
 }
 
 /*============================================================================
@@ -1626,7 +1622,6 @@ static int ray_dev_close(struct net_device *dev)
 static void ray_reset(struct net_device *dev)
 {
 	pr_debug("ray_reset entered\n");
-	return;
 }
 
 /*===========================================================================*/
diff --git a/drivers/net/wireless/rndis_wlan.c b/drivers/net/wireless/rndis_wlan.c
index babdcdf..cc9170f 100644
--- a/drivers/net/wireless/rndis_wlan.c
+++ b/drivers/net/wireless/rndis_wlan.c
@@ -1654,7 +1654,6 @@ static void debug_print_pmkids(struct usbnet *usbdev,
 				struct ndis_80211_pmkid *pmkids,
 				const char *func_str)
 {
-	return;
 }
 #endif
 
diff --git a/drivers/net/wireless/rt2x00/rt2x00debug.c b/drivers/net/wireless/rt2x00/rt2x00debug.c
index 9569fb4..e2497f8 100644
--- a/drivers/net/wireless/rt2x00/rt2x00debug.c
+++ b/drivers/net/wireless/rt2x00/rt2x00debug.c
@@ -700,8 +700,6 @@ void rt2x00debug_register(struct rt2x00_dev *rt2x00dev)
 exit:
 	rt2x00debug_deregister(rt2x00dev);
 	ERROR(rt2x00dev, "Failed to register debug handler.\n");
-
-	return;
 }
 
 void rt2x00debug_deregister(struct rt2x00_dev *rt2x00dev)
diff --git a/drivers/net/wireless/wl12xx/wl1251_rx.c b/drivers/net/wireless/wl12xx/wl1251_rx.c
index af5c67b..8515158 100644
--- a/drivers/net/wireless/wl12xx/wl1251_rx.c
+++ b/drivers/net/wireless/wl12xx/wl1251_rx.c
@@ -183,6 +183,4 @@ void wl1251_rx(struct wl1251 *wl)
 
 	/* Finally, we need to ACK the RX */
 	wl1251_rx_ack(wl);
-
-	return;
 }
diff --git a/drivers/net/wireless/wl3501_cs.c b/drivers/net/wireless/wl3501_cs.c
index 1e61e6c..6449fe3 100644
--- a/drivers/net/wireless/wl3501_cs.c
+++ b/drivers/net/wireless/wl3501_cs.c
@@ -1452,8 +1452,6 @@ static void wl3501_detach(struct pcmcia_device *link)
 
 	if (link->priv)
 		free_netdev(link->priv);
-
-	return;
 }
 
 static int wl3501_get_name(struct net_device *dev, struct iw_request_info *info,
diff --git a/drivers/net/wireless/zd1201.c b/drivers/net/wireless/zd1201.c
index ece86a5..390d77f 100644
--- a/drivers/net/wireless/zd1201.c
+++ b/drivers/net/wireless/zd1201.c
@@ -134,7 +134,6 @@ static void zd1201_usbfree(struct urb *urb)
 
 	kfree(urb->transfer_buffer);
 	usb_free_urb(urb);
-	return;
 }
 
 /* cmdreq message: 
@@ -185,7 +184,6 @@ static void zd1201_usbtx(struct urb *urb)
 {
 	struct zd1201 *zd = urb->context;
 	netif_wake_queue(zd->dev);
-	return;
 }
 
 /* Incoming data */
@@ -407,7 +405,6 @@ exit:
 		wake_up(&zd->rxdataq);
 		kfree(urb->transfer_buffer);
 	}
-	return;
 }
 
 static int zd1201_getconfig(struct zd1201 *zd, int rid, void *riddata,
diff --git a/drivers/net/yellowfin.c b/drivers/net/yellowfin.c
index efbff76..4eb67ae 100644
--- a/drivers/net/yellowfin.c
+++ b/drivers/net/yellowfin.c
@@ -564,7 +564,6 @@ static void mdio_write(void __iomem *ioaddr, int phy_id, int location, int value
 	for (i = 10000; i >= 0; i--)
 		if ((ioread16(ioaddr + MII_Status) & 1) == 0)
 			break;
-	return;
 }
 
 
diff --git a/drivers/net/znet.c b/drivers/net/znet.c
index b9fd2f0..c3a3292 100644
--- a/drivers/net/znet.c
+++ b/drivers/net/znet.c
@@ -801,7 +801,6 @@ static void znet_rx(struct net_device *dev)
 	/* If any worth-while packets have been received, dev_rint()
 	   has done a mark_bh(INET_BH) for us and will work on them
 	   when we get to the bottom-half routine. */
-	return;
 }
 
 /* The inverse routine to znet_open(). */
diff --git a/drivers/net/zorro8390.c b/drivers/net/zorro8390.c
index 81c753a..4f7b9d6 100644
--- a/drivers/net/zorro8390.c
+++ b/drivers/net/zorro8390.c
@@ -430,7 +430,6 @@ static void zorro8390_block_output(struct net_device *dev, int count,
 
     z_writeb(ENISR_RDC, nic_base + NE_EN0_ISR);	/* Ack intr. */
     ei_status.dmaing &= ~0x01;
-    return;
 }
 
 static void __devexit zorro8390_remove_one(struct zorro_dev *z)


