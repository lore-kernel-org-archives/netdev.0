From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 14/15] e1000e: potentially incorrect return for e1000e_setup_fiber_serdes_link
Date: Mon, 13 Feb 2012 13:47:49 -0800
Message-ID: <1329169670-5403-15-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1329169670-5403-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:45312 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755798Ab2BMVsA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Feb 2012 16:48:00 -0500
In-Reply-To: <1329169670-5403-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

In the unlikely event that e1000_poll_fiber_serdes_link_generic() is called
and it returns an error, the returned error code value is not propagated to
the caller of e1000e_setup_fiber_serdes_link().

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/mac.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/mac.c b/drivers/net/ethernet/intel/e1000e/mac.c
index b3b2f9e..943b909 100644
--- a/drivers/net/ethernet/intel/e1000e/mac.c
+++ b/drivers/net/ethernet/intel/e1000e/mac.c
@@ -922,7 +922,7 @@ s32 e1000e_setup_fiber_serdes_link(struct e1000_hw *hw)
 		e_dbg("No signal detected\n");
 	}
 
-	return 0;
+	return ret_val;
 }
 
 /**
-- 
1.7.7.6
