From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/14] e1000e: e1000e_cyclecounter_read(): incvalue is 32 bits, not 64
Date: Fri, 13 May 2016 16:43:46 -0700
Message-ID: <1463183035-31888-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1463183035-31888-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Denys Vlasenko <dvlasenk@redhat.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:31691 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932145AbcEMXn7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 May 2016 19:43:59 -0400
In-Reply-To: <1463183035-31888-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Denys Vlasenko <dvlasenk@redhat.com>

"incvalue" variable holds a result of "er32(TIMINCA) &
E1000_TIMINCA_INCVALUE_MASK" and used in "do_div(temp, incvalue)"
as a divisor.

Thus, "u64 incvalue" declaration is probably a mistake.
Even though it seems to be a harmless one, let's fix it.

Signed-off-by: Denys Vlasenko <dvlasenk@redhat.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 671256d..4969f64 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -4300,7 +4300,8 @@ static cycle_t e1000e_cyclecounter_read(const struct cyclecounter *cc)
 	}
 
 	if ((hw->mac.type == e1000_82574) || (hw->mac.type == e1000_82583)) {
-		u64 incvalue, time_delta, rem, temp;
+		u64 time_delta, rem, temp;
+		u32 incvalue;
 		int i;
 
 		/* errata for 82574/82583 possible bad bits read from SYSTIMH/L
-- 
2.5.5
