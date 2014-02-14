From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 01/13] staging: r8188eu: Remove unnecessary list_head entry
 from recv_frame union
Date: Fri, 14 Feb 2014 16:54:05 -0600
Message-ID: <1392418457-3203-2-git-send-email-Larry.Finger@lwfinger.net>
References: <1392418457-3203-1-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org,
 Jes Sorensen <Jes.Sorensen@redhat.com>,
 Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1392418457-3203-1-git-send-email-Larry.Finger@lwfinger.net>
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

Struct recv_frame_hdr already contains a list head. This one is pointless.

Suggested-by: Jes Sorensen <Jes.Sorensen@redhat.com>
Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
Cc: Jes Sorensen <Jes.Sorensen@redhat.com>
---
 drivers/staging/rtl8188eu/core/rtw_recv.c    | 7 ++++---
 drivers/staging/rtl8188eu/include/rtw_recv.h | 1 -
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/rtl8188eu/core/rtw_recv.c b/drivers/staging/rtl8188eu/core/rtw_recv.c
index bc5baf2..6979c73 100644
--- a/drivers/staging/rtl8188eu/core/rtw_recv.c
+++ b/drivers/staging/rtl8188eu/core/rtw_recv.c
@@ -87,9 +87,10 @@ int _rtw_init_recv_priv(struct recv_priv *precvpriv, struct adapter *padapter)
 	precvframe = (union recv_frame *)precvpriv->precv_frame_buf;
 
 	for (i = 0; i < NR_RECVFRAME; i++) {
-		_rtw_init_listhead(&(precvframe->u.list));
+		_rtw_init_listhead(&(precvframe->u.hdr.list));
 
-		rtw_list_insert_tail(&(precvframe->u.list), &(precvpriv->free_recv_queue.queue));
+		rtw_list_insert_tail(&(precvframe->u.hdr.list),
+				     &(precvpriv->free_recv_queue.queue));
 
 		res = rtw_os_recv_resource_alloc(padapter, precvframe);
 
@@ -1485,7 +1486,7 @@ static union recv_frame *recvframe_defrag(struct adapter *adapter, struct __queu
 	plist = phead->next;
 	pfhdr = container_of(plist, struct recv_frame_hdr, list);
 	prframe = (union recv_frame *)pfhdr;
-	rtw_list_delete(&(prframe->u.list));
+	rtw_list_delete(&(prframe->u.hdr.list));
 
 	if (curfragnum != pfhdr->attrib.frag_num) {
 		/* the first fragment number must be 0 */
diff --git a/drivers/staging/rtl8188eu/include/rtw_recv.h b/drivers/staging/rtl8188eu/include/rtw_recv.h
index be9c30c..866c9e4 100644
--- a/drivers/staging/rtl8188eu/include/rtw_recv.h
+++ b/drivers/staging/rtl8188eu/include/rtw_recv.h
@@ -291,7 +291,6 @@ struct recv_frame_hdr {
 
 union recv_frame {
 	union {
-		struct list_head list;
 		struct recv_frame_hdr hdr;
 		uint mem[RECVFRAME_HDR_ALIGN>>2];
 	} u;
-- 
1.8.4.5
