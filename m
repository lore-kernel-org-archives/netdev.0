From: ganesh.venkatesan@intel.com
Subject: [PATCH 11/12 2.5] e1000 - suspend/resume fix from alex@zodiac.dasalias.org
Date: Thu, 29 Jul 2004 08:32:55 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0407290816250.21929-100000@westville2.jf.intel.com>
Reply-To: ganesh.venkatesan@intel.com
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, <ganesh.venkatesan@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

diff -up linux-2.5/drivers/net/e1000/e1000_main.c linux-2.5/drivers/net/e1000.new/e1000_main.c
--- linux-2.5/drivers/net/e1000/e1000_main.c	2004-07-28 21:50:08.672461176 -0700
+++ linux-2.5/drivers/net/e1000.new/e1000_main.c	2004-07-28 21:50:09.523331824 -0700
@@ -2901,6 +2901,8 @@ e1000_suspend(struct pci_dev *pdev, uint
 		}
 	}
 
+	pci_disable_device(pdev);
+
 	state = (state > 0) ? 3 : 0;
 	pci_set_power_state(pdev, state);
 
@@ -2915,6 +2917,7 @@ e1000_resume(struct pci_dev *pdev)
 	struct e1000_adapter *adapter = netdev->priv;
 	uint32_t manc;
 
+	pci_enable_device(pdev);
 	pci_set_power_state(pdev, 0);
 	pci_restore_state(pdev, adapter->pci_state);
 
