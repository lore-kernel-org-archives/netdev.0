From: Enrico Mioso <mrkiko.rs@gmail.com>
Subject: [PATCH V5 net-next 1/3] net: cdc_ncm: Export cdc_ncm_{tx,rx}_fixup functions for re-use
Date: Mon, 30 Sep 2013 04:50:07 +0000
Message-ID: <1380516609-31242-2-git-send-email-mrkiko.rs@gmail.com>
References: <1380516609-31242-1-git-send-email-mrkiko.rs@gmail.com>
Cc: Enrico Mioso <mrkiko.rs@gmail.com>
To: Oliver Neukum <oliver@neukum.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	Steve Glendinning <steve.glendinning@shawell.net>,
	Robert de Vries <rhdv@xs4all.nl>,
	Hayes Wang <hayeswang@realtek.com>,
	Freddy Xin <freddy@asix.com.tw>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>,
	Liu Junliang <liujunliang_ljl@163.com>,
	linux-kernel@vger.kernel.org (open list),
	linux-usb@vger.kernel.org (open list:USB NETWORKING DR...),
	netdev@vger.kernel.org (open list:NETWORKING DRIVERS),
	ModemManager-devel@lists.freedesktop.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1380516609-31242-1-git-send-email-mrkiko.rs@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Some drivers implementing NCM-like protocols, may re-use those functions, as is
the case in the huawei_cdc_ncm driver.
Export them via EXPORT_SYMBOL_GPL, in accordance with how other functions have
been exported.

Signed-off-by: Enrico Mioso <mrkiko.rs@gmail.com>

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index 43afde8..62686be 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -858,7 +858,7 @@ static void cdc_ncm_txpath_bh(unsigned long param)
 	}
 }
 
-static struct sk_buff *
+struct sk_buff *
 cdc_ncm_tx_fixup(struct usbnet *dev, struct sk_buff *skb, gfp_t flags)
 {
 	struct sk_buff *skb_out;
@@ -885,6 +885,7 @@ error:
 
 	return NULL;
 }
+EXPORT_SYMBOL_GPL(cdc_ncm_tx_fixup);
 
 /* verify NTB header and return offset of first NDP, or negative error */
 int cdc_ncm_rx_verify_nth16(struct cdc_ncm_ctx *ctx, struct sk_buff *skb_in)
@@ -965,7 +966,7 @@ error:
 }
 EXPORT_SYMBOL_GPL(cdc_ncm_rx_verify_ndp16);
 
-static int cdc_ncm_rx_fixup(struct usbnet *dev, struct sk_buff *skb_in)
+int cdc_ncm_rx_fixup(struct usbnet *dev, struct sk_buff *skb_in)
 {
 	struct sk_buff *skb;
 	struct cdc_ncm_ctx *ctx = (struct cdc_ncm_ctx *)dev->data[0];
@@ -1040,6 +1041,7 @@ err_ndp:
 error:
 	return 0;
 }
+EXPORT_SYMBOL_GPL(cdc_ncm_rx_fixup);
 
 static void
 cdc_ncm_speed_change(struct cdc_ncm_ctx *ctx,
diff --git a/include/linux/usb/cdc_ncm.h b/include/linux/usb/cdc_ncm.h
index cc25b70..163244b 100644
--- a/include/linux/usb/cdc_ncm.h
+++ b/include/linux/usb/cdc_ncm.h
@@ -133,3 +133,6 @@ extern void cdc_ncm_unbind(struct usbnet *dev, struct usb_interface *intf);
 extern struct sk_buff *cdc_ncm_fill_tx_frame(struct cdc_ncm_ctx *ctx, struct sk_buff *skb, __le32 sign);
 extern int cdc_ncm_rx_verify_nth16(struct cdc_ncm_ctx *ctx, struct sk_buff *skb_in);
 extern int cdc_ncm_rx_verify_ndp16(struct sk_buff *skb_in, int ndpoffset);
+struct sk_buff *
+cdc_ncm_tx_fixup(struct usbnet *dev, struct sk_buff *skb, gfp_t flags);
+int cdc_ncm_rx_fixup(struct usbnet *dev, struct sk_buff *skb_in);
-- 
1.8.4
