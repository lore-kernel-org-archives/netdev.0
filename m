From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 07/12] staging: r8188eu: Remove wrappers around vmalloc and
 vzalloc
Date: Thu,  6 Feb 2014 20:45:42 -0600
Message-ID: <1391741147-3047-8-git-send-email-Larry.Finger@lwfinger.net>
References: <1391741147-3047-1-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org,
 Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1391741147-3047-1-git-send-email-Larry.Finger@lwfinger.net>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/staging/rtl8188eu/core/rtw_mlme.c         |  4 ++--
 drivers/staging/rtl8188eu/core/rtw_mp.c           |  2 +-
 drivers/staging/rtl8188eu/core/rtw_recv.c         |  2 +-
 drivers/staging/rtl8188eu/core/rtw_sta_mgt.c      |  2 +-
 drivers/staging/rtl8188eu/core/rtw_xmit.c         |  8 ++++----
 drivers/staging/rtl8188eu/hal/odm_interface.c     |  2 +-
 drivers/staging/rtl8188eu/hal/rtl8188e_hal_init.c |  2 +-
 drivers/staging/rtl8188eu/include/osdep_service.h |  4 ----
 drivers/staging/rtl8188eu/os_dep/ioctl_linux.c    |  2 +-
 drivers/staging/rtl8188eu/os_dep/osdep_service.c  | 18 +-----------------
 drivers/staging/rtl8188eu/os_dep/usb_intf.c       |  2 +-
 11 files changed, 14 insertions(+), 34 deletions(-)

diff --git a/drivers/staging/rtl8188eu/core/rtw_mlme.c b/drivers/staging/rtl8188eu/core/rtw_mlme.c
index c738230..c85fcfe 100644
--- a/drivers/staging/rtl8188eu/core/rtw_mlme.c
+++ b/drivers/staging/rtl8188eu/core/rtw_mlme.c
@@ -45,7 +45,7 @@ int	_rtw_init_mlme_priv (struct adapter *padapter)
 
 _func_enter_;
 
-	/*  We don't need to memset padapter->XXX to zero, because adapter is allocated by rtw_zvmalloc(). */
+	/*  We don't need to memset padapter->XXX to zero, because adapter is allocated by vzalloc(). */
 
 	pmlmepriv->nic_hdl = (u8 *)padapter;
 
@@ -62,7 +62,7 @@ _func_enter_;
 
 	_rtw_memset(&pmlmepriv->assoc_ssid, 0, sizeof(struct ndis_802_11_ssid));
 
