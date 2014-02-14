From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 09/13] staging: r8188eu: Remove wrapper _exit_critical_mutex()
Date: Fri, 14 Feb 2014 16:54:13 -0600
Message-ID: <1392418457-3203-10-git-send-email-Larry.Finger@lwfinger.net>
References: <1392418457-3203-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: netdev@vger.kernel.org, devel@driverdev.osuosl.org,
	Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:59421 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753030AbaBNWy5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Feb 2014 17:54:57 -0500
Received: by mail-ob0-f174.google.com with SMTP id uy5so14579769obc.5
        for <netdev@vger.kernel.org>; Fri, 14 Feb 2014 14:54:57 -0800 (PST)
In-Reply-To: <1392418457-3203-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This wrapper is a simple call to mutex_exit().

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/staging/rtl8188eu/core/rtw_mlme_ext.c     | 2 +-
 drivers/staging/rtl8188eu/hal/usb_ops_linux.c     | 2 +-
 drivers/staging/rtl8188eu/include/osdep_service.h | 7 -------
 drivers/staging/rtl8188eu/os_dep/os_intfs.c       | 2 +-
 4 files changed, 3 insertions(+), 10 deletions(-)

diff --git a/drivers/staging/rtl8188eu/core/rtw_mlme_ext.c b/drivers/staging/rtl8188eu/core/rtw_mlme_ext.c
index faeec73..c197b22 100644
--- a/drivers/staging/rtl8188eu/core/rtw_mlme_ext.c
+++ b/drivers/staging/rtl8188eu/core/rtw_mlme_ext.c
@@ -4438,7 +4438,7 @@ s32 dump_mgntframe_and_wait_ack(struct adapter *padapter, struct xmit_frame *pmg
 	}
 
 	pxmitpriv->ack_tx = false;
-	_exit_critical_mutex(&pxmitpriv->ack_tx_mutex, NULL);
+	mutex_unlock(&pxmitpriv->ack_tx_mutex);
 
 	 return ret;
 }
diff --git a/drivers/staging/rtl8188eu/hal/usb_ops_linux.c b/drivers/staging/rtl8188eu/hal/usb_ops_linux.c
index 1bfe497..1fa5370 100644
--- a/drivers/staging/rtl8188eu/hal/usb_ops_linux.c
+++ b/drivers/staging/rtl8188eu/hal/usb_ops_linux.c
@@ -111,7 +111,7 @@ static int usbctrl_vendorreq(struct intf_hdl *pintfhdl, u8 request, u16 value, u
 			break;
 	}
 release_mutex:
-	_exit_critical_mutex(&dvobjpriv->usb_vendor_req_mutex, NULL);
+	mutex_unlock(&dvobjpriv->usb_vendor_req_mutex);
 exit:
 	return status;
 }
diff --git a/drivers/staging/rtl8188eu/include/osdep_service.h b/drivers/staging/rtl8188eu/include/osdep_service.h
index 09e2d48..5cf13a6 100644
--- a/drivers/staging/rtl8188eu/include/osdep_service.h
+++ b/drivers/staging/rtl8188eu/include/osdep_service.h
@@ -76,13 +76,6 @@ static inline int _enter_critical_mutex(struct mutex *pmutex,
 	return ret;
 }
 
-
-static inline void _exit_critical_mutex(struct mutex *pmutex,
-					unsigned long *pirqL)
-{
-		mutex_unlock(pmutex);
-}
-
 static inline void rtw_list_delete(struct list_head *plist)
 {
 	list_del_init(plist);
diff --git a/drivers/staging/rtl8188eu/os_dep/os_intfs.c b/drivers/staging/rtl8188eu/os_dep/os_intfs.c
index cf4107a..bc9ae1d 100644
--- a/drivers/staging/rtl8188eu/os_dep/os_intfs.c
+++ b/drivers/staging/rtl8188eu/os_dep/os_intfs.c
@@ -1111,7 +1111,7 @@ int netdev_open(struct net_device *pnetdev)
 
 	_enter_critical_mutex(padapter->hw_init_mutex, NULL);
 	ret = _netdev_open(pnetdev);
-	_exit_critical_mutex(padapter->hw_init_mutex, NULL);
+	mutex_unlock(padapter->hw_init_mutex);
 	return ret;
 }
 
-- 
1.8.4.5
