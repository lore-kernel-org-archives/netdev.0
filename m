From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch -mainline] fm10k: drop upper bits of VLAN ID
Date: Fri, 30 Jan 2015 11:41:27 +0300
Message-ID: <20150130084127.GE21357@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	Matthew Vick <matthew.vick@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Mitch Williams <mitch.a.williams@intel.com>,
	Linux NICS <linux.nics@intel.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:42876 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752400AbbA3Il5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2015 03:41:57 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Static checkers complain that the shifts in "(vid << 4) >> 4" perfectly
cancel each other out and the code is a no-op.  "vid" is a u16.  The
comment says that the intention here is to drop the upper bits so I have
added a cast to "u16" to do that.

Fixes: 401b5383c6c9 ('fm10k: Add support for configuring PF interface')
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
---
Static analysis.  Not tested.

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pf.c b/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
index 275423d..ee30d06 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
@@ -335,7 +335,7 @@ static s32 fm10k_update_xc_addr_pf(struct fm10k_hw *hw, u16 glort,
 		return FM10K_ERR_PARAM;
 
 	/* drop upper 4 bits of VLAN ID */
-	vid = (vid << 4) >> 4;
+	vid = (u16)(vid << 4) >> 4;
 
 	/* record fields */
 	mac_update.mac_lower = cpu_to_le32(((u32)mac[2] << 24) |
