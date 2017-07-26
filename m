From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/14] i40e: fix up 32 bit timespec references
Date: Wed, 26 Jul 2017 03:31:14 -0700
Message-ID: <20170726103123.76743-6-jeffrey.t.kirsher@intel.com>
References: <20170726103123.76743-1-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:21438 "EHLO mga04.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751421AbdGZKdd (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 26 Jul 2017 06:33:33 -0400
In-Reply-To: <20170726103123.76743-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

As it turns out there was only a small set of errors
on 32 bit, and we just needed to be using the right calls
for dealing with timespec64 variables.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_ptp.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ptp.c b/drivers/net/ethernet/intel/i40e/i40e_ptp.c
index 1a0be835fa06..0129ed3b78ec 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ptp.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ptp.c
@@ -158,13 +158,12 @@ static int i40e_ptp_adjfreq(struct ptp_clock_info *ptp, s32 ppb)
 static int i40e_ptp_adjtime(struct ptp_clock_info *ptp, s64 delta)
 {
 	struct i40e_pf *pf = container_of(ptp, struct i40e_pf, ptp_caps);
-	struct timespec64 now, then;
+	struct timespec64 now;
 
-	then = ns_to_timespec64(delta);
 	mutex_lock(&pf->tmreg_lock);
 
 	i40e_ptp_read(pf, &now);
-	now = timespec64_add(now, then);
+	timespec64_add_ns(&now, delta);
 	i40e_ptp_write(pf, (const struct timespec64 *)&now);
 
 	mutex_unlock(&pf->tmreg_lock);
-- 
2.13.3
