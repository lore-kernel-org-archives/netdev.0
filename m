From: ganesh.venkatesan@intel.com
Subject: [PATCH 11/12 2.4] e1000 - suspend/resume fix from alex@zodiac.dasalias.org
Date: Thu, 29 Jul 2004 08:31:16 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0407290749430.21929-100000@westville2.jf.intel.com>
Reply-To: ganesh.venkatesan@intel.com
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, <ganesh.venkatesan@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

diff -up linux-2.4/drivers/net/e1000/e1000_main.c linux-2.4/drivers/net/e1000.new/e1000_main.c
--- linux-2.4/drivers/net/e1000/e1000_main.c	2004-07-28 08:47:08.177582000 -0700
+++ linux-2.4/drivers/net/e1000.new/e1000_main.c	2004-07-28 08:47:09.559371936 -0700
@@ -2902,6 +2902,8 @@ e1000_suspend(struct pci_dev *pdev, uint
 		}
 	}
 
+	pci_disable_device(pdev);
+
 	state = (state > 0) ? 3 : 0;
 	pci_set_power_state(pdev, state);
 
@@ -2916,6 +2918,7 @@ e1000_resume(struct pci_dev *pdev)
 	struct e1000_adapter *adapter = netdev->priv;
 	uint32_t manc;
 
+	pci_enable_device(pdev);
 	pci_set_power_state(pdev, 0);
 	pci_restore_state(pdev, adapter->pci_state);
 
