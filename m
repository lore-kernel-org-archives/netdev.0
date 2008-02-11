From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH 4/6] ixgbe: warn when device is in a x4 or
	lower width slot
Date: Mon, 11 Feb 2008 09:25:56 -0800
Message-ID: <20080211172556.29090.23204.stgit@localhost.localdomain>
References: <20080211172539.29090.99369.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20080211172539.29090.99369.stgit@localhost.localdomain>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

It's easy to oversee this issue when working with this card
as evrything will work OK but performance is severely limited
(something like 1.5gbit on a x1 link) if the pci-express
slot does not offer more bandwidth.

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index ead49e5..576fb51 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -2778,6 +2778,14 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 		 hw->mac.type, hw->phy.type,
 		 (part_num >> 8), (part_num & 0xff));
 
+	if (link_width <= IXGBE_PCI_LINK_WIDTH_4) {
+		dev_warn(&pdev->dev, "PCI-Express bandwidth available for "
+			 "this card is not sufficient for optimal "
+			 "performance.\n");
+		dev_warn(&pdev->dev, "For optimal performance a x8 "
+			 "PCI-Express slot is required.\n");
+	}
+
 	/* reset the hardware with the new settings */
 	ixgbe_start_hw(hw);
 


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2008.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
