From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 11/31] staging: r8188eu: Remove wrapper around mutex_destroy
Date: Sun, 22 Dec 2013 17:36:42 -0600
Message-ID: <1387755422-11443-12-git-send-email-Larry.Finger@lwfinger.net>
References: <1387755422-11443-1-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org,
 Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1387755422-11443-1-git-send-email-Larry.Finger@lwfinger.net>
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
 drivers/staging/rtl8188eu/core/rtw_xmit.c         | 2 +-
 drivers/staging/rtl8188eu/include/osdep_service.h | 1 -
 drivers/staging/rtl8188eu/os_dep/osdep_service.c  | 5 -----
 drivers/staging/rtl8188eu/os_dep/usb_intf.c       | 4 ++--
 4 files changed, 3 insertions(+), 9 deletions(-)

diff --git a/drivers/staging/rtl8188eu/core/rtw_xmit.c b/drivers/staging/rtl8188eu/core/rtw_xmit.c
index b1af4ef..026645c 100644
--- a/drivers/staging/rtl8188eu/core/rtw_xmit.c
+++ b/drivers/staging/rtl8188eu/core/rtw_xmit.c
@@ -277,7 +277,7 @@ void _rtw_free_xmit_priv (struct xmit_priv *pxmitpriv)
 
 	rtw_free_hwxmits(padapter);
 
-	_rtw_mutex_free(&pxmitpriv->ack_tx_mutex);
+	mutex_destroy(&pxmitpriv->ack_tx_mutex);
 
 out:
 
diff --git a/drivers/staging/rtl8188eu/include/osdep_service.h b/drivers/staging/rtl8188eu/include/osdep_service.h
index 3ea97fd..7956f0c 100644
--- a/drivers/staging/rtl8188eu/include/osdep_service.h
+++ b/drivers/staging/rtl8188eu/include/osdep_service.h
@@ -257,7 +257,6 @@ void rtw_list_insert_tail(struct list_head *plist, struct list_head *phead);
 void rtw_list_delete(struct list_head *plist);
 
 u32  _rtw_down_sema(struct semaphore *sema);
-void _rtw_mutex_free(struct mutex *pmutex);
 
 void _rtw_init_queue(struct __queue *pqueue);
 u32  _rtw_queue_empty(struct __queue *pqueue);
diff --git a/drivers/staging/rtl8188eu/os_dep/osdep_service.c b/drivers/staging/rtl8188eu/os_dep/osdep_service.c
index 23d39cc..8c3b077 100644
--- a/drivers/staging/rtl8188eu/os_dep/osdep_service.c
+++ b/drivers/staging/rtl8188eu/os_dep/osdep_service.c
@@ -169,11 +169,6 @@ u32 _rtw_down_sema(struct semaphore *sema)
 		return _SUCCESS;
 }
 
-void	_rtw_mutex_free(struct mutex *pmutex)
-{
-	mutex_destroy(pmutex);
-}
-
 void	_rtw_init_queue(struct __queue *pqueue)
 {
 	_rtw_init_listhead(&(pqueue->queue));
diff --git a/drivers/staging/rtl8188eu/os_dep/usb_intf.c b/drivers/staging/rtl8188eu/os_dep/usb_intf.c
index 32d1e97..35107fd 100644
--- a/drivers/staging/rtl8188eu/os_dep/usb_intf.c
+++ b/drivers/staging/rtl8188eu/os_dep/usb_intf.c
@@ -144,7 +144,7 @@ static u8 rtw_deinit_intf_priv(struct dvobj_priv *dvobj)
 	u8 rst = _SUCCESS;
 
 	kfree(dvobj->usb_alloc_vendor_req_buf);
-	_rtw_mutex_free(&dvobj->usb_vendor_req_mutex);
+	mutex_destroy(&dvobj->usb_vendor_req_mutex);
 	return rst;
 }
 
@@ -881,7 +881,7 @@ static void __exit rtw_drv_halt(void)
 	usb_drv->drv_registered = false;
 	usb_deregister(&usb_drv->usbdrv);
 
-	_rtw_mutex_free(&usb_drv->hw_init_mutex);
+	mutex_destroy(&usb_drv->hw_init_mutex);
 	DBG_88E("-rtw_drv_halt\n");
 }
 
-- 
1.8.4
