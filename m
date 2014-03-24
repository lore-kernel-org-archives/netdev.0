From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 3/7] intel: Remove casts of pointer
	to same type
Date: Mon, 24 Mar 2014 13:15:36 -0700
Message-ID: <9e1ace2dfe6b14005e66c914b4905efb3eadd18e.1395692043.git.joe@perches.com>
References: <cover.1395692043.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, Bruce Allan <bruce.w.allan@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	linux-kernel@vger.kernel.org, John Ronciak <john.ronciak@intel.com>
To: netdev@vger.kernel.org
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <cover.1395692043.git.joe@perches.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Casting a pointer to a pointer of the same type is pointless,
so remove these unnecessary casts.

Done via coccinelle script:

$ cat typecast_2.cocci
@@
type T;
T *foo;
@@

-	(T *)foo
+	foo

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index 28da412..93c09c0 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -396,7 +396,7 @@ static int i40e_get_eeprom(struct net_device *netdev,
 		ret_val = i40e_aq_read_nvm(hw, 0x0,
 				eeprom->offset + (I40E_NVM_SECTOR_SIZE * i),
 				len,
-				(u8 *)eeprom_buff + (I40E_NVM_SECTOR_SIZE * i),
+				eeprom_buff + (I40E_NVM_SECTOR_SIZE * i),
 				last, NULL);
 		if (ret_val) {
 			dev_info(&pf->pdev->dev,
@@ -408,7 +408,7 @@ static int i40e_get_eeprom(struct net_device *netdev,
 
 release_nvm:
 	i40e_release_nvm(hw);
-	memcpy(bytes, (u8 *)eeprom_buff, eeprom->len);
+	memcpy(bytes, eeprom_buff, eeprom->len);
 free_buff:
 	kfree(eeprom_buff);
 	return ret_val;
-- 
1.8.1.2.459.gbcd45b4.dirty


------------------------------------------------------------------------------
Learn Graph Databases - Download FREE O'Reilly Book
"Graph Databases" is the definitive new guide to graph databases and their
applications. Written by three acclaimed leaders in the field,
this first edition is now available. Download your free book today!
http://p.sf.net/sfu/13534_NeoTech
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
