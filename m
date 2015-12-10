From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: [PATCH v1 1/2] net:hns: annotate IO address space properly
Date: Thu, 10 Dec 2015 17:23:09 +0200
Message-ID: <1449760990-111046-1-git-send-email-andriy.shevchenko@linux.intel.com>
Cc: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	huangdaode <huangdaode@hisilicon.com>,
	Rasmus Villemoes <linux@rasmusvillemoes.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:56042 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751387AbbLJPX7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Dec 2015 10:23:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mark address pointer with __iomem in the IO accessors.

Otherwise we will get a sparse complain like following

.../hns/hns_dsaf_reg.h:991:36: warning: incorrect type in argument 1 (different address spaces)
.../hns/hns_dsaf_reg.h:991:36:    expected unsigned char [noderef] [usertype] <asn:2>*base
.../hns/hns_dsaf_reg.h:991:36:    got void *base

Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h | 11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h
index c4d7c26..5d1b746 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h
@@ -956,7 +956,7 @@
 #define XGMAC_PAUSE_CTL_RSP_MODE_B	2
 #define XGMAC_PAUSE_CTL_TX_XOFF_B	3
 
-static inline void dsaf_write_reg(void *base, u32 reg, u32 value)
+static inline void dsaf_write_reg(void __iomem *base, u32 reg, u32 value)
 {
 	u8 __iomem *reg_addr = ACCESS_ONCE(base);
 
@@ -966,7 +966,7 @@ static inline void dsaf_write_reg(void *base, u32 reg, u32 value)
 #define dsaf_write_dev(a, reg, value) \
 	dsaf_write_reg((a)->io_base, (reg), (value))
 
-static inline u32 dsaf_read_reg(u8 *base, u32 reg)
+static inline u32 dsaf_read_reg(u8 __iomem *base, u32 reg)
 {
 	u8 __iomem *reg_addr = ACCESS_ONCE(base);
 
@@ -985,8 +985,8 @@ static inline u32 dsaf_read_reg(u8 *base, u32 reg)
 #define dsaf_set_bit(origin, shift, val) \
 	dsaf_set_field((origin), (1ull << (shift)), (shift), (val))
 
-static inline void dsaf_set_reg_field(void *base, u32 reg, u32 mask, u32 shift,
-				      u32 val)
+static inline void dsaf_set_reg_field(void __iomem *base, u32 reg, u32 mask,
+				      u32 shift, u32 val)
 {
 	u32 origin = dsaf_read_reg(base, reg);
 
@@ -1005,7 +1005,8 @@ static inline void dsaf_set_reg_field(void *base, u32 reg, u32 mask, u32 shift,
 #define dsaf_get_bit(origin, shift) \
 	dsaf_get_field((origin), (1ull << (shift)), (shift))
 
-static inline u32 dsaf_get_reg_field(void *base, u32 reg, u32 mask, u32 shift)
+static inline u32 dsaf_get_reg_field(void __iomem *base, u32 reg, u32 mask,
+				     u32 shift)
 {
 	u32 origin;
 
-- 
2.6.2
