From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH 6/6] e1000e: Remove two compile warnings
Date: Fri, 10 Aug 2007 13:01:07 -0700
Message-ID: <20070810200107.21509.74125.stgit@localhost.localdomain>
References: <20070810200038.21509.77815.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	andi@firstfloor.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:33254 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S938165AbXHJUBJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Aug 2007 16:01:09 -0400
In-Reply-To: <20070810200038.21509.77815.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

CC [M]  drivers/net/e1000e/lib.o
drivers/net/e1000e/lib.c: In function 'e1000e_read_nvm_eerd':
drivers/net/e1000e/lib.c:1941: warning: 'ret_val' may be used uninitialized
in this function
  CC [M]  drivers/net/e1000e/phy.o
drivers/net/e1000e/phy.c: In function 'e1000e_phy_has_link_generic':
drivers/net/e1000e/phy.c:1324: warning: 'ret_val' may be used
uninitialized in this function

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000e/lib.c |    2 +-
 drivers/net/e1000e/phy.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/e1000e/lib.c b/drivers/net/e1000e/lib.c
index a04c1e4..6645c21 100644
--- a/drivers/net/e1000e/lib.c
+++ b/drivers/net/e1000e/lib.c
@@ -1938,7 +1938,7 @@ s32 e1000e_read_nvm_eerd(struct e1000_hw *hw, u16 offset, u16 words, u16 *data)
 {
 	struct e1000_nvm_info *nvm = &hw->nvm;
 	u32 i, eerd = 0;
-	s32 ret_val;
+	s32 ret_val = 0;
 
 	/* A check for invalid values:  offset too large, too many words,
 	 * and not enough words. */
diff --git a/drivers/net/e1000e/phy.c b/drivers/net/e1000e/phy.c
index 1efb47a..7932318 100644
--- a/drivers/net/e1000e/phy.c
+++ b/drivers/net/e1000e/phy.c
@@ -1321,7 +1321,7 @@ static s32 e1000_wait_autoneg(struct e1000_hw *hw)
 s32 e1000e_phy_has_link_generic(struct e1000_hw *hw, u32 iterations,
 			       u32 usec_interval, bool *success)
 {
-	s32 ret_val;
+	s32 ret_val = 0;
 	u16 i, phy_status;
 
 	for (i = 0; i < iterations; i++) {
