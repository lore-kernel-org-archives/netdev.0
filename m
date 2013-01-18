From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/12] e1000e: Use standard #defines for
	PCIe Capability ASPM fields
Date: Fri, 18 Jan 2013 07:04:37 -0800
Message-ID: <1358521487-28610-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1358521487-28610-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org, gospo@redhat.com,
	Bjorn Helgaas <bhelgaas@google.com>, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1358521487-28610-1-git-send-email-jeffrey.t.kirsher@intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Bjorn Helgaas <bhelgaas@google.com>

Use the standard #defines for PCIe Capability ASPM fields.

Previously we used PCIE_LINK_STATE_L0S and PCIE_LINK_STATE_L1 directly, but
these are defined for the Linux ASPM interfaces, e.g.,
pci_disable_link_state(), and only coincidentally match the actual register
bits.  PCIE_LINK_STATE_CLKPM, also part of that interface, does not match
the register bit.

Signed-off-by: Bjorn Helgaas <bhelgaas@google.com>
CC: e1000-devel@lists.sourceforge.net
Acked-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c | 11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 05538e6..bf2c84cf 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -5548,14 +5548,21 @@ static void __e1000e_disable_aspm(struct pci_dev *pdev, u16 state)
 #else
 static void __e1000e_disable_aspm(struct pci_dev *pdev, u16 state)
 {
+	u16 aspm_ctl = 0;
+
+	if (state & PCIE_LINK_STATE_L0S)
+		aspm_ctl |= PCI_EXP_LNKCTL_ASPM_L0S;
+	if (state & PCIE_LINK_STATE_L1)
+		aspm_ctl |= PCI_EXP_LNKCTL_ASPM_L1;
+
 	/* Both device and parent should have the same ASPM setting.
 	 * Disable ASPM in downstream component first and then upstream.
 	 */
-	pcie_capability_clear_word(pdev, PCI_EXP_LNKCTL, state);
+	pcie_capability_clear_word(pdev, PCI_EXP_LNKCTL, aspm_ctl);
 
 	if (pdev->bus->self)
 		pcie_capability_clear_word(pdev->bus->self, PCI_EXP_LNKCTL,
-					   state);
+					   aspm_ctl);
 }
 #endif
 static void e1000e_disable_aspm(struct pci_dev *pdev, u16 state)
-- 
1.7.11.7


------------------------------------------------------------------------------
Master HTML5, CSS3, ASP.NET, MVC, AJAX, Knockout.js, Web API and
much more. Get web development skills now with LearnDevNow -
350+ hours of step-by-step video tutorials by Microsoft MVPs and experts.
SALE $99.99 this month only -- learn more at:
http://p.sf.net/sfu/learnmore_122812
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
