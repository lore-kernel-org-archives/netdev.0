From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] fix drivers/net/irda/ali-ircc.c:ali_ircc_init()
Date: Sat, 8 Jul 2006 03:28:05 +0200
Message-ID: <20060708012800.GH26941@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from emailhub.stusta.mhn.de ([141.84.69.5]:44049 "HELO
	mailout.stusta.mhn.de") by vger.kernel.org with SMTP
	id S1751286AbWGHB2K (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Jul 2006 21:28:10 -0400
To: Samuel Ortiz <samuel@sortiz.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The Coverity checker spotted, that from the changes from commit 
898b1d16f8230fb912a0c2248df685735c6ceda3 the
       if (ret)
               platform_driver_unregister(&ali_ircc_driver);
was dead code.

This patch changes this function to what seems to have been the 
intention.

Signed-off-by: Adrian Bunk <bunk@stusta.de>

---

 drivers/net/irda/ali-ircc.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

--- linux-2.6.17-mm6-full/drivers/net/irda/ali-ircc.c.old	2006-07-08 01:44:53.000000000 +0200
+++ linux-2.6.17-mm6-full/drivers/net/irda/ali-ircc.c	2006-07-08 01:46:46.000000000 +0200
@@ -142,28 +142,29 @@
  *    Initialize chip. Find out whay kinds of chips we are dealing with
  *    and their configuation registers address
  */
 static int __init ali_ircc_init(void)
 {
 	ali_chip_t *chip;
 	chipio_t info;
-	int ret = -ENODEV;
+	int ret;
 	int cfg, cfg_base;
 	int reg, revision;
 	int i = 0;
 	
 	IRDA_DEBUG(2, "%s(), ---------------- Start ----------------\n", __FUNCTION__);
 
 	ret = platform_driver_register(&ali_ircc_driver);
         if (ret) {
                 IRDA_ERROR("%s, Can't register driver!\n",
 			   ALI_IRCC_DRIVER_NAME);
                 return ret;
         }
 
+	ret = -ENODEV;
 	
 	/* Probe for all the ALi chipsets we know about */
 	for (chip= chips; chip->name; chip++, i++) 
 	{
 		IRDA_DEBUG(2, "%s(), Probing for %s ...\n", __FUNCTION__, chip->name);
 				
 		/* Try all config registers for this chip */

