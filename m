From: <yanjiang.jin@windriver.com>
Subject: [PATCH] ethernet: e1000e: define lat_ns as u64 instead of s64
Date: Fri, 3 Apr 2015 17:17:53 +0800
Message-ID: <1428052673-16412-1-git-send-email-yanjiang.jin@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <jeffrey.t.kirsher@intel.com>, <jesse.brandeburg@intel.com>,
	<carolyn.wyborny@intel.com>, <donald.c.skidmore@intel.com>,
	<gregory.v.rose@intel.com>, <matthew.vick@intel.com>,
	<john.ronciak@intel.com>, <mitch.a.williams@intel.com>,
	<e1000-devel@lists.sourceforge.net>, <linux.nics@intel.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<jinyanjiang@gmail.com>
To: <bruce.w.allan@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:52469 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751338AbbDCJSJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Apr 2015 05:18:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yanjiang Jin <yanjiang.jin@windriver.com>

do_div() expects the type of "n" to be uint64_t, define "lat_ns" as u64 to
avoid the below warning, also update its correlative operations and data.

In file included from ./arch/powerpc/include/asm/div64.h:1:0,
                 from include/linux/kernel.h:124,
                 from include/linux/list.h:8,
                 from include/linux/timer.h:4,
                 from drivers/net/ethernet/intel/e1000e/e1000.h:29,
                 from drivers/net/ethernet/intel/e1000e/ich8lan.c:59:
drivers/net/ethernet/intel/e1000e/ich8lan.c: In function 'e1000_platform_pm_pch_lpt':
include/asm-generic/div64.h:43:28: warning: comparison of distinct pointer types lacks a cast [enabled by default]
  (void)(((typeof((n)) *)0) == ((uint64_t *)0)); \
                            ^
drivers/net/ethernet/intel/e1000e/ich8lan.c:1016:4: note: in expansion of macro 'do_div'
    do_div(lat_ns, speed);

Signed-off-by: Yanjiang Jin <yanjiang.jin@windriver.com>
---
 drivers/net/ethernet/intel/e1000e/ich8lan.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/ich8lan.c b/drivers/net/ethernet/intel/e1000e/ich8lan.c
index 48b74a5..baab58b 100644
--- a/drivers/net/ethernet/intel/e1000e/ich8lan.c
+++ b/drivers/net/ethernet/intel/e1000e/ich8lan.c
@@ -982,8 +982,8 @@ static s32 e1000_platform_pm_pch_lpt(struct e1000_hw *hw, bool link)
 		u16 speed, duplex, scale = 0;
 		u16 max_snoop, max_nosnoop;
 		u16 max_ltr_enc;	/* max LTR latency encoded */
-		s64 lat_ns;	/* latency (ns) */
-		s64 value;
+		u64 lat_ns;	/* latency (ns) */
+		u64 value;
 		u32 rxa;
 
 		if (!hw->adapter->max_frame_size) {
@@ -1008,8 +1008,8 @@ static s32 e1000_platform_pm_pch_lpt(struct e1000_hw *hw, bool link)
 		 * 2^25*(2^10-1) ns.  The scale is encoded as 0=2^0ns,
 		 * 1=2^5ns, 2=2^10ns,...5=2^25ns.
 		 */
-		lat_ns = ((s64)rxa * 1024 -
-			  (2 * (s64)hw->adapter->max_frame_size)) * 8 * 1000;
+		lat_ns = ((u64)rxa * 1024 -
+			  (2 * (u64)hw->adapter->max_frame_size)) * 8 * 1000;
 		if (lat_ns < 0)
 			lat_ns = 0;
 		else
-- 
1.9.1
