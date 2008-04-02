From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH 2/5] e1000e: limit EEPROM size accesses
Date: Wed, 02 Apr 2008 13:48:07 -0700
Message-ID: <20080402204807.29122.77075.stgit@localhost.localdomain>
References: <20080402204802.29122.81707.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20080402204802.29122.81707.stgit@localhost.localdomain>
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

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000e/82571.c  |    4 ++++
 drivers/net/e1000e/es2lan.c |    4 ++++
 2 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/drivers/net/e1000e/82571.c b/drivers/net/e1000e/82571.c
index f7e1619..9b46a00 100644
--- a/drivers/net/e1000e/82571.c
+++ b/drivers/net/e1000e/82571.c
@@ -171,6 +171,10 @@ static s32 e1000_init_nvm_params_82571(struct e1000_hw *hw)
 		 * for setting word_size.
 		 */
 		size += NVM_WORD_SIZE_BASE_SHIFT;
+
+		/* EEPROM access above 16k is unsupported */
+		if (size > 14)
+			size = 14;
 		nvm->word_size	= 1 << size;
 		break;
 	}
diff --git a/drivers/net/e1000e/es2lan.c b/drivers/net/e1000e/es2lan.c
index e3f4aee..2689e4b 100644
--- a/drivers/net/e1000e/es2lan.c
+++ b/drivers/net/e1000e/es2lan.c
@@ -178,6 +178,10 @@ static s32 e1000_init_nvm_params_80003es2lan(struct e1000_hw *hw)
 	 * for setting word_size.
 	 */
 	size += NVM_WORD_SIZE_BASE_SHIFT;
+
+	/* EEPROM access above 16k is unsupported */
+	if (size > 14)
+		size = 14;
 	nvm->word_size	= 1 << size;
 
 	return 0;


-------------------------------------------------------------------------
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services for
just about anything Open Source.
http://ad.doubleclick.net/clk;164216239;13503038;w?http://sf.net/marketplace
