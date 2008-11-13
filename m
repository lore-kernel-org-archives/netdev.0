From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Subject: [patch] igb: use dev_printk instead of printk
Date: Thu, 13 Nov 2008 10:20:10 -0600
Message-ID: <200811130920.11930.bjorn.helgaas@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	Joh
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Use dev_printk() instead of printk() to give a little more context
and use consistent format.
    
Signed-off-by: Bjorn Helgaas <bjorn.helgaas@hp.com>

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 1f397cd..2799518 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -1019,10 +1019,9 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 			state &= ~PCIE_LINK_STATE_L0S;
 			pci_write_config_word(us_dev, pos + PCI_EXP_LNKCTL,
 			                      state);
-			printk(KERN_INFO "Disabling ASPM L0s upstream switch "
-			       "port %x:%x.%x\n", us_dev->bus->number,
-			       PCI_SLOT(us_dev->devfn),
-			       PCI_FUNC(us_dev->devfn));
+			dev_info(&pdev->dev,
+				 "Disabling ASPM L0s upstream switch port %s\n",
+				 pci_name(us_dev));
 		}
 	default:
 		break;

-------------------------------------------------------------------------
This SF.Net email is sponsored by the Moblin Your Move Developer's challenge
Build the coolest Linux based applications with Moblin SDK & win great prizes
Grand prize is a trip for two to an Open Source event anywhere in the world
http://moblin-contest.org/redirect.php?banner_id=100&url=/
