From: Matthew Garrett <mjg@redhat.com>
Subject: [PATCH v3 2/2] e1000e: Don't disable jumbo frames on
	82573L due to eeprom contents
Date: Thu, 11 Feb 2010 13:14:54 -0500
Message-ID: <1265912094-4705-2-git-send-email-mjg@redhat.com>
References: <1265912094-4705-1-git-send-email-mjg@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Matthew Garrett <mjg@redhat.com>
To: e1000-devel@lists.sourceforge.net
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1265912094-4705-1-git-send-email-mjg@redhat.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

According to the 82573L errata, jumbo frames will work correctly if ASPM
is disabled. Since we disable ASPM on these devices, leave jumbo frames
enabled.

Signed-off-by: Matthew Garrett <mjg@redhat.com>
---
Updated to provide the right chip name 

 drivers/net/e1000e/82571.c |   11 ++---------
 1 files changed, 2 insertions(+), 9 deletions(-)

diff --git a/drivers/net/e1000e/82571.c b/drivers/net/e1000e/82571.c
index 02d67d0..f26edf7 100644
--- a/drivers/net/e1000e/82571.c
+++ b/drivers/net/e1000e/82571.c
@@ -330,7 +330,6 @@ static s32 e1000_get_variants_82571(struct e1000_adapter *adapter)
 	struct e1000_hw *hw = &adapter->hw;
 	static int global_quad_port_a; /* global port a indication */
 	struct pci_dev *pdev = adapter->pdev;
-	u16 eeprom_data = 0;
 	int is_port_b = er32(STATUS) & E1000_STATUS_FUNC_1;
 	s32 rc;
 
@@ -381,16 +380,10 @@ static s32 e1000_get_variants_82571(struct e1000_adapter *adapter)
 		if (pdev->device == E1000_DEV_ID_82571EB_SERDES_QUAD)
 			adapter->flags &= ~FLAG_HAS_WOL;
 		break;
-
 	case e1000_82573:
 		if (pdev->device == E1000_DEV_ID_82573L) {
-			if (e1000_read_nvm(&adapter->hw, NVM_INIT_3GIO_3, 1,
-				       &eeprom_data) < 0)
-				break;
-			if (!(eeprom_data & NVM_WORD1A_ASPM_MASK)) {
-				adapter->flags |= FLAG_HAS_JUMBO_FRAMES;
-				adapter->max_hw_frame_size = DEFAULT_JUMBO;
-			}
+			adapter->flags |= FLAG_HAS_JUMBO_FRAMES;
+			adapter->max_hw_frame_size = DEFAULT_JUMBO;
 		}
 		break;
 	default:
-- 
1.6.6.1


------------------------------------------------------------------------------
SOLARIS 10 is the OS for Data Centers - provides features such as DTrace,
Predictive Self Healing and Award Winning ZFS. Get Solaris 10 NOW
http://p.sf.net/sfu/solaris-dev2dev
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
