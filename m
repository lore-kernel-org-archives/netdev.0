From: akpm@osdl.org
Subject: [patch 11/13] Fix suspend/resume on via-velocity
Date: Tue, 15 Mar 2005 14:22:48 -0800
Message-ID: <200503152222.j2FMMhMp016823@shell0.pdx.osdl.net>
Cc: jgarzik@pobox.com, netdev@oss.sgi.com, akpm@osdl.org, pavel@ucw.cz,
        pavel@suse.cz
To: davem@davemloft.net
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


From: Pavel Machek <pavel@ucw.cz>

This fixes suspend-resume on via-velocity.  It was confused w.r.t. 
pointers...  Now uses netdev_priv().  [Well, someone should run sed over
that driver, there are many more dev->priv].

Signed-off-by: Pavel Machek <pavel@suse.cz>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 25-akpm/drivers/net/via-velocity.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff -puN drivers/net/via-velocity.c~fix-suspend-resume-on-via-velocity drivers/net/via-velocity.c
--- 25/drivers/net/via-velocity.c~fix-suspend-resume-on-via-velocity	Tue Mar 15 14:19:55 2005
+++ 25-akpm/drivers/net/via-velocity.c	Tue Mar 15 14:19:55 2005
@@ -3212,7 +3212,8 @@ static int velocity_set_wol(struct veloc
 
 static int velocity_suspend(struct pci_dev *pdev, pm_message_t state)
 {
-	struct velocity_info *vptr = pci_get_drvdata(pdev);
+	struct net_device *dev = pci_get_drvdata(pdev);
+	struct velocity_info *vptr = netdev_priv(dev);
 	unsigned long flags;
 
 	if(!netif_running(vptr->dev))
@@ -3245,7 +3246,8 @@ static int velocity_suspend(struct pci_d
 
 static int velocity_resume(struct pci_dev *pdev)
 {
-	struct velocity_info *vptr = pci_get_drvdata(pdev);
+	struct net_device *dev = pci_get_drvdata(pdev);
+	struct velocity_info *vptr = netdev_priv(dev);
 	unsigned long flags;
 	int i;
 
_
