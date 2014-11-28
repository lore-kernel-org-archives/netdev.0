From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: [PATCH 1/3 for 3.18] rtlwifi: rtl8192ce: Fix editing error that causes silent memory corruption
Date: Fri, 28 Nov 2014 10:41:14 -0600
Message-ID: <1417192876-12101-2-git-send-email-Larry.Finger@lwfinger.net>
References: <1417192876-12101-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Catalin Iacob <iacobcatalin-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1417192876-12101-1-git-send-email-Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

In the major update of the rtlwifi-family of drivers, there was an editing
mistake. Unfortunately, this particular error leads to memory corruption that
silently leads to failure of the system. This patch is one of three needed to
fix the kernel regression reported at https://bugzilla.kernel.org/show_bug.cgi?id=88951.

Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Reported-by: Catalin Iacob <iacobcatalin-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Tested-by: Catalin Iacob <iacobcatalin-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Catalin Iacob <iacobcatalin-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 drivers/net/wireless/rtlwifi/rtl8192ce/trx.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/rtl8192ce/trx.c b/drivers/net/wireless/rtlwifi/rtl8192ce/trx.c
index dc3d20b..0916275 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ce/trx.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192ce/trx.c
@@ -720,16 +720,15 @@ u32 rtl92ce_get_desc(u8 *p_desc, bool istx, u8 desc_name)
 			break;
 		}
 	} else {
-		struct rx_desc_92c *pdesc = (struct rx_desc_92c *)p_desc;
 		switch (desc_name) {
 		case HW_DESC_OWN:
-			ret = GET_RX_DESC_OWN(pdesc);
+			ret = GET_RX_DESC_OWN(p_desc);
 			break;
 		case HW_DESC_RXPKT_LEN:
-			ret = GET_RX_DESC_PKT_LEN(pdesc);
+			ret = GET_RX_DESC_PKT_LEN(p_desc);
 			break;
 		case HW_DESC_RXBUFF_ADDR:
-			ret = GET_RX_STATUS_DESC_BUFF_ADDR(pdesc);
+			ret = GET_RX_DESC_BUFF_ADDR(p_desc);
 			break;
 		default:
 			RT_ASSERT(false, "ERR rxdesc :%d not process\n",
-- 
2.1.2

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
