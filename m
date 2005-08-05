From: Mateusz Berezecki <mateuszb@gmail.com>
Subject: atheros driver (8/8)
Date: Fri, 05 Aug 2005 05:01:40 +0200
Message-ID: <42F2D694.4040000@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------010809010300060901030803"
Cc: netdev <netdev@vger.kernel.org>
Return-path: <kernel-mentors-bounces@selenic.com>
To: kernel-mentors@selenic.com
List-Unsubscribe: <http://selenic.com/mailman/listinfo/kernel-mentors>,
	<mailto:kernel-mentors-request@selenic.com?subject=unsubscribe>
List-Archive: <http://www.selenic.com/pipermail/kernel-mentors>
List-Post: <mailto:kernel-mentors@selenic.com>
List-Help: <mailto:kernel-mentors-request@selenic.com?subject=help>
List-Subscribe: <http://selenic.com/mailman/listinfo/kernel-mentors>,
	<mailto:kernel-mentors-request@selenic.com?subject=subscribe>
Sender: kernel-mentors-bounces@selenic.com
Errors-To: kernel-mentors-bounces@selenic.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------010809010300060901030803
Content-Type: text/plain; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: 7bit



--------------010809010300060901030803
Content-Type: text/x-patch;
 name="atheros5212-8.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="atheros5212-8.patch"

