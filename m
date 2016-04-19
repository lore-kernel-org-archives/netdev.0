From: Denys Vlasenko <dvlasenk@redhat.com>
Subject: [PATCH 1/3] e1000e: e1000e_cyclecounter_read(): incvalue is 32 bits, not 64
Date: Tue, 19 Apr 2016 14:34:44 +0200
Message-ID: <1461069286-31946-1-git-send-email-dvlasenk@redhat.com>
Cc: Denys Vlasenko <dvlasenk@redhat.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Shannon Nelson <shannon.nelson@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Mitch Williams <mitch.a.williams@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"incvalue" variable holds a result of "er32(TIMINCA) & E1000_TIMINCA_INCVALUE_MASK"
and used in "do_div(temp, incvalue)" as a divisor.

Thus, "u64 incvalue" declaration is probably a mistake.
Even though it seems to be a harmless one, let's fix it.

Signed-off-by: Denys Vlasenko <dvlasenk@redhat.com>
CC: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
CC: Jesse Brandeburg <jesse.brandeburg@intel.com>
CC: Shannon Nelson <shannon.nelson@intel.com>
CC: Carolyn Wyborny <carolyn.wyborny@intel.com>
CC: Don Skidmore <donald.c.skidmore@intel.com>
CC: Bruce Allan <bruce.w.allan@intel.com>
CC: John Ronciak <john.ronciak@intel.com>
CC: Mitch Williams <mitch.a.williams@intel.com>
CC: David S. Miller <davem@davemloft.net>
CC: LKML <linux-kernel@vger.kernel.org>
CC: netdev@vger.kernel.org
---
 drivers/net/ethernet/intel/e1000e/netdev.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 9b4ec13..967311b 100644
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
1.8.1.4
