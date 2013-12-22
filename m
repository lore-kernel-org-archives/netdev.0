From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 04/31] staging: r8188eu: Replace ATOMIC_T with atomic_t
Date: Sun, 22 Dec 2013 17:36:35 -0600
Message-ID: <1387755422-11443-5-git-send-email-Larry.Finger@lwfinger.net>
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
 drivers/staging/rtl8188eu/include/drv_types.h     |  2 +-
 drivers/staging/rtl8188eu/include/osdep_service.h | 22 ++++++++++------------
 drivers/staging/rtl8188eu/include/rtw_cmd.h       |  2 +-
 drivers/staging/rtl8188eu/include/rtw_mlme_ext.h  |  2 +-
 drivers/staging/rtl8188eu/os_dep/osdep_service.c  | 20 ++++++++++----------
 5 files changed, 23 insertions(+), 25 deletions(-)

diff --git a/drivers/staging/rtl8188eu/include/drv_types.h b/drivers/staging/rtl8188eu/include/drv_types.h
index ad073c8..00a49ef 100644
--- a/drivers/staging/rtl8188eu/include/drv_types.h
+++ b/drivers/staging/rtl8188eu/include/drv_types.h
@@ -191,7 +191,7 @@ struct dvobj_priv {
 	struct usb_interface *pusbintf;
 	struct usb_device *pusbdev;
 
-	ATOMIC_T continual_urb_error;
+	atomic_t continual_urb_error;
 };
 
 static inline struct device *dvobj_to_dev(struct dvobj_priv *dvobj)
diff --git a/drivers/staging/rtl8188eu/include/osdep_service.h b/drivers/staging/rtl8188eu/include/osdep_service.h
index 091ca4b..be588aa 100644
--- a/drivers/staging/rtl8188eu/include/osdep_service.h
+++ b/drivers/staging/rtl8188eu/include/osdep_service.h
@@ -358,18 +358,16 @@ static inline u32 bitshift(u32 bitmask)
 #define PATH_LENGTH_MAX PATH_MAX
 
 /* Atomic integer operations */
-#define ATOMIC_T atomic_t
-
-void ATOMIC_SET(ATOMIC_T *v, int i);
-int ATOMIC_READ(ATOMIC_T *v);
-void ATOMIC_ADD(ATOMIC_T *v, int i);
-void ATOMIC_SUB(ATOMIC_T *v, int i);
-void ATOMIC_INC(ATOMIC_T *v);
-void ATOMIC_DEC(ATOMIC_T *v);
-int ATOMIC_ADD_RETURN(ATOMIC_T *v, int i);
-int ATOMIC_SUB_RETURN(ATOMIC_T *v, int i);
-int ATOMIC_INC_RETURN(ATOMIC_T *v);
-int ATOMIC_DEC_RETURN(ATOMIC_T *v);
+void ATOMIC_SET(atomic_t *v, int i);
+int ATOMIC_READ(atomic_t *v);
+void ATOMIC_ADD(atomic_t *v, int i);
+void ATOMIC_SUB(atomic_t *v, int i);
+void ATOMIC_INC(atomic_t *v);
+void ATOMIC_DEC(atomic_t *v);
+int ATOMIC_ADD_RETURN(atomic_t *v, int i);
+int ATOMIC_SUB_RETURN(atomic_t *v, int i);
+int ATOMIC_INC_RETURN(atomic_t *v);
+int ATOMIC_DEC_RETURN(atomic_t *v);
 
 struct rtw_netdev_priv_indicator {
 	void *priv;
diff --git a/drivers/staging/rtl8188eu/include/rtw_cmd.h b/drivers/staging/rtl8188eu/include/rtw_cmd.h
index 73e9f7d..3d34702 100644
--- a/drivers/staging/rtl8188eu/include/rtw_cmd.h
+++ b/drivers/staging/rtl8188eu/include/rtw_cmd.h
@@ -69,7 +69,7 @@ struct	evt_priv {
 	bool c2h_wk_alive;
 	struct rtw_cbuf *c2h_queue;
 	#define C2H_QUEUE_MAX_LEN 10
-	ATOMIC_T event_seq;
+	atomic_t event_seq;
 	u8	*evt_buf;	/* shall be non-paged, and 4 bytes aligned */
 	u8	*evt_allocated_buf;
 	u32	evt_done_cnt;
diff --git a/drivers/staging/rtl8188eu/include/rtw_mlme_ext.h b/drivers/staging/rtl8188eu/include/rtw_mlme_ext.h
index b1bfa2e..7a4b5c6 100644
--- a/drivers/staging/rtl8188eu/include/rtw_mlme_ext.h
+++ b/drivers/staging/rtl8188eu/include/rtw_mlme_ext.h
@@ -401,7 +401,7 @@ struct p2p_oper_class_map {
 struct mlme_ext_priv {
 	struct adapter	*padapter;
 	u8	mlmeext_init;
-	ATOMIC_T	event_seq;
+	atomic_t	event_seq;
 	u16	mgnt_seq;
 
 	unsigned char	cur_channel;
diff --git a/drivers/staging/rtl8188eu/os_dep/osdep_service.c b/drivers/staging/rtl8188eu/os_dep/osdep_service.c
index 9c3e410..2f064e8 100644
--- a/drivers/staging/rtl8188eu/os_dep/osdep_service.c
+++ b/drivers/staging/rtl8188eu/os_dep/osdep_service.c
@@ -247,52 +247,52 @@ void rtw_sleep_schedulable(int ms)
 
 #define RTW_SUSPEND_LOCK_NAME "rtw_wifi"
 
-inline void ATOMIC_SET(ATOMIC_T *v, int i)
+inline void ATOMIC_SET(atomic_t *v, int i)
 {
 	atomic_set(v, i);
 }
 
-inline int ATOMIC_READ(ATOMIC_T *v)
+inline int ATOMIC_READ(atomic_t *v)
 {
 	return atomic_read(v);
 }
 
-inline void ATOMIC_ADD(ATOMIC_T *v, int i)
+inline void ATOMIC_ADD(atomic_t *v, int i)
 {
 	atomic_add(i, v);
 }
 
-inline void ATOMIC_SUB(ATOMIC_T *v, int i)
+inline void ATOMIC_SUB(atomic_t *v, int i)
 {
 	atomic_sub(i, v);
 }
 
-inline void ATOMIC_INC(ATOMIC_T *v)
+inline void ATOMIC_INC(atomic_t *v)
 {
 	atomic_inc(v);
 }
 
-inline void ATOMIC_DEC(ATOMIC_T *v)
+inline void ATOMIC_DEC(atomic_t *v)
 {
 	atomic_dec(v);
 }
 
-inline int ATOMIC_ADD_RETURN(ATOMIC_T *v, int i)
+inline int ATOMIC_ADD_RETURN(atomic_t *v, int i)
 {
 	return atomic_add_return(i, v);
 }
 
-inline int ATOMIC_SUB_RETURN(ATOMIC_T *v, int i)
+inline int ATOMIC_SUB_RETURN(atomic_t *v, int i)
 {
 	return atomic_sub_return(i, v);
 }
 
-inline int ATOMIC_INC_RETURN(ATOMIC_T *v)
+inline int ATOMIC_INC_RETURN(atomic_t *v)
 {
 	return atomic_inc_return(v);
 }
 
-inline int ATOMIC_DEC_RETURN(ATOMIC_T *v)
+inline int ATOMIC_DEC_RETURN(atomic_t *v)
 {
 	return atomic_dec_return(v);
 }
-- 
1.8.4
