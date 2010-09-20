From: Andy Shevchenko <andy.shevchenko@gmail.com>
Subject: [PATCH 1/3] drivers: atm: use native kernel's hex_to_bin() func
Date: Tue, 21 Sep 2010 02:27:06 +0300
Message-ID: <ee8a4349cc0eb3a881994b77e1e415b92ff7e669.1285024850.git.andy.shevchenko@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Andy Shevchenko <andy.shevchenko@gmail.com>,
	Chas Williams <chas@cmf.nrl.navy.mil>,
	linux-atm-general@lists.sourceforge.net
To: linux-kernel@vger.krenel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:62431 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754304Ab0ITX10 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Sep 2010 19:27:26 -0400
Received: by ewy23 with SMTP id 23so1764617ewy.19
        for <netdev@vger.kernel.org>; Mon, 20 Sep 2010 16:27:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Andy Shevchenko <andy.shevchenko@gmail.com>
Cc: Chas Williams <chas@cmf.nrl.navy.mil>
Cc: linux-atm-general@lists.sourceforge.net
---
 drivers/atm/horizon.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/atm/horizon.c b/drivers/atm/horizon.c
index 54720ba..dbce700 100644
--- a/drivers/atm/horizon.c
+++ b/drivers/atm/horizon.c
@@ -1645,10 +1645,8 @@ static int hrz_send (struct atm_vcc * atm_vcc, struct sk_buff * skb) {
     unsigned short d = 0;
     char * s = skb->data;
     if (*s++ == 'D') {
-      for (i = 0; i < 4; ++i) {
-	d = (d<<4) | ((*s <= '9') ? (*s - '0') : (*s - 'a' + 10));
-	++s;
-      }
+	for (i = 0; i < 4; ++i)
+		d = (d << 4) | hex_to_bin(*s++);
       PRINTK (KERN_INFO, "debug bitmap is now %hx", debug = d);
     }
   }
-- 
1.7.2.2

