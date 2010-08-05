From: Julia Lawall <julia@diku.dk>
Subject: [PATCH 8/42] drivers/net/ixgbe: Adjust confusing if indentation
Date: Thu, 5 Aug 2010 22:19:18 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.1008052219010.31692__8698.36168499223$1281039601$gmane$org@ask.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Alex Duyck <alexander.h.duyck@intel.com>,
	PJ Waskiew
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw2.diku.dk ([130.225.96.92]:55363 "EHLO mgw2.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933554Ab0HEUTU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Aug 2010 16:19:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <julia@diku.dk>

Both ifs and assignments to autoc seem similar enough that they are both
put in the if branch indicated by their indentation.

The semantic match that finds this problem is as follows:
(http://coccinelle.lip6.fr/)

// <smpl>
@r disable braces4@
position p1,p2;
statement S1,S2;
@@

(
if (...) { ... }
|
if (...) S1@p1 S2@p2
)

@script:python@
p1 << r.p1;
p2 << r.p2;
@@

if (p1[0].column == p2[0].column):
  cocci.print_main("branch",p1)
  cocci.print_secs("after",p2)
// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>

---
This changes the semantics and might be the wrong fix.  Not tested.

 drivers/net/ixgbe/ixgbe_82599.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ixgbe/ixgbe_82599.c b/drivers/net/ixgbe/ixgbe_82599.c
index 3e06a61..a5fcdce 100644
--- a/drivers/net/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ixgbe/ixgbe_82599.c
@@ -766,12 +766,13 @@ s32 ixgbe_setup_mac_link_82599(struct ixgbe_hw *hw,
 	    link_mode == IXGBE_AUTOC_LMS_KX4_KX_KR_SGMII) {
 		/* Set KX4/KX/KR support according to speed requested */
 		autoc &= ~(IXGBE_AUTOC_KX4_KX_SUPP_MASK | IXGBE_AUTOC_KR_SUPP);
-		if (speed & IXGBE_LINK_SPEED_10GB_FULL)
+		if (speed & IXGBE_LINK_SPEED_10GB_FULL) {
 			if (orig_autoc & IXGBE_AUTOC_KX4_SUPP)
 				autoc |= IXGBE_AUTOC_KX4_SUPP;
 			if ((orig_autoc & IXGBE_AUTOC_KR_SUPP) &&
 			    (hw->phy.smart_speed_active == false))
 				autoc |= IXGBE_AUTOC_KR_SUPP;
+		}
 		if (speed & IXGBE_LINK_SPEED_1GB_FULL)
 			autoc |= IXGBE_AUTOC_KX_SUPP;
 	} else if ((pma_pmd_1g == IXGBE_AUTOC_1G_SFI) &&
