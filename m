From: Joe Perches <joe@perches.com>
Subject: [PATCH 27/62] ixgbevf: Use static const
Date: Sat, 20 Nov 2010 18:38:28 -0800
Message-ID: <2f0b47333ee780c36283db8b098a78285e7547fd.1290305776.git.joe@perches.com>
References: <cover.1290305773.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Ski
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <cover.1290305773.git.joe@perches.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Using static const generally increases object text and decreases data size.
It also generally decreases overall object size.

   text	   data	    bss	    dec	    hex	filename
   8436	    372	   1728	  10536	   2928	drivers/net/ixgbevf/ethtool.o.old
   8469	    252	   1728	  10449	   28d1	drivers/net/ixgbevf/ethtool.o.new

Make single file scope definition for register_test_patterns.
Rename _test to register_test_patterns.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ixgbevf/ethtool.c |   18 +++++++++++-------
 1 files changed, 11 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ixgbevf/ethtool.c b/drivers/net/ixgbevf/ethtool.c
index 4cc817a..fa29b3c 100644
--- a/drivers/net/ixgbevf/ethtool.c
+++ b/drivers/net/ixgbevf/ethtool.c
@@ -544,7 +544,7 @@ struct ixgbevf_reg_test {
 #define TABLE64_TEST_HI	6
 
 /* default VF register test */
-static struct ixgbevf_reg_test reg_test_vf[] = {
+static const struct ixgbevf_reg_test reg_test_vf[] = {
 	{ IXGBE_VFRDBAL(0), 2, PATTERN_TEST, 0xFFFFFF80, 0xFFFFFF80 },
 	{ IXGBE_VFRDBAH(0), 2, PATTERN_TEST, 0xFFFFFFFF, 0xFFFFFFFF },
 	{ IXGBE_VFRDLEN(0), 2, PATTERN_TEST, 0x000FFF80, 0x000FFFFF },
@@ -557,19 +557,23 @@ static struct ixgbevf_reg_test reg_test_vf[] = {
 	{ 0, 0, 0, 0 }
 };
 
+static const u32 register_test_patterns[] = {
+	0x5A5A5A5A, 0xA5A5A5A5, 0x00000000, 0xFFFFFFFF
+};
+
 #define REG_PATTERN_TEST(R, M, W)                                             \
 {                                                                             \
 	u32 pat, val, before;                                                 \
-	const u32 _test[] = {0x5A5A5A5A, 0xA5A5A5A5, 0x00000000, 0xFFFFFFFF}; \
-	for (pat = 0; pat < ARRAY_SIZE(_test); pat++) {                       \
+	for (pat = 0; pat < ARRAY_SIZE(register_test_patterns); pat++) {      \
 		before = readl(adapter->hw.hw_addr + R);                      \
-		writel((_test[pat] & W), (adapter->hw.hw_addr + R));          \
+		writel((register_test_patterns[pat] & W),                     \
+		       (adapter->hw.hw_addr + R));                            \
 		val = readl(adapter->hw.hw_addr + R);                         \
-		if (val != (_test[pat] & W & M)) {                            \
+		if (val != (register_test_patterns[pat] & W & M)) {           \
 			hw_dbg(&adapter->hw,                                  \
 			"pattern test reg %04X failed: got "                  \
 			"0x%08X expected 0x%08X\n",                           \
-			R, val, (_test[pat] & W & M));                        \
+			R, val, (register_test_patterns[pat] & W & M));       \
 			*data = R;                                            \
 			writel(before, adapter->hw.hw_addr + R);              \
 			return 1;                                             \
@@ -596,7 +600,7 @@ static struct ixgbevf_reg_test reg_test_vf[] = {
 
 static int ixgbevf_reg_test(struct ixgbevf_adapter *adapter, u64 *data)
 {
-	struct ixgbevf_reg_test *test;
+	const struct ixgbevf_reg_test *test;
 	u32 i;
 
 	test = reg_test_vf;
-- 
1.7.3.2.245.g03276.dirty


------------------------------------------------------------------------------
Beautiful is writing same markup. Internet Explorer 9 supports
standards for HTML5, CSS3, SVG 1.1,  ECMAScript5, and DOM L2 & L3.
Spend less time writing and  rewriting code and more time creating great
experiences on the web. Be a part of the beta today
http://p.sf.net/sfu/msIE9-sfdev2dev
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
