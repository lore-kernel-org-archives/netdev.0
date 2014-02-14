From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 04/13] staging: r8188eu: Remove pkt_to_recv{frame, data,
 mem} routines
Date: Fri, 14 Feb 2014 16:54:08 -0600
Message-ID: <1392418457-3203-5-git-send-email-Larry.Finger@lwfinger.net>
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

These functions are not called from the outside source.

Suggested-by: Jes Sorensen <Jes.Sorensen@redhat.com>
Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
Cc: Jes Sorensen <Jes.Sorensen@redhat.com>
---
 drivers/staging/rtl8188eu/include/rtw_recv.h | 38 ----------------------------
 1 file changed, 38 deletions(-)

diff --git a/drivers/staging/rtl8188eu/include/rtw_recv.h b/drivers/staging/rtl8188eu/include/rtw_recv.h
index e579c38..81fdcf5 100644
--- a/drivers/staging/rtl8188eu/include/rtw_recv.h
+++ b/drivers/staging/rtl8188eu/include/rtw_recv.h
@@ -415,44 +415,6 @@ static inline unsigned char *get_rxbuf_desc(struct recv_frame *precvframe)
 	return buf_desc;
 }
 
-static inline struct recv_frame *rxmem_to_recvframe(u8 *rxmem)
-{
-	/* due to the design of 2048 bytes alignment of recv_frame,
-	 * we can reference the struct recv_frame */
-	/* from any given member of recv_frame. */
-	/*  rxmem indicates the any member/address in recv_frame */
-
-	return (struct recv_frame *)(((size_t)rxmem >> RXFRAME_ALIGN) <<
-				     RXFRAME_ALIGN);
-}
-
-static inline struct recv_frame *pkt_to_recvframe(struct sk_buff *pkt)
-{
-	u8 *buf_star;
-	struct recv_frame *precv_frame;
-	precv_frame = rxmem_to_recvframe((unsigned char *)buf_star);
-
-	return precv_frame;
-}
-
-static inline u8 *pkt_to_recvmem(struct sk_buff *pkt)
-{
-	/*  return the rx_head */
-
-	struct recv_frame *precv_frame = pkt_to_recvframe(pkt);
-
-	return	precv_frame->rx_head;
-}
-
-static inline u8 *pkt_to_recvdata(struct sk_buff *pkt)
-{
-	/*  return the rx_data */
-
-	struct recv_frame *precv_frame = pkt_to_recvframe(pkt);
-
-	return	precv_frame->rx_data;
-}
-
 static inline int get_recvframe_len(struct recv_frame *precvframe)
 {
 	return precvframe->len;
-- 
1.8.4.5