-	pbuf = rtw_zvmalloc(MAX_BSS_CNT * (sizeof(struct wlan_network)));
+	pbuf = vzalloc(MAX_BSS_CNT * (sizeof(struct wlan_network)));
 
 	if (pbuf == NULL) {
 		res = _FAIL;
diff --git a/drivers/staging/rtl8188eu/core/rtw_mp.c b/drivers/staging/rtl8188eu/core/rtw_mp.c
index 6451efd..a88c5f1 100644
--- a/drivers/staging/rtl8188eu/core/rtw_mp.c
+++ b/drivers/staging/rtl8188eu/core/rtw_mp.c
@@ -956,7 +956,7 @@ void _rtw_mp_xmit_priv(struct xmit_priv *pxmitpriv)
 	/*  Init xmit extension buff */
 	_rtw_init_queue(&pxmitpriv->free_xmit_extbuf_queue);
 
-	pxmitpriv->pallocated_xmit_extbuf = rtw_zvmalloc(num_xmit_extbuf * sizeof(struct xmit_buf) + 4);
+	pxmitpriv->pallocated_xmit_extbuf = vzalloc(num_xmit_extbuf * sizeof(struct xmit_buf) + 4);
 
 	if (pxmitpriv->pallocated_xmit_extbuf  == NULL) {
 		RT_TRACE(_module_rtl871x_xmit_c_, _drv_err_, ("alloc xmit_extbuf fail!\n"));
diff --git a/drivers/staging/rtl8188eu/core/rtw_recv.c b/drivers/staging/rtl8188eu/core/rtw_recv.c
index c9c1806..b2e00f9 100644
--- a/drivers/staging/rtl8188eu/core/rtw_recv.c
+++ b/drivers/staging/rtl8188eu/core/rtw_recv.c
@@ -77,7 +77,7 @@ _func_enter_;
 
 	rtw_os_recv_resource_init(precvpriv, padapter);
 
-	precvpriv->pallocated_frame_buf = rtw_zvmalloc(NR_RECVFRAME * sizeof(union recv_frame) + RXFRAME_ALIGN_SZ);
+	precvpriv->pallocated_frame_buf = vzalloc(NR_RECVFRAME * sizeof(union recv_frame) + RXFRAME_ALIGN_SZ);
 
 	if (precvpriv->pallocated_frame_buf == NULL) {
 		res = _FAIL;
diff --git a/drivers/staging/rtl8188eu/core/rtw_sta_mgt.c b/drivers/staging/rtl8188eu/core/rtw_sta_mgt.c
index 02e1e1f..21b205f 100644
--- a/drivers/staging/rtl8188eu/core/rtw_sta_mgt.c
+++ b/drivers/staging/rtl8188eu/core/rtw_sta_mgt.c
@@ -79,7 +79,7 @@ u32	_rtw_init_sta_priv(struct	sta_priv *pstapriv)
 
 _func_enter_;
 
-	pstapriv->pallocated_stainfo_buf = rtw_zvmalloc(sizeof(struct sta_info) * NUM_STA + 4);
+	pstapriv->pallocated_stainfo_buf = vzalloc(sizeof(struct sta_info) * NUM_STA + 4);
 
 	if (!pstapriv->pallocated_stainfo_buf)
 		return _FAIL;
diff --git a/drivers/staging/rtl8188eu/core/rtw_xmit.c b/drivers/staging/rtl8188eu/core/rtw_xmit.c
index 24182fb..e98c038 100644
--- a/drivers/staging/rtl8188eu/core/rtw_xmit.c
+++ b/drivers/staging/rtl8188eu/core/rtw_xmit.c
@@ -65,7 +65,7 @@ s32	_rtw_init_xmit_priv(struct xmit_priv *pxmitpriv, struct adapter *padapter)
 
 _func_enter_;
 
-	/*  We don't need to memset padapter->XXX to zero, because adapter is allocated by rtw_zvmalloc(). */
+	/*  We don't need to memset padapter->XXX to zero, because adapter is allocated by vzalloc(). */
 
 	spin_lock_init(&pxmitpriv->lock);
 	sema_init(&pxmitpriv->xmit_sema, 0);
@@ -91,7 +91,7 @@ _func_enter_;
 	Please also apply  free_txobj to link_up all the xmit_frames...
 	*/
 
-	pxmitpriv->pallocated_frame_buf = rtw_zvmalloc(NR_XMITFRAME * sizeof(struct xmit_frame) + 4);
+	pxmitpriv->pallocated_frame_buf = vzalloc(NR_XMITFRAME * sizeof(struct xmit_frame) + 4);
 
 	if (pxmitpriv->pallocated_frame_buf  == NULL) {
 		pxmitpriv->pxmit_frame_buf = NULL;
@@ -129,7 +129,7 @@ _func_enter_;
 	_rtw_init_queue(&pxmitpriv->free_xmitbuf_queue);
 	_rtw_init_queue(&pxmitpriv->pending_xmitbuf_queue);
 
-	pxmitpriv->pallocated_xmitbuf = rtw_zvmalloc(NR_XMITBUFF * sizeof(struct xmit_buf) + 4);
+	pxmitpriv->pallocated_xmitbuf = vzalloc(NR_XMITBUFF * sizeof(struct xmit_buf) + 4);
 
 	if (pxmitpriv->pallocated_xmitbuf  == NULL) {
 		RT_TRACE(_module_rtl871x_xmit_c_, _drv_err_, ("alloc xmit_buf fail!\n"));
@@ -171,7 +171,7 @@ _func_enter_;
 	/*  Init xmit extension buff */
 	_rtw_init_queue(&pxmitpriv->free_xmit_extbuf_queue);
 
-	pxmitpriv->pallocated_xmit_extbuf = rtw_zvmalloc(num_xmit_extbuf * sizeof(struct xmit_buf) + 4);
+	pxmitpriv->pallocated_xmit_extbuf = vzalloc(num_xmit_extbuf * sizeof(struct xmit_buf) + 4);
 
 	if (pxmitpriv->pallocated_xmit_extbuf  == NULL) {
 		RT_TRACE(_module_rtl871x_xmit_c_, _drv_err_, ("alloc xmit_extbuf fail!\n"));
diff --git a/drivers/staging/rtl8188eu/hal/odm_interface.c b/drivers/staging/rtl8188eu/hal/odm_interface.c
index b84b111..5ba95ab 100644
--- a/drivers/staging/rtl8188eu/hal/odm_interface.c
+++ b/drivers/staging/rtl8188eu/hal/odm_interface.c
@@ -23,7 +23,7 @@
 /*  ODM Memory relative API. */
 void ODM_AllocateMemory(struct odm_dm_struct *pDM_Odm, void **pPtr, u32 length)
 {
-	*pPtr = rtw_zvmalloc(length);
+	*pPtr = vzalloc(length);
 }
 
 /*  length could be ignored, used to detect memory leakage. */
diff --git a/drivers/staging/rtl8188eu/hal/rtl8188e_hal_init.c b/drivers/staging/rtl8188eu/hal/rtl8188e_hal_init.c
index 5921db8..d364abc 100644
--- a/drivers/staging/rtl8188eu/hal/rtl8188e_hal_init.c
+++ b/drivers/staging/rtl8188eu/hal/rtl8188e_hal_init.c
@@ -365,7 +365,7 @@ void rtw_IOL_cmd_tx_pkt_buf_dump(struct adapter *Adapter, int data_len)
 	u32 fifo_data, reg_140;
 	u32 addr, rstatus, loop = 0;
 	u16 data_cnts = (data_len/8)+1;
-	u8 *pbuf = rtw_zvmalloc(data_len+10);
+	u8 *pbuf = vzalloc(data_len+10);
 	DBG_88E("###### %s ######\n", __func__);
 
 	rtw_write8(Adapter, REG_PKT_BUFF_ACCESS_CTRL, TXPKT_BUF_SELECT);
diff --git a/drivers/staging/rtl8188eu/include/osdep_service.h b/drivers/staging/rtl8188eu/include/osdep_service.h
index 7956f0c..0d34c36 100644
--- a/drivers/staging/rtl8188eu/include/osdep_service.h
+++ b/drivers/staging/rtl8188eu/include/osdep_service.h
@@ -230,14 +230,10 @@ extern unsigned char WPA_TKIP_CIPHER[4];
 extern unsigned char RSN_TKIP_CIPHER[4];
 
 #define rtw_update_mem_stat(flag, sz) do {} while (0)
-u8 *_rtw_vmalloc(u32 sz);
-u8 *_rtw_zvmalloc(u32 sz);
 void _rtw_vmfree(u8 *pbuf, u32 sz);
 u8 *_rtw_zmalloc(u32 sz);
 u8 *_rtw_malloc(u32 sz);
 void _rtw_mfree(u8 *pbuf, u32 sz);
-#define rtw_vmalloc(sz)			_rtw_vmalloc((sz))
-#define rtw_zvmalloc(sz)			_rtw_zvmalloc((sz))
 #define rtw_vmfree(pbuf, sz)		_rtw_vmfree((pbuf), (sz))
 #define rtw_malloc(sz)			_rtw_malloc((sz))
 #define rtw_zmalloc(sz)			_rtw_zmalloc((sz))
diff --git a/drivers/staging/rtl8188eu/os_dep/ioctl_linux.c b/drivers/staging/rtl8188eu/os_dep/ioctl_linux.c
index 4ad80ae..50c61c3 100644
--- a/drivers/staging/rtl8188eu/os_dep/ioctl_linux.c
+++ b/drivers/staging/rtl8188eu/os_dep/ioctl_linux.c
@@ -5648,7 +5648,7 @@ static int rtw_wx_set_priv(struct net_device *dev,
 		return -EFAULT;
 
 	len = dwrq->length;
-	ext = rtw_vmalloc(len);
+	ext = vmalloc(len);
 	if (!ext)
 		return -ENOMEM;
 
diff --git a/drivers/staging/rtl8188eu/os_dep/osdep_service.c b/drivers/staging/rtl8188eu/os_dep/osdep_service.c
index 8c3b077..02f5e0c 100644
--- a/drivers/staging/rtl8188eu/os_dep/osdep_service.c
+++ b/drivers/staging/rtl8188eu/os_dep/osdep_service.c
@@ -55,22 +55,6 @@ u32 rtw_atoi(u8 *s)
 	return num;
 }
 
-inline u8 *_rtw_vmalloc(u32 sz)
-{
-	u8	*pbuf;
-	pbuf = vmalloc(sz);
-	return pbuf;
-}
-
-inline u8 *_rtw_zvmalloc(u32 sz)
-{
-	u8	*pbuf;
-	pbuf = _rtw_vmalloc(sz);
-	if (pbuf != NULL)
-		memset(pbuf, 0, sz);
-	return pbuf;
-}
-
 inline void _rtw_vmfree(u8 *pbuf, u32 sz)
 {
 	vfree(pbuf);
@@ -252,7 +236,7 @@ struct net_device *rtw_alloc_etherdev(int sizeof_priv)
 
 	pnpi = netdev_priv(pnetdev);
 
-	pnpi->priv = rtw_zvmalloc(sizeof_priv);
+	pnpi->priv = vzalloc(sizeof_priv);
 	if (!pnpi->priv) {
 		free_netdev(pnetdev);
 		pnetdev = NULL;
diff --git a/drivers/staging/rtl8188eu/os_dep/usb_intf.c b/drivers/staging/rtl8188eu/os_dep/usb_intf.c
index 0a341d6..e5539dd 100644
--- a/drivers/staging/rtl8188eu/os_dep/usb_intf.c
+++ b/drivers/staging/rtl8188eu/os_dep/usb_intf.c
@@ -646,7 +646,7 @@ static struct adapter *rtw_usb_if1_init(struct dvobj_priv *dvobj,
 	struct net_device *pnetdev = NULL;
 	int status = _FAIL;
 
-	padapter = (struct adapter *)rtw_zvmalloc(sizeof(*padapter));
+	padapter = (struct adapter *)vzalloc(sizeof(*padapter));
 	if (padapter == NULL)
 		goto exit;
 	padapter->dvobj = dvobj;
-- 
1.8.4.5
