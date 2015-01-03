From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 1/1 linux-next] hp100: simplify hp100_module_init
Date: Sat,  3 Jan 2015 14:44:16 +0100
Message-ID: <1420292656-14429-1-git-send-email-fabf@skynet.be>
Cc: Fabian Frederick <fabf@skynet.be>,
	Jaroslav Kysela <perex@perex.cz>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

-Avoid double goto and directly return err where possible.
-Remove unused labels which fixes:

drivers/net/ethernet/hp/hp100.c:3047:2: warning: label
'out3' defined but not used [-Wunused-label]

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
This is untested.

 drivers/net/ethernet/hp/hp100.c | 17 ++++++++---------
 1 file changed, 8 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/hp/hp100.c b/drivers/net/ethernet/hp/hp100.c
index ae6e30d..7155938 100644
--- a/drivers/net/ethernet/hp/hp100.c
+++ b/drivers/net/ethernet/hp/hp100.c
@@ -3031,26 +3031,25 @@ static int __init hp100_module_init(void)
 
 	err = hp100_isa_init();
 	if (err && err != -ENODEV)
-		goto out;
+		return err;
 #ifdef CONFIG_EISA
 	err = eisa_driver_register(&hp100_eisa_driver);
 	if (err && err != -ENODEV)
-		goto out2;
+		goto out_eisa;
+	else
+		return err;
 #endif
 #ifdef CONFIG_PCI
 	err = pci_register_driver(&hp100_pci_driver);
-	if (err && err != -ENODEV)
-		goto out3;
+	if (!err || err == -ENODEV)
+		return err;
 #endif
- out:
-	return err;
- out3:
 #ifdef CONFIG_EISA
 	eisa_driver_unregister (&hp100_eisa_driver);
- out2:
+ out_eisa:
 #endif
 	hp100_isa_cleanup();
-	goto out;
+	return err;
 }
 
 
-- 
2.1.0
