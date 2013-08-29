From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] mISDN: return -EINVAL on error in dsp_control_req()
Date: Thu, 29 Aug 2013 11:47:00 +0300
Message-ID: <20130829084700.GF14334@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Konstantin Khlebnikov <khlebnikov@openvz.org>,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Karsten Keil <isdn@linux-pingi.de>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If skb->len is too short then we should return an error.  Otherwise we
read beyond the end of skb->data for several bytes.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/isdn/mISDN/dsp_core.c b/drivers/isdn/mISDN/dsp_core.c
index 22b720e..77025f5 100644
--- a/drivers/isdn/mISDN/dsp_core.c
+++ b/drivers/isdn/mISDN/dsp_core.c
@@ -288,8 +288,10 @@ dsp_control_req(struct dsp *dsp, struct mISDNhead *hh, struct sk_buff *skb)
 	u8 *data;
 	int len;
 
-	if (skb->len < sizeof(int))
+	if (skb->len < sizeof(int)) {
 		printk(KERN_ERR "%s: PH_CONTROL message too short\n", __func__);
+		return -EINVAL;
+	}
 	cont = *((int *)skb->data);
 	len = skb->len - sizeof(int);
 	data = skb->data + sizeof(int);
