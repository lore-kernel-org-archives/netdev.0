From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH 1/2] e1000: fix memcpy  in e1000_get_strings
Date: Wed, 05 Dec 2007 11:57:30 -0800
Message-ID: <20071205195729.6859.97796.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 12o3l@tiscali.nl
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:42110 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751696AbXLET6l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Dec 2007 14:58:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roel Kluin <12o3l@tiscali.nl>

drivers/net/e1000/e1000_ethtool.c:113:
#define E1000_TEST_LEN sizeof(e1000_gstrings_test) / ETH_GSTRING_LEN

drivers/net/e1000e/ethtool.c:106:
#define E1000_TEST_LEN sizeof(e1000_gstrings_test) / ETH_GSTRING_LEN

E1000_TEST_LEN*ETH_GSTRING_LEN will expand to
sizeof(e1000_gstrings_test) / (ETH_GSTRING_LEN * ETH_GSTRING_LEN)

A lack of parentheses around defines causes unexpected results due to
operator precedences.

Signed-off-by: Roel Kluin <12o3l@tiscali.nl>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000_ethtool.c |    2 +-
 drivers/net/e1000e/ethtool.c      |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/e1000/e1000_ethtool.c b/drivers/net/e1000/e1000_ethtool.c
index 0542b10..d876787 100644
--- a/drivers/net/e1000/e1000_ethtool.c
+++ b/drivers/net/e1000/e1000_ethtool.c
@@ -1949,7 +1949,7 @@ e1000_get_strings(struct net_device *netdev, uint32_t stringset, uint8_t *data)
 	switch (stringset) {
 	case ETH_SS_TEST:
 		memcpy(data, *e1000_gstrings_test,
-			E1000_TEST_LEN*ETH_GSTRING_LEN);
+			sizeof(e1000_gstrings_test));
 		break;
 	case ETH_SS_STATS:
 		for (i = 0; i < E1000_GLOBAL_STATS_LEN; i++) {
diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/e1000e/ethtool.c
index d824914..6d9c27f 100644
--- a/drivers/net/e1000e/ethtool.c
+++ b/drivers/net/e1000e/ethtool.c
@@ -1760,7 +1760,7 @@ static void e1000_get_strings(struct net_device *netdev, u32 stringset,
 	switch (stringset) {
 	case ETH_SS_TEST:
 		memcpy(data, *e1000_gstrings_test,
-			E1000_TEST_LEN*ETH_GSTRING_LEN);
+			sizeof(e1000_gstrings_test));
 		break;
 	case ETH_SS_STATS:
 		for (i = 0; i < E1000_GLOBAL_STATS_LEN; i++) {