diff -uprN -X 'netdev-2.6.git#ieee80211/Documentation/dontdiff' netdev-2.6.git#ieee80211/drivers/net/wireless/atheros/atheros5212/other.c netdev-atheros/drivers/net/wireless/atheros/atheros5212/other.c
--- netdev-2.6.git#ieee80211/drivers/net/wireless/atheros/atheros5212/other.c	1970-01-01 01:00:00.000000000 +0100
+++ netdev-atheros/drivers/net/wireless/atheros/atheros5212/other.c	2005-08-05 03:48:36.000000000 +0200
@@ -0,0 +1,57 @@
+/*
+ * All the work was created by reverse engineering and porting
+ * for interoperability. The creator is Mateusz Berezecki,
+ * unless explicitly marked ( some parts are derived
+ * from GPL'ed parts of madwifi project located at http://madwifi.sf.net)
+ *
+ * derived or copied parts of code licensed under
+ * dual GPL/BSD license
+ * Copyright (c) 2002-2005 Sam Leffler, Errno Consulting
+ * All rights reserved.
+ * 
+ * rest of the code has been reversed by me and is under copyright too
+ * Copyright (C) 2005  Mateusz Berezecki
+ * 
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version 2
+ * of the License, or (at your option) any later version.
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ * 
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
+ *
+ */
+
+
+#include <linux/config.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/version.h>
+#include <linux/init.h>
+#include <linux/delay.h>
+#include <linux/pci.h>
+#include <linux/netdevice.h>
+
+#include <net/ieee80211.h>
+
+#include <linux/wireless.h>
+#include <net/iw_handler.h>
+
+#include "atheros_id.h"
+#include "atheros_dev.h"
+#include "atheros_defs.h"
+#include "atheros_registers.h"
+#include "atheros.h"
+
+
+int ath_phy_disable(struct net_device *netdev)
+{
+	return ath_set_reset_register(netdev, AR5212_RC_BB);
+}
+
+
diff -uprN -X 'netdev-2.6.git#ieee80211/Documentation/dontdiff' netdev-2.6.git#ieee80211/drivers/net/wireless/atheros/atheros5212/powermodes.c netdev-atheros/drivers/net/wireless/atheros/atheros5212/powermodes.c
--- netdev-2.6.git#ieee80211/drivers/net/wireless/atheros/atheros5212/powermodes.c	1970-01-01 01:00:00.000000000 +0100
+++ netdev-atheros/drivers/net/wireless/atheros/atheros5212/powermodes.c	2005-08-05 03:48:36.000000000 +0200
@@ -0,0 +1,155 @@
+/*
+ * All the work was created by reverse engineering and porting
+ * for interoperability. The creator is Mateusz Berezecki,
+ * unless explicitly marked ( some parts are derived
+ * from GPL'ed parts of madwifi project located at http://madwifi.sf.net)
+ *
+ * derived or copied parts of code licensed under
+ * dual GPL/BSD license
+ * Copyright (c) 2002-2005 Sam Leffler, Errno Consulting
+ * All rights reserved.
+ * 
+ * rest of the code has been reversed by me and is under copyright too
+ * Copyright (C) 2005  Mateusz Berezecki
+ * 
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version 2
+ * of the License, or (at your option) any later version.
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ * 
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
+ *
+ */
+
+
+#include <linux/config.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/version.h>
+#include <linux/init.h>
+#include <linux/delay.h>
+#include <linux/pci.h>
+#include <linux/netdevice.h>
+
+#include <net/ieee80211.h>
+
+#include <linux/wireless.h>
+#include <net/iw_handler.h>
+
+#include "atheros_id.h"
+#include "atheros_dev.h"
+#include "atheros_defs.h"
+//#include "atheros_devops.h"
+//#include "atheros_regops.h"
+#include "atheros_registers.h"
+#include "atheros.h"
+
+
+/* don return power mode from private device data.
+ * use hardware instead. thats better */
+POWER_MODE ath_get_power_mode(struct net_device *netdev)
+{
+	unsigned int mode = ath_reg_read(netdev, AR5212_SCR);
+	mode &= (AR5212_SCR_SLE >> 16);
+	return mode;
+}
+
+/* zZzZ... */
+void ath_pmode_fullsleep(struct net_device *netdev, int set)
+{
+	ath_reg_enable(netdev, AR5212_STA_ID1, AR5212_STA_ID1_PWR_SV);
+	
+	if (set)
+		ath_reg_write(netdev, AR5212_SCR, 
+				AR5212_SCR_SLE_SLP);
+	return;
+}
+
+/* oh, my god, its 6 am already... */
+unsigned int ath_pmode_awake(struct net_device *netdev, int set)
+{
+	int i;
+	unsigned int tmp;
+	
+	if (set) {
+		ath_reg_write(netdev, 0x4004, 0);
+		udelay(10);
+		
+		for (i = 10; i != 0; i--) {
+			tmp = ath_reg_read(netdev, 0x4010);
+			if ((tmp & 0x00010000) == 0)
+				break;
+			udelay(200);
+			ath_reg_write(netdev, 0x4004, 0);
+		}
+		
+		if (i == 0) {
+			printk(KERN_DEBUG"atheros_pci: we are unlucky ;-(\n");
+			return 0;
+		}
+	}
+	
+	ath_reg_disable(netdev, 0x8004, 0x00040000);
+	return 1;
+}
+
+/* i dont know how it differs from fullsleep but OpenBSD doesnt have it:D
+ *
+ * note: thats probably used in power saving situations... */
+void ath_pmode_netsleep(struct net_device *netdev, 
+		int set, unsigned short sleepduration)
+{
+	ath_reg_enable(netdev, AR5212_STA_ID1, 
+		AR5212_STA_ID1_PWR_SV);
+	
+	if (set) 
+		ath_reg_write(netdev, AR5212_SCR, 
+			AR5212_SCR_SLE_ALLOW | sleepduration);
+	return;
+}
+
+
+/* set some power mode. nothing magical happens here */
+unsigned int ath_set_power_mode(struct net_device *netdev, 
+		POWER_MODE mode, int set, 
+		unsigned short sleep_duration)
+{
+	unsigned int ret = 0;
+	struct atheros_priv *pdata = ieee80211_priv(netdev);
+	
+	switch (mode) {
+		case PMODE_FULL_SLEEP:
+			ret = 1;
+			ath_pmode_fullsleep(netdev, set);
+			break;
+			
+		case PMODE_AWAKE:
+			ret = ath_pmode_awake(netdev, set);
+			break;
+			
+		case PMODE_NETWORK_SLEEP:
+			ath_pmode_netsleep(netdev, 
+				set, sleep_duration);
+			ret = 1;
+			break;
+			
+		default:
+			return 0;
+	}
+
+	pdata->pmode = mode;
+	return ret;
+}
+
+void ath_update_txpow(struct net_device *netdev)
+{
+
+}
+
+
diff -uprN -X 'netdev-2.6.git#ieee80211/Documentation/dontdiff' netdev-2.6.git#ieee80211/drivers/net/wireless/atheros/atheros5212/powermodes.h netdev-atheros/drivers/net/wireless/atheros/atheros5212/powermodes.h
--- netdev-2.6.git#ieee80211/drivers/net/wireless/atheros/atheros5212/powermodes.h	1970-01-01 01:00:00.000000000 +0100
+++ netdev-atheros/drivers/net/wireless/atheros/atheros5212/powermodes.h	2005-08-05 03:48:36.000000000 +0200
@@ -0,0 +1,57 @@
+/*
+ * All the work was created by reverse engineering and porting
+ * for interoperability. The creator is Mateusz Berezecki,
+ * unless explicitly marked ( some parts are derived
+ * from GPL'ed parts of madwifi project located at http://madwifi.sf.net)
+ *
+ * derived or copied parts of code licensed under
+ * dual GPL/BSD license
+ * Copyright (c) 2002-2005 Sam Leffler, Errno Consulting
+ * All rights reserved.
+ * 
+ * rest of the code has been reversed by me and is under copyright too
+ * Copyright (C) 2005  Mateusz Berezecki
+ * 
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version 2
+ * of the License, or (at your option) any later version.
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ * 
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
+ *
+ */
+#ifndef _POWERMODE_H
+#define _POWERMODE_H
+
+#include <linux/config.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/version.h>
+#include <linux/init.h>
+#include <linux/delay.h>
+#include <linux/pci.h>
+#include <linux/netdevice.h>
+
+#include <net/ieee80211.h>
+
+#include <linux/wireless.h>
+#include <net/iw_handler.h>
+
+#include "atheros_id.h"
+#include "atheros_dev.h"
+#include "atheros_defs.h"
+#include "regops.h"
+#include "atheros_registers.h"
+#include "atheros.h"
+
+POWER_MODE ath_get_power_mode(struct net_device *);
+unsigned int ath_set_power_mode(struct net_device *, 
+		POWER_MODE, int, unsigned short);
+
+#endif
diff -uprN -X 'netdev-2.6.git#ieee80211/Documentation/dontdiff' netdev-2.6.git#ieee80211/drivers/net/wireless/atheros/atheros5212/regops.c netdev-atheros/drivers/net/wireless/atheros/atheros5212/regops.c
--- netdev-2.6.git#ieee80211/drivers/net/wireless/atheros/atheros5212/regops.c	1970-01-01 01:00:00.000000000 +0100
+++ netdev-atheros/drivers/net/wireless/atheros/atheros5212/regops.c	2005-08-05 03:48:36.000000000 +0200
@@ -0,0 +1,83 @@
+/*
+ * All the work was created by reverse engineering and porting
+ * for interoperability. The creator is Mateusz Berezecki,
+ * unless explicitly marked ( some parts are derived
+ * from GPL'ed parts of madwifi project located at http://madwifi.sf.net)
+ *
+ * derived or copied parts of code licensed under
+ * dual GPL/BSD license
+ * Copyright (c) 2002-2005 Sam Leffler, Errno Consulting
+ * All rights reserved.
+ * 
+ * rest of the code has been reversed by me and is under copyright too
+ * Copyright (C) 2005  Mateusz Berezecki
+ * 
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version 2
+ * of the License, or (at your option) any later version.
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ * 
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
+ *
+ */
+
+
+#include <linux/config.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/version.h>
+#include <linux/init.h>
+#include <linux/delay.h>
+#include <linux/pci.h>
+#include <linux/netdevice.h>
+
+#include <net/ieee80211.h>
+
+#include <linux/wireless.h>
+#include <net/iw_handler.h>
+
+#include "atheros_id.h"
+#include "atheros_dev.h"
+#include "atheros_defs.h"
+#include "atheros_registers.h"
+#include "atheros.h"
+
+
+/* write to hardware register. thats for little endian hosts
+ * right now. I/or someone else has to add  support for big endians */
+void ath_reg_write(struct net_device *netdev, 
+		unsigned int reg, unsigned int val)
+{       
+	*((volatile unsigned int *)(netdev->mem_start + reg)) = val;
+	return;
+}
+
+/* reads from hw. same note as above */
+unsigned int ath_reg_read(struct net_device *netdev, unsigned int reg)
+{       
+	return (*((volatile u_int32_t *)(netdev->mem_start + reg)));
+}       
+
+/* just a wrapper. look above */
+void ath_reg_enable(struct net_device *netdev, 
+		unsigned int reg, unsigned int flags)
+{       
+	unsigned int tmp = ath_reg_read(netdev, reg);
+	ath_reg_write(netdev, reg, tmp | flags);
+}
+
+/* look above */
+void ath_reg_disable(struct net_device *netdev,
+		unsigned int reg, unsigned int flags)
+{
+	unsigned int val = ath_reg_read(netdev, reg);
+	val = val & ~flags;
+	ath_reg_write(netdev, reg, val);
+}
+
diff -uprN -X 'netdev-2.6.git#ieee80211/Documentation/dontdiff' netdev-2.6.git#ieee80211/drivers/net/wireless/atheros/atheros5212/regops.h netdev-atheros/drivers/net/wireless/atheros/atheros5212/regops.h
--- netdev-2.6.git#ieee80211/drivers/net/wireless/atheros/atheros5212/regops.h	1970-01-01 01:00:00.000000000 +0100
+++ netdev-atheros/drivers/net/wireless/atheros/atheros5212/regops.h	2005-08-05 03:48:36.000000000 +0200
@@ -0,0 +1,62 @@
+/*
+ * All the work was created by reverse engineering and porting
+ * for interoperability. The creator is Mateusz Berezecki,
+ * unless explicitly marked ( some parts are derived
+ * from GPL'ed parts of madwifi project located at http://madwifi.sf.net)
+ *
+ * derived or copied parts of code licensed under
+ * dual GPL/BSD license
+ * Copyright (c) 2002-2005 Sam Leffler, Errno Consulting
+ * All rights reserved.
+ * 
+ * rest of the code has been reversed by me and is under copyright too
+ * Copyright (C) 2005  Mateusz Berezecki
+ * 
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version 2
+ * of the License, or (at your option) any later version.
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ * 
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
+ *
+ */
+
+
+#ifndef _REGOPS_H
+#define _REGOPS_H
+
+#include <linux/config.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/version.h>
+#include <linux/init.h>
+#include <linux/delay.h>
+#include <linux/pci.h>
+#include <linux/netdevice.h>
+
+#include <net/ieee80211.h>
+
+#include <linux/wireless.h>
+#include <net/iw_handler.h>
+
+#include "atheros_id.h"
+#include "atheros_dev.h"
+#include "atheros_defs.h"
+#include "atheros_registers.h"
+#include "atheros.h"
+
+void ath_reg_write(struct net_device *, unsigned int, unsigned int);
+unsigned int ath_reg_read(struct net_device *, unsigned int);
+void ath_reg_enable(struct net_device *, unsigned int, unsigned int);
+void ath_reg_disable(struct net_device *,unsigned int, unsigned int);
+
+
+
+
+#endif
diff -uprN -X 'netdev-2.6.git#ieee80211/Documentation/dontdiff' netdev-2.6.git#ieee80211/drivers/net/wireless/atheros/atheros5212/transmit_receive.c netdev-atheros/drivers/net/wireless/atheros/atheros5212/transmit_receive.c
--- netdev-2.6.git#ieee80211/drivers/net/wireless/atheros/atheros5212/transmit_receive.c	1970-01-01 01:00:00.000000000 +0100
+++ netdev-atheros/drivers/net/wireless/atheros/atheros5212/transmit_receive.c	2005-08-05 03:48:36.000000000 +0200
@@ -0,0 +1,433 @@
+/*
+ * All the work was created by reverse engineering and porting
+ * for interoperability. The creator is Mateusz Berezecki,
+ * unless explicitly marked ( some parts are derived
+ * from GPL'ed parts of madwifi project located at http://madwifi.sf.net)
+ *
+ * derived or copied parts of code licensed under
+ * dual GPL/BSD license
+ * Copyright (c) 2002-2005 Sam Leffler, Errno Consulting
+ * All rights reserved.
+ * 
+ * rest of the code has been reversed by me and is under copyright too
+ * Copyright (C) 2005  Mateusz Berezecki
+ * 
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version 2
+ * of the License, or (at your option) any later version.
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ * 
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
+ *
+ */
+
+#include <linux/config.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/version.h>
+#include <linux/init.h>
+#include <linux/delay.h>
+#include <linux/pci.h>
+#include <linux/netdevice.h>
+
+#include <net/ieee80211.h>
+
+#include <linux/wireless.h>
+#include <net/iw_handler.h>
+
+#include "atheros_id.h"
+#include "atheros_dev.h"
+#include "atheros_defs.h"
+//#include "atheros_devops.h"
+//#include "atheros_regops.h"
+#include "atheros_registers.h"
+#include "atheros.h"
+#include "eeprom.h"
+
+int ath_stopdmarecv(struct net_device *netdev)
+{
+	ath_reg_write(netdev, AR5212_CR, AR5212_CR_RXD);
+	if (ath_timed_read(netdev, AR5212_CR, AR5212_CR_RXE, 0) == 0) {
+		printk(KERN_DEBUG"atheros: failed to stop DMA engine.\n");
+		return 0;
+	}
+
+	return 1;
+}
+
+void ath_stoppcurecv(struct net_device *netdev)
+{
+	ath_reg_enable(netdev, AR5212_DIAG_SW, AR5212_DIAG_SW_DIS_RX); 
+}
+
+/* TODO: add routines for starting dma/pcu recv */
+
+
+int ath_startrecv(struct net_device *netdev)
+{
+	/* XXX TODO fix it asap ;-) that one comes directly
+	 * from madwifi source */
+#if 0
+	struct atheros_priv *p = ieee80211_priv(netdev);
+	struct ath_buf *bf;
+
+	if (sc->sc_ic.ic_opmode == IEEE80211_M_MONITOR) {
+		sc->sc_rxbufsize = roundup(IEEE80211_MAX_LEN, sc->sc_cachelsz);
+	} else {
+		sc->sc_rxbufsize = roundup(sizeof(struct ieee80211_frame) +
+				dev->mtu + IEEE80211_CRC_LEN +
+				(IEEE80211_WEP_IVLEN + IEEE80211_WEP_KIDLEN +
+				 IEEE80211_WEP_CRCLEN), sc->sc_cachelsz);
+	}
+
+	p->rxlink = NULL;
+	STAILQ_FOREACH(bf, &p->rxbuf, bf_list) {
+		int error = ath_rxbuf_init(sc, bf);
+		if (error != 0) {
+			printk(KERN_DEBUG"atheros: startrecv failed\n");
+			return error;
+		}
+	}
+	
+	bf = STAILQ_FIRST(&p->rxbuf);
+	ath_putrxbuf(netdev, bf->bf_daddr);
+	ath_rxena(ah);              /* enable recv descriptors */
+	ath_mode_init(dev);             /* set filters, etc. */
+	ath_startpcurecv(ah);       /* re-enable PCU/DMA engine */
+#endif	
+	return 0;
+}
+
+void ath_setrxfilter(struct net_device *netdev, unsigned int mask)
+{
+	unsigned int val;
+
+	ath_reg_write(netdev, AR5212_RX_FILTER, mask & 0xff);
+	val = 0;
+
+	if (mask & 0x200)
+		val |= 0x20;
+
+	if (mask & 0x100)
+		val |= 0x10;
+
+	ath_reg_write(netdev, AR5212_PHY_ERR_FIL, val);
+
+	if (val)
+		ath_reg_enable(netdev, AR5212_RXCFG, AR5212_RXCFG_ZLFDMA);  
+	else
+		ath_reg_disable(netdev, AR5212_RXCFG, AR5212_RXCFG_ZLFDMA);
+
+}
+
+void ath_draintxq(struct net_device *netdev)
+{
+	struct atheros_priv *p = ieee80211_priv(netdev);
+	int i;
+	
+	/* XXX return value */
+	if (!p->invalid) {
+		/* don't touch the hardware if marked invalid */
+		/*
+		(void) ath_stoptxdma(netdev, p->bhalq);
+		
+		for (i = 0; i < HAL_NUM_TX_QUEUES; i++) {
+			if (ATH_TXQ_SETUP(sc, i))
+				ath_tx_stopdma(netdev, &p->txq[i]);
+		}
+		*/
+	}
+	netdev->trans_start = jiffies;
+	
+	netif_start_queue(netdev); 
+	/* XXX
+	for (i = 0; i < HAL_NUM_TX_QUEUES; i++) {
+		if (ATH_TXQ_SETUP(netdev, i))
+			ath_tx_draintxq(netdev, &p->txq[i]);
+	}
+	sc->sc_tx_timer = 0;
+	*/
+}
+
+void ath_stoprecv(struct net_device *netdev)
+{
+	struct atheros_priv *p = ieee80211_priv(netdev);
+	
+	ath_stoppcurecv(netdev);        /* disable PCU */
+	ath_setrxfilter(netdev, 0);     /* clear recv filter */
+	ath_stopdmarecv(netdev);        /* disable DMA engine */
+	udelay(3);                      /* 3ms is long enough for 1 frame */
+
+	p->rxlink = NULL;
+}
+
+
+unsigned int ath_setup_xtx_desc(struct net_device *netdev, struct ath_desc *desc,
+			unsigned int txrate1, unsigned int txtries1,
+			unsigned int txrate2, unsigned int txtries2,
+			unsigned int txrate3, unsigned int txtries3)
+{
+	if (txtries1 != 0) {
+		desc->u.tx.ctl2 |= (txtries1 << 20) & 0xf00000;
+		desc->u.tx.ctl3 |= (txrate1 << 5);
+	}
+	if (txtries2 != 0) {
+		desc->u.tx.ctl2 |= (txtries2 << 24) & 0xf000000;
+		desc->u.tx.ctl3 |= (txrate2 << 10);
+	}
+	if (txtries3 != 0) {
+		desc->u.tx.ctl2 |= (txtries3 << 28);
+		desc->u.tx.ctl3 |= (txrate3 << 15); 
+	}
+
+	return 1;
+}
+
+unsigned int ath_set_tx_queue_params(struct net_device *netdev,
+		unsigned int q, struct tx_queue_info *txi)
+{
+	struct atheros_priv *p = ieee80211_priv(netdev);
+
+	if (p->txq_info[q].tqi_type == 0)
+		return 0;
+
+	/* Q: why just do not memcopy it ? */
+	p->txq_info[q].tqi_ver = txi->tqi_ver;
+	p->txq_info[q].tqi_subtype = txi->tqi_subtype;
+	p->txq_info[q].tqi_qflags = txi->tqi_qflags;
+	p->txq_info[q].tqi_priority = txi->tqi_priority;
+	p->txq_info[q].tqi_aifs = txi->tqi_aifs;
+	p->txq_info[q].tqi_cwmin = txi->tqi_cwmin;
+	p->txq_info[q].tqi_cwmax = txi->tqi_cwmax;
+	p->txq_info[q].tqi_cbrPeriod = txi->tqi_cbrPeriod;
+	p->txq_info[q].tqi_cbrOverflowLimit = txi->tqi_cbrOverflowLimit;
+	p->txq_info[q].tqi_burstTime = txi->tqi_burstTime;
+	p->txq_info[q].tqi_readyTime = txi->tqi_readyTime;
+
+	switch (txi->tqi_subtype) {
+		case WME_AC_VI:
+		case WME_AC_VO:
+		case WME_UPSD:
+			if (p->txq_info[q].tqi_type == TX_QUEUE_DATA)
+				p->txq_info[q].tqi_flags = 1;
+			break;
+		default:
+			break;
+	}
+
+	return 1;
+}
+
+unsigned int ath_setup_tx_queue(struct net_device *netdev,
+		unsigned int type, struct tx_queue_info *txi)
+{
+	struct atheros_priv *p = ieee80211_priv(netdev);
+	int q;
+	
+	switch (type) {
+		case 2:
+			q = 9;		
+			break;
+		default:
+			return 0;
+	}
+
+	memset(&p->tx_queues[q], 0, sizeof(struct tx_queue_info));
+	p->txq_info[q].tqi_type = type;
+	
+	if (txi != NULL) {
+		ath_set_tx_queue_params(netdev, q, txi);
+	}
+
+	p->intr_mask |= 1 << q;
+	return q;
+}
+
+struct tx_queue *ath_txq_setup(struct net_device *netdev,
+		int qtype, int subtype)
+{
+	struct atheros_priv *p = ieee80211_priv(netdev);
+	struct tx_queue_info qi;
+	int qnum;
+
+	memset(&qi, 0, sizeof(qi));
+	qi.tqi_subtype = subtype;
+	qi.tqi_aifs = 0xffffffff;
+	qi.tqi_cwmin = 0xffffffff;
+	qi.tqi_cwmax = 0xffffffff;
+	qi.tqi_qflags = TXQ_FLAG_TXEOLINT_ENABLE | TXQ_FLAG_TXDESCINT_ENABLE;
+	qnum = ath_setup_tx_queue(netdev, qtype, &qi);
+	if (qnum == -1) {
+		return NULL;
+	}
+	
+	if (p->tx_setup & (1 << qnum)) {
+		struct tx_queue *txq = &p->tx_queues[qnum];
+
+		txq->axq_qnum = qnum;
+		txq->axq_depth = 0;
+		txq->axq_intrcnt = 0;
+		txq->axq_link = NULL;
+		/* XXX 
+		STAILQ_INIT(&txq->axq_q);
+		ATH_TXQ_LOCK_INIT(sc, txq);
+		*/
+		p->tx_setup |= 1<<qnum;
+	}
+	return &p->tx_queues[qnum];
+}
+
+
+/*
+ * RECEIVE PART
+ */
+
+unsigned int ath_get_rx_desc(struct net_device *netdev, 
+		unsigned int descriptor)
+{
+	return ath_reg_read(netdev, AR5212_RXDP); 
+}
+
+void ath_set_rx_desc(struct net_device *netdev,
+		unsigned int descriptor)
+{
+	ath_reg_write(netdev, AR5212_RXDP, descriptor);
+	ath_reg_read(netdev, AR5212_RXDP);
+}
+
+void ath_enable_receive(struct net_device *netdev)
+{
+	ath_reg_write(netdev, AR5212_CR, AR5212_CR_RXE);  
+}
+
+
+unsigned int ath_stop_dma_recv(struct net_device *netdev)
+{
+	ath_reg_write(netdev, AR5212_CR, AR5212_CR_RXD);
+	if (!ath_timed_read(netdev, AR5212_CR, AR5212_CR_RXE, 0)) {
+		printk(KERN_DEBUG"atheros: failed to stop DMA\n");
+		return 0;
+	}
+	return 1;
+}
+
+
+void ath_set_multicast_fltr(struct net_device *netdev, 
+		unsigned int fil0, unsigned int fil1)
+{
+	ath_reg_write(netdev, AR5212_MCAST_FIL0, fil0);
+	ath_reg_write(netdev, AR5212_MCAST_FIL1, fil1);	
+}
+
+unsigned int ath_set_multicast_filter_idx(struct net_device *netdev, unsigned int idx)
+{
+	unsigned int val;
+	
+	if (idx >= 64)
+		return 0;
+	
+	if (idx >= 32) {
+		val = ath_reg_read(netdev, AR5212_MCAST_FIL1);
+		ath_reg_write(netdev, AR5212_MCAST_FIL1, (val | (1<<(idx-32))));
+	} else {
+		val = ath_reg_read(netdev, AR5212_MCAST_FIL0);
+		ath_reg_write(netdev, AR5212_MCAST_FIL0, (val | (1<<idx)));
+	}
+	return 1;
+}
+
+unsigned int ath_clr_multicast_fltr_idx(struct net_device *netdev, unsigned int idx)
+{
+	unsigned int val;
+	
+	if (idx >= 64)
+		return 0;
+	
+	if (idx >= 32) {
+		val = ath_reg_read(netdev, AR5212_MCAST_FIL1);
+		ath_reg_write(netdev, AR5212_MCAST_FIL1, (val &~ (1<<(idx-32))));
+	} else {
+		val = ath_reg_read(netdev, AR5212_MCAST_FIL0);
+		ath_reg_write(netdev, AR5212_MCAST_FIL0, (val &~ (1<<idx)));
+	}
+	return 1;
+}
+
+unsigned int ath_get_rx_filter(struct net_device *netdev)
+{
+	unsigned int bits = ath_reg_read(netdev, AR5212_RX_FILTER);
+	unsigned int phy = ath_reg_read(netdev, AR5212_PHY_ERR_FIL);
+	
+	if (phy & AR5212_PHY_ERR_FIL_RADAR)
+		bits |= RX_FILTER_PHYRADAR;
+	if (phy & (AR5212_PHY_ERR_FIL_OFDM|AR5212_PHY_ERR_FIL_CCK))
+		bits |= RX_FILTER_PHYERR;
+	return bits;
+}
+
+unsigned int ath_setup_rx_desc(struct net_device *netdev, struct ath_desc *ds,
+		unsigned int size, unsigned int flags)
+{
+	ds->ctl0 = 0;
+	ds->ctl1 = size & 0xfff;
+	if (ds->ctl1 != size) {
+		return 0;
+	}
+	
+	if (flags & 0x20)
+		ds->ctl1 |= 0x2000;
+	
+	ds->u.rx.status0 = ds->u.rx.status1 = 0;
+	
+	return 1;
+}
+
+int ath_proc_rx_desc(struct net_device *netdev, struct ath_desc *ds,
+		unsigned int cx, struct ath_desc *nds)
+{
+	if ((ds->u.rx.status1 & 1) == 0)
+		return EINPROGRESS;
+	
+	if ((nds->u.rx.status1 & 1) == 0 && ath_reg_read(netdev, AR5212_RXDP) == cx)
+		return EINPROGRESS;
+	
+	ds->s.rxstat.rs_datalen = ds->u.rx.status0 & 0xfff;
+	ds->s.rxstat.rs_tstamp = (ds->u.rx.status1 & 0x7fff0000) >> 16;
+	ds->s.rxstat.rs_status = 0;
+	
+	if ((ds->u.rx.status1 & 2) == 0) {
+		if (ds->u.rx.status1 & 4) /* CRC Error */
+			ds->s.rxstat.rs_status |= RXERR_CRC;
+		if (ds->u.rx.status1 & 8) /* crc decrypt error */
+			ds->s.rxstat.rs_status |= RXERR_DECRYPT;
+		if (ds->u.rx.status1 & 32) /* MIC error */
+			ds->s.rxstat.rs_status |= RXERR_MIC;
+		if (ds->u.rx.status1 & 16) { /* PHY error */
+			unsigned int phyerr;
+			//ds->s.rxstat.rs_status |= RXERR_PHY;
+			//phyerr = MS(ads->ds_rxstatus1, AR_PHYErrCode);
+			//ds->s.rxstat.rs_phyerr = phyerr;
+		}
+	}
+
+
+	ds->s.rxstat.rs_rssi = (ds->u.rx.status0 & 0x0ff00000) >> 20;
+	if (ds->u.rx.status1 & 0x100)
+		ds->s.rxstat.rs_keyix = (ds->u.rx.status1 & 0xfe00) >> 9; 
+	else
+		ds->s.rxstat.rs_keyix = 0xff;
+	
+	
+	ds->s.rxstat.rs_rate = (ds->u.rx.status0 & 0xf8000) >> 15;
+	ds->s.rxstat.rs_antenna  = (ds->u.rx.status0 & 0xf0000000) >> 28;
+	ds->s.rxstat.rs_more = (ds->u.rx.status0 & 0x1000) ? 1 : 0;
+	
+	return 1;
+}
+
diff -uprN -X 'netdev-2.6.git#ieee80211/Documentation/dontdiff' netdev-2.6.git#ieee80211/drivers/net/wireless/atheros/atheros5212/transmit_receive.h netdev-atheros/drivers/net/wireless/atheros/atheros5212/transmit_receive.h
--- netdev-2.6.git#ieee80211/drivers/net/wireless/atheros/atheros5212/transmit_receive.h	1970-01-01 01:00:00.000000000 +0100
+++ netdev-atheros/drivers/net/wireless/atheros/atheros5212/transmit_receive.h	2005-08-05 03:48:36.000000000 +0200
@@ -0,0 +1,62 @@
+/*
+ * All the work was created by reverse engineering and porting
+ * for interoperability. The creator is Mateusz Berezecki,
+ * unless explicitly marked ( some parts are derived
+ * from GPL'ed parts of madwifi project located at http://madwifi.sf.net)
+ *
+ * derived or copied parts of code licensed under
+ * dual GPL/BSD license
+ * Copyright (c) 2002-2005 Sam Leffler, Errno Consulting
+ * All rights reserved.
+ * 
+ * rest of the code has been reversed by me and is under copyright too
+ * Copyright (C) 2005  Mateusz Berezecki
+ * 
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version 2
+ * of the License, or (at your option) any later version.
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ * 
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
+ *
+ */
+
+
+#ifndef _TRANSMIT_RECEIVE_H
+#define _TRANSMIT_RECEIVE_H
+
+#include <linux/config.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/version.h>
+#include <linux/init.h>
+#include <linux/delay.h>
+#include <linux/pci.h>
+#include <linux/netdevice.h>
+
+#include <net/ieee80211.h>
+
+#include <linux/wireless.h>
+#include <net/iw_handler.h>
+
+#include "atheros_id.h"
+#include "atheros_dev.h"
+#include "atheros_defs.h"
+//#include "atheros_devops.h"
+//#include "atheros_regops.h"
+#include "atheros_registers.h"
+#include "atheros.h"
+#include "eeprom.h"
+
+unsigned int ath_setup_xtx_desc(struct net_device *, struct ath_desc *,
+			unsigned int, unsigned int, unsigned int,
+			unsigned int, unsigned int, unsigned int);
+
+
+#endif

--------------010809010300060901030803
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Kernel-mentors mailing list
Kernel-mentors@selenic.com
http://selenic.com/mailman/listinfo/kernel-mentors

--------------010809010300060901030803--
