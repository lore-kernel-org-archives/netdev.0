From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH] staging: r8188eu: Fix some sparse warnings
Date: Thu, 17 Apr 2014 10:35:22 -0500
Message-ID: <1397748922-8941-1-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org,
 Dan Carpenter <dan.carpenter@oracle.com>,
 Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
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

In a patch entitles "staging: r8188eu: Fix case where ethtype was never obtained
and always be checked against 0" (commit ID unknown), I introduce an endian error.
This patch fixes that, and removes two additional sparse warnings.

drivers/staging/rtl8188eu/core/rtw_recv.c:653:6: warning: symbol 'process_pwrbit_data' was not declared. Should it be static?
drivers/staging/rtl8188eu/core/rtw_recv.c:1828:5: warning: symbol 'enqueue_reorder_recvframe' was not declared. Should it be static?

Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
Cc: Dan Carpenter <dan.carpenter@oracle.com>
---
 drivers/staging/rtl8188eu/core/rtw_recv.c | 13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/drivers/staging/rtl8188eu/core/rtw_recv.c b/drivers/staging/rtl8188eu/core/rtw_recv.c
index aeb0053..9bb1790 100644
--- a/drivers/staging/rtl8188eu/core/rtw_recv.c
+++ b/drivers/staging/rtl8188eu/core/rtw_recv.c
@@ -554,6 +554,7 @@ static struct recv_frame *portctrl(struct adapter *adapter,
 	u16	ether_type;
 	u16  eapol_type = 0x888e;/* for Funia BD's WPA issue */
 	struct rx_pkt_attrib *pattrib;
+	__be16 be_tmp;
 
 
 	pstapriv = &adapter->stapriv;
@@ -573,8 +574,8 @@ static struct recv_frame *portctrl(struct adapter *adapter,
 	if (auth_alg == 2) {
 		/* get ether_type */
 		ptr = ptr + pfhdr->attrib.hdrlen + LLC_HEADER_SIZE;
-		memcpy(&ether_type, ptr, 2);
-		ether_type = ntohs((unsigned short)ether_type);
+		memcpy(&be_tmp, ptr, 2);
+		ether_type = ntohs(be_tmp);
 
 		if ((psta != NULL) && (psta->ieee8021x_blocked)) {
 			/* blocked */
@@ -647,8 +648,8 @@ static int recv_decache(struct recv_frame *precv_frame, u8 bretry,
 	return _SUCCESS;
 }
 
-void process_pwrbit_data(struct adapter *padapter,
-			 struct recv_frame *precv_frame)
+static void process_pwrbit_data(struct adapter *padapter,
+				struct recv_frame *precv_frame)
 {
 #ifdef CONFIG_88EU_AP_MODE
 	unsigned char pwrbit;
@@ -1822,8 +1823,8 @@ static int check_indicate_seq(struct recv_reorder_ctrl *preorder_ctrl, u16 seq_n
 	return true;
 }
 
-int enqueue_reorder_recvframe(struct recv_reorder_ctrl *preorder_ctrl,
-			      struct recv_frame *prframe)
+static int enqueue_reorder_recvframe(struct recv_reorder_ctrl *preorder_ctrl,
+				     struct recv_frame *prframe)
 {
 	struct rx_pkt_attrib *pattrib = &prframe->attrib;
 	struct __queue *ppending_recvframe_queue = &preorder_ctrl->pending_recvframe_queue;
-- 
1.8.1.4
