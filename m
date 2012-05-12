From: "Linus Walleij" <linus.walleij@linaro.org>
Subject: [PATCH 16/17 v5] rndis_host: cleanup: change oid from __le32 to u32 in rndis_query()
Date: Sat, 12 May 2012 10:17:50 +0200
Message-ID: <1336810670-6619-1-git-send-email-linus.walleij@linaro.org>
Cc: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>,
	Haiyang Zhang <haiyangz@microsoft.com>,
	Wei Yongjun <yongjun_wei@trendmicro.com.cn>,
	Ben Hutchings <ben@decadent.org.uk>,
	Linus Walleij <linus.walleij@linaro.org>
To: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Felipe Balbi <balbi@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.df.lth.se ([194.47.250.12]:51223 "EHLO mail.df.lth.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753995Ab2ELIRx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 May 2012 04:17:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>

Signed-off-by: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Signed-off-by: Linus Walleij <linus.walleij@linaro.org>
---
 drivers/net/usb/rndis_host.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/usb/rndis_host.c b/drivers/net/usb/rndis_host.c
index 74315fd..0d746b3 100644
--- a/drivers/net/usb/rndis_host.c
+++ b/drivers/net/usb/rndis_host.c
@@ -239,7 +239,7 @@ EXPORT_SYMBOL_GPL(rndis_command);
  * ActiveSync 4.1 Windows driver.
  */
 static int rndis_query(struct usbnet *dev, struct usb_interface *intf,
-		void *buf, __le32 oid, u32 in_len,
+		void *buf, u32 oid, u32 in_len,
 		void **reply, int *reply_len)
 {
 	int retval;
@@ -256,7 +256,7 @@ static int rndis_query(struct usbnet *dev, struct usb_interface *intf,
 	memset(u.get, 0, sizeof *u.get + in_len);
 	u.get->msg_type = cpu_to_le32(RNDIS_MSG_QUERY);
 	u.get->msg_len = cpu_to_le32(sizeof *u.get + in_len);
-	u.get->oid = oid;
+	u.get->oid = cpu_to_le32(oid);
 	u.get->len = cpu_to_le32(in_len);
 	u.get->offset = cpu_to_le32(20);
 
@@ -399,8 +399,8 @@ generic_rndis_bind(struct usbnet *dev, struct usb_interface *intf, int flags)
 	phym = NULL;
 	reply_len = sizeof *phym;
 	retval = rndis_query(dev, intf, u.buf,
-			     cpu_to_le32(RNDIS_OID_GEN_PHYSICAL_MEDIUM),
-			0, (void **) &phym, &reply_len);
+			     RNDIS_OID_GEN_PHYSICAL_MEDIUM,
+			     0, (void **) &phym, &reply_len);
 	if (retval != 0 || !phym) {
 		/* OID is optional so don't fail here. */
 		phym_unspec = cpu_to_le32(RNDIS_PHYSICAL_MEDIUM_UNSPECIFIED);
@@ -424,8 +424,8 @@ generic_rndis_bind(struct usbnet *dev, struct usb_interface *intf, int flags)
 	/* Get designated host ethernet address */
 	reply_len = ETH_ALEN;
 	retval = rndis_query(dev, intf, u.buf,
-			     cpu_to_le32(RNDIS_OID_802_3_PERMANENT_ADDRESS),
-			48, (void **) &bp, &reply_len);
+			     RNDIS_OID_802_3_PERMANENT_ADDRESS,
+			     48, (void **) &bp, &reply_len);
 	if (unlikely(retval< 0)) {
 		dev_err(&intf->dev, "rndis get ethaddr, %d\n", retval);
 		goto halt_fail_and_release;
-- 
1.7.7.6
