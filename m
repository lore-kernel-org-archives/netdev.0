From: akpm@osdl.org
Subject: [patch 3/7] E1000 stop working after resume
Date: Wed, 10 Nov 2004 16:02:25 -0800
Message-ID: <200411102358.iAANwE904206@mail.osdl.org>
Cc: jgarzik@pobox.com, netdev@oss.sgi.com, akpm@osdl.org, shaohua.li@intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


From: Li Shaohua <shaohua.li@intel.com>

Obviously pci_enable_device should be called after pci_restore_state. 

Signed-off-by: Li Shaohua <shaohua.li@intel.com>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 25-akpm/drivers/net/e1000/e1000_main.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletion(-)

diff -puN drivers/net/e1000/e1000_main.c~e1000-stop-working-after-resume drivers/net/e1000/e1000_main.c
--- 25/drivers/net/e1000/e1000_main.c~e1000-stop-working-after-resume	Wed Nov 10 16:00:36 2004
+++ 25-akpm/drivers/net/e1000/e1000_main.c	Wed Nov 10 16:00:36 2004
@@ -2885,9 +2885,11 @@ e1000_resume(struct pci_dev *pdev)
 	struct e1000_adapter *adapter = netdev->priv;
 	uint32_t manc, ret;
 
-	ret = pci_enable_device(pdev);
 	pci_set_power_state(pdev, 0);
 	pci_restore_state(pdev);
+	ret = pci_enable_device(pdev);
+	if (pdev->is_busmaster)
+		pci_set_master(pdev);
 
 	pci_enable_wake(pdev, 3, 0);
 	pci_enable_wake(pdev, 4, 0); /* 4 == D3 cold */
_
