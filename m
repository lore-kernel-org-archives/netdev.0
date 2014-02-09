From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 3/6] staging: r8188eu: Remove some dead code from headers
Date: Sun,  9 Feb 2014 15:15:56 -0600
Message-ID: <1391980559-24288-4-git-send-email-Larry.Finger@lwfinger.net>
References: <1391980559-24288-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: netdev@vger.kernel.org, devel@driverdev.osuosl.org,
	Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f172.google.com ([209.85.214.172]:42449 "EHLO
	mail-ob0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751786AbaBIVQK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Feb 2014 16:16:10 -0500
Received: by mail-ob0-f172.google.com with SMTP id vb8so6448759obc.31
        for <netdev@vger.kernel.org>; Sun, 09 Feb 2014 13:16:10 -0800 (PST)
In-Reply-To: <1391980559-24288-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The headers for this driver contain a number of unused structs and macros
that are removed. File include/ioctl_cfg80211.h is now empty and was
deleted.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/staging/rtl8188eu/include/ioctl_cfg80211.h | 107 ---------------------
 drivers/staging/rtl8188eu/include/rtw_io.h         |  44 ---------
 drivers/staging/rtl8188eu/include/rtw_mlme.h       |  32 ------
 drivers/staging/rtl8188eu/os_dep/rtw_android.c     |   1 -
 4 files changed, 184 deletions(-)
 delete mode 100644 drivers/staging/rtl8188eu/include/ioctl_cfg80211.h

diff --git a/drivers/staging/rtl8188eu/include/ioctl_cfg80211.h b/drivers/staging/rtl8188eu/include/ioctl_cfg80211.h
deleted file mode 100644
index 037e9a5..0000000
--- a/drivers/staging/rtl8188eu/include/ioctl_cfg80211.h
+++ /dev/null
@@ -1,107 +0,0 @@
-/******************************************************************************
- *
- * Copyright(c) 2007 - 2011 Realtek Corporation. All rights reserved.
- *
- * This program is free software; you can redistribute it and/or modify it
- * under the terms of version 2 of the GNU General Public License as
- * published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but WITHOUT
- * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
- * FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
- * more details.
- *
- * You should have received a copy of the GNU General Public License along with
- * this program; if not, write to the Free Software Foundation, Inc.,
- * 51 Franklin Street, Fifth Floor, Boston, MA 02110, USA
- *
- *
- ******************************************************************************/
-#ifndef __IOCTL_CFG80211_H__
-#define __IOCTL_CFG80211_H__
-
-struct rtw_wdev_invit_info {
-	u8 token;
-	u8 flags;
-	u8 status;
-	u8 req_op_ch;
-	u8 rsp_op_ch;
-};
-
-#define rtw_wdev_invit_info_init(invit_info) \
-	do { \
-		(invit_info)->token = 0; \
-		(invit_info)->flags = 0x00; \
-		(invit_info)->status = 0xff; \
-		(invit_info)->req_op_ch = 0; \
-		(invit_info)->rsp_op_ch = 0; \
-	} while (0)
-
-struct rtw_wdev_priv {
-	struct wireless_dev *rtw_wdev;
-
-	struct adapter *padapter;
-
-	struct cfg80211_scan_request *scan_request;
-	spinlock_t scan_req_lock;
-
-	struct net_device *pmon_ndev;/* for monitor interface */
-	char ifname_mon[IFNAMSIZ + 1]; /* name of monitor interface */
-
-	u8 p2p_enabled;
-
-	u8 provdisc_req_issued;
-
-	struct rtw_wdev_invit_info invit_info;
-
-	u8 bandroid_scan;
-	bool block;
-	bool power_mgmt;
-};
-
-#define wdev_to_priv(w) ((struct rtw_wdev_priv *)(wdev_priv(w)))
-
-#define wiphy_to_wdev(x)				\
-((struct wireless_dev *)(((struct rtw_wdev_priv *)wiphy_priv(x))->rtw_wdev))
-
-int rtw_wdev_alloc(struct adapter *padapter, struct device *dev);
-void rtw_wdev_free(struct wireless_dev *wdev);
-void rtw_wdev_unregister(struct wireless_dev *wdev);
-
-void rtw_cfg80211_init_wiphy(struct adapter *padapter);
-
-void rtw_cfg80211_surveydone_event_callback(struct adapter *padapter);
-
-void rtw_cfg80211_indicate_connect(struct adapter *padapter);
-void rtw_cfg80211_indicate_disconnect(struct adapter *padapter);
-void rtw_cfg80211_indicate_scan_done(struct rtw_wdev_priv *pwdev_priv,
-				     bool aborted);
-
-#ifdef CONFIG_88EU_AP_MODE
-void rtw_cfg80211_indicate_sta_assoc(struct adapter *padapter,
-				     u8 *pmgmt_frame, uint frame_len);
-void rtw_cfg80211_indicate_sta_disassoc(struct adapter *padapter,
-					unsigned char *da,
-					unsigned short reason);
-#endif /* CONFIG_88EU_AP_MODE */
-
-void rtw_cfg80211_issue_p2p_provision_request(struct adapter *padapter,
-					      const u8 *buf, size_t len);
-void rtw_cfg80211_rx_p2p_action_public(struct adapter *padapter,
-				       u8 *pmgmt_frame, uint frame_len);
-void rtw_cfg80211_rx_action_p2p(struct adapter *padapter, u8 *pmgmt_frame,
-				uint frame_len);
-void rtw_cfg80211_rx_action(struct adapter *adapter, u8 *frame,
-			    uint frame_len, const char *msg);
-
-int rtw_cfg80211_set_mgnt_wpsp2pie(struct net_device *net,
-				   char *buf, int len, int type);
-
-bool rtw_cfg80211_pwr_mgmt(struct adapter *adapter);
-
-#define rtw_cfg80211_rx_mgmt(dev, freq, sig_dbm, buf, len, gfp)		\
-	cfg80211_rx_mgmt(dev, freq, sig_dbm, buf, len, gfp)
-#define rtw_cfg80211_send_rx_assoc(dev, bss, buf, len)			\
-	cfg80211_send_rx_assoc(dev, bss, buf, len)
-
-#endif /* __IOCTL_CFG80211_H__ */
diff --git a/drivers/staging/rtl8188eu/include/rtw_io.h b/drivers/staging/rtl8188eu/include/rtw_io.h
index 3d1dfcc..e8790f8 100644
--- a/drivers/staging/rtl8188eu/include/rtw_io.h
+++ b/drivers/staging/rtl8188eu/include/rtw_io.h
@@ -99,7 +99,6 @@
 
 struct intf_priv;
 struct intf_hdl;
-struct io_queue;
 
 struct _io_ops {
 	u8 (*_read8)(struct intf_hdl *pintfhdl, u32 addr);
@@ -117,7 +116,6 @@ struct _io_ops {
 			  u8 *pmem);
 	void (*_write_mem)(struct intf_hdl *pintfhdl, u32 addr, u32 cnt,
 			   u8 *pmem);
-	void (*_sync_irp_protocol_rw)(struct io_queue *pio_q);
 	u32 (*_read_interrupt)(struct intf_hdl *pintfhdl, u32 addr);
 	u32 (*_read_port)(struct intf_hdl *pintfhdl, u32 addr, u32 cnt,
 			  u8 *pmem);
@@ -237,34 +235,11 @@ struct reg_protocol_wt {
 Below is the data structure used by _io_handler
 */
 
-struct io_queue {
-	spinlock_t lock;
-	struct list_head free_ioreqs;
-	struct list_head pending;	/* The io_req list that will be served
-					 * in the single protocol read/write.*/
-	struct list_head processing;
-	u8	*free_ioreqs_buf; /*  4-byte aligned */
-	u8	*pallocated_free_ioreqs_buf;
-	struct	intf_hdl	intf;
-};
-
 struct io_priv {
 	struct adapter *padapter;
 	struct intf_hdl intf;
 };
 
-uint ioreq_flush(struct adapter *adapter, struct io_queue *ioqueue);
-void sync_ioreq_enqueue(struct io_req *preq, struct io_queue *ioqueue);
-uint sync_ioreq_flush(struct adapter *adapter, struct io_queue *ioqueue);
-uint free_ioreq(struct io_req *preq, struct io_queue *pio_queue);
-struct io_req *alloc_ioreq(struct io_queue *pio_q);
-
-uint register_intf_hdl(u8 *dev, struct intf_hdl *pintfhdl);
-void unregister_intf_hdl(struct intf_hdl *pintfhdl);
-
-void _rtw_attrib_read(struct adapter *adapter, u32 addr, u32 cnt, u8 *pmem);
-void _rtw_attrib_write(struct adapter *adapter, u32 addr, u32 cnt, u8 *pmem);
-
 u8 _rtw_read8(struct adapter *adapter, u32 addr);
 u16 _rtw_read16(struct adapter *adapter, u32 addr);
 u32 _rtw_read32(struct adapter *adapter, u32 addr);
@@ -363,25 +338,6 @@ void async_write_port(struct adapter *adapter, u32 addr, u32 cnt, u8 *pmem);
 int rtw_init_io_priv(struct adapter *padapter,
 		     void (*set_intf_ops)(struct _io_ops *pops));
 
-uint alloc_io_queue(struct adapter *adapter);
-void free_io_queue(struct adapter *adapter);
-void async_bus_io(struct io_queue *pio_q);
-void bus_sync_io(struct io_queue *pio_q);
-u32 _ioreq2rwmem(struct io_queue *pio_q);
 void dev_power_down(struct adapter *Adapter, u8 bpwrup);
 
-#define PlatformEFIOWrite1Byte(_a, _b, _c)		\
-	rtw_write8(_a, _b, _c)
-#define PlatformEFIOWrite2Byte(_a, _b, _c)		\
-	rtw_write16(_a, _b, _c)
-#define PlatformEFIOWrite4Byte(_a, _b, _c)		\
-	rtw_write32(_a, _b, _c)
-
-#define PlatformEFIORead1Byte(_a, _b)		\
-		rtw_read8(_a, _b)
-#define PlatformEFIORead2Byte(_a, _b)		\
-		rtw_read16(_a, _b)
-#define PlatformEFIORead4Byte(_a, _b)		\
-		rtw_read32(_a, _b)
-
 #endif	/* _RTL8711_IO_H_ */
diff --git a/drivers/staging/rtl8188eu/include/rtw_mlme.h b/drivers/staging/rtl8188eu/include/rtw_mlme.h
index 6cd988f..45c22ef 100644
--- a/drivers/staging/rtl8188eu/include/rtw_mlme.h
+++ b/drivers/staging/rtl8188eu/include/rtw_mlme.h
@@ -106,13 +106,6 @@ SHALL not lock up more than one lock at a time!
 #define traffic_threshold	10
 #define	traffic_scan_period	500
 
-struct sitesurvey_ctrl {
-	u64	last_tx_pkts;
-	uint	last_rx_pkts;
-	int	traffic_busy;
-	struct timer_list sitesurvey_ctrl_timer;
-};
-
 struct rt_link_detect {
 	u32	NumTxOkInPeriod;
 	u32	NumRxOkInPeriod;
@@ -304,31 +297,6 @@ struct wifidirect_info {
 	u32 noa_start_time[P2P_MAX_NOA_NUM];
 };
 
-struct tdls_ss_record {	/* signal strength record */
-	u8 macaddr[ETH_ALEN];
-	u8 RxPWDBAll;
-	u8 is_tdls_sta;	/*  true: direct link sta, false: else */
-};
-
-struct tdls_info {
-	u8 ap_prohibited;
-	uint setup_state;
-	u8 sta_cnt;
-	u8 sta_maximum;	/*  1:tdls sta is equal (NUM_STA-1), reach max direct link number; 0: else; */
-	struct tdls_ss_record	ss_record;
-	u8 macid_index;	/* macid entry that is ready to write */
-	u8 clear_cam;	/* cam entry that is trying to clear, using it in direct link teardown */
-	u8 ch_sensing;
-	u8 cur_channel;
-	u8 candidate_ch;
-	u8 collect_pkt_num[MAX_CHANNEL_NUM];
-	spinlock_t cmd_lock;
-	spinlock_t hdl_lock;
-	u8 watchdog_count;
-	u8 dev_discovered;		/* WFD_TDLS: for sigma test */
-	u8 enable;
-};
-
 struct mlme_priv {
 	spinlock_t lock;
 	int fw_state;	/* shall we protect this variable? maybe not necessarily... */
diff --git a/drivers/staging/rtl8188eu/os_dep/rtw_android.c b/drivers/staging/rtl8188eu/os_dep/rtw_android.c
index a3c2bc5..ca2736d 100644
--- a/drivers/staging/rtl8188eu/os_dep/rtw_android.c
+++ b/drivers/staging/rtl8188eu/os_dep/rtw_android.c
@@ -24,7 +24,6 @@
 #include <rtw_android.h>
 #include <osdep_service.h>
 #include <rtw_debug.h>
-#include <ioctl_cfg80211.h>
 #include <rtw_ioctl_set.h>
 
 static const char *android_wifi_cmd_str[ANDROID_WIFI_CMD_MAX] = {
-- 
1.8.4.5
