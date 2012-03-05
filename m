From: Jiri Slaby <jslaby@suse.cz>
Subject: [PATCH 17/68] NET: pc300, show version info from module init
Date: Mon,  5 Mar 2012 14:52:04 +0100
Message-ID: <1330955575-26641-18-git-send-email-jslaby@suse.cz>
References: <1330955575-26641-1-git-send-email-jslaby@suse.cz>
Cc: alan@linux.intel.com, linux-serial@vger.kernel.org,
	linux-kernel@vger.kernel.org, jirislaby@gmail.com,
	netdev@vger.kernel.org
To: gregkh@linuxfoundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1330955575-26641-1-git-send-email-jslaby@suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Again, no need to do that from the pci probe function.

Hmm, I noticed this driver is marked as BROKEN. Won't touch it more,
it has to be converted to dynamic tty driver allocation first.

Perhaps it is time to move it to staging?

Signed-off-by: Jiri Slaby <jslaby@suse.cz>
Cc: netdev@vger.kernel.org
---
 drivers/net/wan/pc300_drv.c |    9 ++-------
 1 file changed, 2 insertions(+), 7 deletions(-)

diff --git a/drivers/net/wan/pc300_drv.c b/drivers/net/wan/pc300_drv.c
index a6dd00d..cb0f8d9 100644
--- a/drivers/net/wan/pc300_drv.c
+++ b/drivers/net/wan/pc300_drv.c
@@ -3231,7 +3231,7 @@ static void plx_init(pc300_t * card)
 
 }
 
-static inline void show_version(void)
+static void show_version(void)
 {
 	char *rcsvers, *rcsdate, *tmp;
 
@@ -3412,16 +3412,10 @@ static void cpc_init_card(pc300_t * card)
 static int __devinit
 cpc_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
-	static int first_time = 1;
 	int err, eeprom_outdated = 0;
 	u16 device_id;
 	pc300_t *card;
 
-	if (first_time) {
-		first_time = 0;
-		show_version();
-	}
-
 	if ((err = pci_enable_device(pdev)) < 0)
 		return err;
 
@@ -3657,6 +3651,7 @@ static struct pci_driver cpc_driver = {
 
 static int __init cpc_init(void)
 {
+	show_version();
 	return pci_register_driver(&cpc_driver);
 }
 
-- 
1.7.9.2
