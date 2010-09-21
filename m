From: Andy Shevchenko <andy.shevchenko@gmail.com>
Subject: [PATCHv1.5 1/3] drivers: atm: use native kernel's hex_to_bin() func
Date: Tue, 21 Sep 2010 09:40:24 +0300
Message-ID: <2d00b66224535ae82be1a1e638b86b81fb890f58.1285051188.git.andy.shevchenko@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Andy Shevchenko <andy.shevchenko@gmail.com>,
	Chas Williams <chas@cmf.nrl.navy.mil>,
	linux-atm-general@lists.sourceforge.net
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:47899 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753274Ab0IUGkn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Sep 2010 02:40:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Andy Shevchenko <andy.shevchenko@gmail.com>
Cc: Chas Williams <chas@cmf.nrl.navy.mil>
Cc: linux-atm-general@lists.sourceforge.net
---
 drivers/atm/horizon.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/atm/horizon.c b/drivers/atm/horizon.c
index 54720ba..a957904 100644
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

