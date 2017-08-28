From: Tariq Toukan <tariqt@mellanox.com>
Subject: [ethtool] ethtool: Remove UDP Fragmentation Offload use from ethtool
Date: Mon, 28 Aug 2017 15:38:48 +0300
Message-ID: <1503923928-9419-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Shaker Daibes <shakerd@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:52274 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751269AbdH1MjK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 08:39:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shaker Daibes <shakerd@mellanox.com>

UFO was removed in kernel, here we remove it in ethtool app.

Fixes the following issue:
Features for ens8:
Cannot get device udp-fragmentation-offload settings: Operation not supported

Tested with "make check"

Signed-off-by: Shaker Daibes <shakerd@mellanox.com>
Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
---
 ethtool.8.in    |  3 ---
 ethtool.c       |  2 --
 internal.h      |  5 ++---
 test-features.c | 36 +++++-------------------------------
 4 files changed, 7 insertions(+), 39 deletions(-)

diff --git a/ethtool.8.in b/ethtool.8.in
index 7224b04b8f2f..f14ac53118c8 100644
--- a/ethtool.8.in
+++ b/ethtool.8.in
@@ -480,9 +480,6 @@ Specifies whether scatter-gather should be enabled.
 .A2 tso on off
 Specifies whether TCP segmentation offload should be enabled.
 .TP
-.A2 ufo on off
-Specifies whether UDP fragmentation offload should be enabled 
-.TP
 .A2 gso on off
 Specifies whether generic segmentation offload should be enabled 
 .TP
diff --git a/ethtool.c b/ethtool.c
index ad18704e7c5f..f3514447c18e 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -166,8 +166,6 @@ static const struct off_flag_def off_flag_def[] = {
 	  ETHTOOL_GSG,	   ETHTOOL_SSG,     ETH_FLAG_SG,	0 },
 	{ "tso",    "tcp-segmentation-offload",	    "tx-tcp*-segmentation",
 	  ETHTOOL_GTSO,	   ETHTOOL_STSO,    ETH_FLAG_TSO,	0 },
-	{ "ufo",    "udp-fragmentation-offload",    "tx-udp-fragmentation",
-	  ETHTOOL_GUFO,	   ETHTOOL_SUFO,    ETH_FLAG_UFO,	0 },
 	{ "gso",    "generic-segmentation-offload", "tx-generic-segmentation",
 	  ETHTOOL_GGSO,	   ETHTOOL_SGSO,    ETH_FLAG_GSO,	0 },
 	{ "gro",    "generic-receive-offload",	    "rx-gro",
diff --git a/internal.h b/internal.h
index 4e658ea54307..c033e080e4ff 100644
--- a/internal.h
+++ b/internal.h
@@ -112,12 +112,11 @@ static inline int test_bit(unsigned int nr, const unsigned long *addr)
 #define ETH_FLAG_TXCSUM		(1 << 1)
 #define ETH_FLAG_SG		(1 << 2)
 #define ETH_FLAG_TSO		(1 << 3)
-#define ETH_FLAG_UFO		(1 << 4)
 #define ETH_FLAG_GSO		(1 << 5)
 #define ETH_FLAG_GRO		(1 << 6)
 #define ETH_FLAG_INT_MASK	(ETH_FLAG_RXCSUM | ETH_FLAG_TXCSUM |	\
-				 ETH_FLAG_SG | ETH_FLAG_TSO | ETH_FLAG_UFO | \
-				 ETH_FLAG_GSO | ETH_FLAG_GRO),
+				 ETH_FLAG_SG | ETH_FLAG_TSO | ETH_FLAG_GSO | \
+				 ETH_FLAG_GRO),
 /* Mask of all flags defined for ETHTOOL_{G,S}FLAGS. */
 #define ETH_FLAG_EXT_MASK	(ETH_FLAG_LRO | ETH_FLAG_RXVLAN |	\
 				 ETH_FLAG_TXVLAN | ETH_FLAG_NTUPLE |	\
diff --git a/test-features.c b/test-features.c
index 6ebb364803a2..31e2a223d19c 100644
--- a/test-features.c
+++ b/test-features.c
@@ -37,10 +37,6 @@ cmd_gtso_off = { ETHTOOL_GTSO, 0 },
 cmd_gtso_on = { ETHTOOL_GTSO, 1 },
 cmd_stso_off = { ETHTOOL_STSO, 0 },
 cmd_stso_on = { ETHTOOL_STSO, 1 },
-cmd_gufo_off = { ETHTOOL_GUFO, 0 },
-cmd_gufo_on = { ETHTOOL_GUFO, 1 },
-cmd_sufo_off = { ETHTOOL_SUFO, 0 },
-cmd_sufo_on = { ETHTOOL_SUFO, 1 },
 cmd_ggso_off = { ETHTOOL_GGSO, 0 },
 cmd_ggso_on = { ETHTOOL_GGSO, 1 },
 cmd_sgso_off = { ETHTOOL_SGSO, 0 },
@@ -73,7 +69,6 @@ static const struct cmd_expect cmd_expect_get_features_off_old[] = {
 	{ &cmd_gtxcsum_off, 4, 0, &cmd_gtxcsum_off, sizeof(cmd_gtxcsum_off) },
 	{ &cmd_gsg_off, 4, 0, &cmd_gsg_off, sizeof(cmd_gsg_off) },
 	{ &cmd_gtso_off, 4, 0, &cmd_gtso_off, sizeof(cmd_gtso_off) },
-	{ &cmd_gufo_off, 4, 0, &cmd_gufo_off, sizeof(cmd_gufo_off) },
 	{ &cmd_ggso_off, 4, 0, &cmd_ggso_off, sizeof(cmd_ggso_off) },
 	{ &cmd_ggro_off, 4,0, &cmd_ggro_off, sizeof(cmd_ggro_off) },
 	{ &cmd_gflags_off, 4, 0, &cmd_gflags_off, sizeof(cmd_gflags_off) },
@@ -86,7 +81,6 @@ static const struct cmd_expect cmd_expect_get_features_off_old_some_unsup[] = {
 	{ &cmd_gtxcsum_off, 4, 0, &cmd_gtxcsum_off, sizeof(cmd_gtxcsum_off) },
 	{ &cmd_gsg_off, 4, 0, &cmd_gsg_off, sizeof(cmd_gsg_off) },
 	{ &cmd_gtso_off, 4, 0, &cmd_gtso_off, sizeof(cmd_gtso_off) },
-	{ &cmd_gufo_off, 4, -EOPNOTSUPP },
 	{ &cmd_ggso_off, 4, 0, &cmd_ggso_off, sizeof(cmd_ggso_off) },
 	{ &cmd_ggro_off, 4, -EOPNOTSUPP },
 	{ &cmd_gflags_off, 4, 0, &cmd_gflags_off, sizeof(cmd_gflags_off) },
@@ -99,7 +93,6 @@ static const struct cmd_expect cmd_expect_get_features_off_old_some_priv[] = {
 	{ &cmd_gtxcsum_off, 4, 0, &cmd_gtxcsum_off, sizeof(cmd_gtxcsum_off) },
 	{ &cmd_gsg_off, 4, 0, &cmd_gsg_off, sizeof(cmd_gsg_off) },
 	{ &cmd_gtso_off, 4, 0, &cmd_gtso_off, sizeof(cmd_gtso_off) },
-	{ &cmd_gufo_off, 4, 0, &cmd_gufo_off, sizeof(cmd_gufo_off) },
 	{ &cmd_ggso_off, 4, 0, &cmd_ggso_off, sizeof(cmd_ggso_off) },
 	{ &cmd_ggro_off, 4, -EPERM },
 	{ &cmd_gflags_off, 4, 0, &cmd_gflags_off, sizeof(cmd_gflags_off) },
@@ -112,7 +105,6 @@ static const struct cmd_expect cmd_expect_set_features_off_old[] = {
 	{ &cmd_gtxcsum_on, 4, 0, &cmd_gtxcsum_on, sizeof(cmd_gtxcsum_on) },
 	{ &cmd_gsg_on, 4, 0, &cmd_gsg_on, sizeof(cmd_gsg_on) },
 	{ &cmd_gtso_on, 4, 0, &cmd_gtso_on, sizeof(cmd_gtso_on) },
-	{ &cmd_gufo_on, 4, 0, &cmd_gufo_on, sizeof(cmd_gufo_on) },
 	{ &cmd_ggso_on, 4, 0, &cmd_ggso_on, sizeof(cmd_ggso_on) },
 	{ &cmd_ggro_on, 4,0, &cmd_ggro_on, sizeof(cmd_ggro_on) },
 	{ &cmd_gflags_on, 4, 0, &cmd_gflags_on, sizeof(cmd_sflags_on) },
@@ -120,7 +112,6 @@ static const struct cmd_expect cmd_expect_set_features_off_old[] = {
 	{ &cmd_stxcsum_off, sizeof(cmd_stxcsum_off), 0, 0, 0 },
 	{ &cmd_ssg_off, sizeof(cmd_ssg_off), 0, 0, 0 },
 	{ &cmd_stso_off, sizeof(cmd_stso_off), 0, 0, 0 },
-	{ &cmd_sufo_off, sizeof(cmd_sufo_off), 0, 0, 0 },
 	{ &cmd_sgso_off, sizeof(cmd_sgso_off), 0, 0, 0 },
 	{ &cmd_sgro_off, sizeof(cmd_sgro_off), 0, 0, 0 },
 	{ &cmd_sflags_off, sizeof(cmd_sflags_off), 0, 0, 0 },
@@ -128,7 +119,6 @@ static const struct cmd_expect cmd_expect_set_features_off_old[] = {
 	{ &cmd_gtxcsum_off, 4, 0, &cmd_gtxcsum_off, sizeof(cmd_gtxcsum_off) },
 	{ &cmd_gsg_off, 4, 0, &cmd_gsg_off, sizeof(cmd_gsg_off) },
 	{ &cmd_gtso_off, 4, 0, &cmd_gtso_off, sizeof(cmd_gtso_off) },
-	{ &cmd_gufo_off, 4, 0, &cmd_gufo_off, sizeof(cmd_gufo_off) },
 	{ &cmd_ggso_off, 4, 0, &cmd_ggso_off, sizeof(cmd_ggso_off) },
 	{ &cmd_ggro_off, 4,0, &cmd_ggro_off, sizeof(cmd_ggro_off) },
 	{ &cmd_gflags_off, 4, 0, &cmd_gflags_off, sizeof(cmd_sflags_off) },
@@ -141,7 +131,6 @@ static const struct cmd_expect cmd_expect_set_features_on_old[] = {
 	{ &cmd_gtxcsum_off, 4, 0, &cmd_gtxcsum_off, sizeof(cmd_gtxcsum_off) },
 	{ &cmd_gsg_off, 4, 0, &cmd_gsg_off, sizeof(cmd_gsg_off) },
 	{ &cmd_gtso_off, 4, 0, &cmd_gtso_off, sizeof(cmd_gtso_off) },
-	{ &cmd_gufo_off, 4, 0, &cmd_gufo_off, sizeof(cmd_gufo_off) },
 	{ &cmd_ggso_off, 4, 0, &cmd_ggso_off, sizeof(cmd_ggso_off) },
 	{ &cmd_ggro_off, 4,0, &cmd_ggro_off, sizeof(cmd_ggro_off) },
 	{ &cmd_gflags_off, 4, 0, &cmd_gflags_off, sizeof(cmd_gflags_off) },
@@ -149,7 +138,6 @@ static const struct cmd_expect cmd_expect_set_features_on_old[] = {
 	{ &cmd_stxcsum_on, sizeof(cmd_stxcsum_on), 0, 0, 0 },
 	{ &cmd_ssg_on, sizeof(cmd_ssg_on), 0, 0, 0 },
 	{ &cmd_stso_on, sizeof(cmd_stso_on), 0, 0, 0 },
-	{ &cmd_sufo_on, sizeof(cmd_sufo_on), 0, 0, 0 },
 	{ &cmd_sgso_on, sizeof(cmd_sgso_on), 0, 0, 0 },
 	{ &cmd_sgro_on, sizeof(cmd_sgro_on), 0, 0, 0 },
 	{ &cmd_sflags_on, sizeof(cmd_sflags_on), 0, 0, 0 },
@@ -157,7 +145,6 @@ static const struct cmd_expect cmd_expect_set_features_on_old[] = {
 	{ &cmd_gtxcsum_on, 4, 0, &cmd_gtxcsum_on, sizeof(cmd_gtxcsum_on) },
 	{ &cmd_gsg_on, 4, 0, &cmd_gsg_on, sizeof(cmd_gsg_on) },
 	{ &cmd_gtso_on, 4, 0, &cmd_gtso_on, sizeof(cmd_gtso_on) },
-	{ &cmd_gufo_on, 4, 0, &cmd_gufo_on, sizeof(cmd_gufo_on) },
 	{ &cmd_ggso_on, 4, 0, &cmd_ggso_on, sizeof(cmd_ggso_on) },
 	{ &cmd_ggro_on, 4,0, &cmd_ggro_on, sizeof(cmd_ggro_on) },
 	{ &cmd_gflags_on, 4, 0, &cmd_gflags_on, sizeof(cmd_sflags_on) },
@@ -170,7 +157,6 @@ static const struct cmd_expect cmd_expect_set_features_unsup_on_old[] = {
 	{ &cmd_gtxcsum_off, 4, 0, &cmd_gtxcsum_off, sizeof(cmd_gtxcsum_off) },
 	{ &cmd_gsg_off, 4, 0, &cmd_gsg_off, sizeof(cmd_gsg_off) },
 	{ &cmd_gtso_off, 4, 0, &cmd_gtso_off, sizeof(cmd_gtso_off) },
-	{ &cmd_gufo_off, 4, 0, &cmd_gufo_off, sizeof(cmd_gufo_off) },
 	{ &cmd_ggso_off, 4, 0, &cmd_ggso_off, sizeof(cmd_ggso_off) },
 	{ &cmd_ggro_off, 4,0, &cmd_ggro_off, sizeof(cmd_ggro_off) },
 	{ &cmd_gflags_off, 4, 0, &cmd_gflags_off, sizeof(cmd_gflags_off) },
@@ -290,7 +276,6 @@ static const struct cmd_expect cmd_expect_get_features_min_off[] = {
 	{ &cmd_gtxcsum_off, 4, 0, &cmd_gtxcsum_off, sizeof(cmd_gtxcsum_off) },
 	{ &cmd_gsg_off, 4, 0, &cmd_gsg_off, sizeof(cmd_gsg_off) },
 	{ &cmd_gtso_off, 4, 0, &cmd_gtso_off, sizeof(cmd_gtso_off) },
-	{ &cmd_gufo_off, 4, 0, &cmd_gufo_off, sizeof(cmd_gufo_off) },
 	{ &cmd_ggso_off, 4, 0, &cmd_ggso_off, sizeof(cmd_ggso_off) },
 	{ &cmd_ggro_off, 4,0, &cmd_ggro_off, sizeof(cmd_ggro_off) },
 	{ &cmd_gflags_off, 4, 0, &cmd_gflags_off, sizeof(cmd_gflags_off) },
@@ -308,7 +293,6 @@ static const struct cmd_expect cmd_expect_get_features_max_on[] = {
 	{ &cmd_gtxcsum_on, 4, 0, &cmd_gtxcsum_on, sizeof(cmd_gtxcsum_on) },
 	{ &cmd_gsg_on, 4, 0, &cmd_gsg_on, sizeof(cmd_gsg_on) },
 	{ &cmd_gtso_on, 4, 0, &cmd_gtso_on, sizeof(cmd_gtso_on) },
-	{ &cmd_gufo_on, 4, 0, &cmd_gufo_on, sizeof(cmd_gufo_on) },
 	{ &cmd_ggso_on, 4, 0, &cmd_ggso_on, sizeof(cmd_ggso_on) },
 	{ &cmd_ggro_on, 4,0, &cmd_ggro_on, sizeof(cmd_ggro_on) },
 	{ &cmd_gflags_on, 4, 0, &cmd_gflags_on, sizeof(cmd_sflags_on) },
@@ -326,7 +310,6 @@ static const struct cmd_expect cmd_expect_set_features_min_off_min_on[] = {
 	{ &cmd_gtxcsum_off, 4, 0, &cmd_gtxcsum_off, sizeof(cmd_gtxcsum_off) },
 	{ &cmd_gsg_off, 4, 0, &cmd_gsg_off, sizeof(cmd_gsg_off) },
 	{ &cmd_gtso_off, 4, 0, &cmd_gtso_off, sizeof(cmd_gtso_off) },
-	{ &cmd_gufo_off, 4, 0, &cmd_gufo_off, sizeof(cmd_gufo_off) },
 	{ &cmd_ggso_off, 4, 0, &cmd_ggso_off, sizeof(cmd_ggso_off) },
 	{ &cmd_ggro_off, 4,0, &cmd_ggro_off, sizeof(cmd_ggro_off) },
 	{ &cmd_gflags_off, 4, 0, &cmd_gflags_off, sizeof(cmd_gflags_off) },
@@ -338,7 +321,6 @@ static const struct cmd_expect cmd_expect_set_features_min_off_min_on[] = {
 	{ &cmd_gtxcsum_off, 4, 0, &cmd_gtxcsum_off, sizeof(cmd_gtxcsum_off) },
 	{ &cmd_gsg_off, 4, 0, &cmd_gsg_off, sizeof(cmd_gsg_off) },
 	{ &cmd_gtso_off, 4, 0, &cmd_gtso_off, sizeof(cmd_gtso_off) },
-	{ &cmd_gufo_off, 4, 0, &cmd_gufo_off, sizeof(cmd_gufo_off) },
 	{ &cmd_ggso_off, 4, 0, &cmd_ggso_off, sizeof(cmd_ggso_off) },
 	{ &cmd_ggro_on, 4,0, &cmd_ggro_on, sizeof(cmd_ggro_on) },
 	{ &cmd_gflags_off, 4, 0, &cmd_gflags_off, sizeof(cmd_gflags_off) },
@@ -356,7 +338,6 @@ static const struct cmd_expect cmd_expect_set_features_min_off_min_off[] = {
 	{ &cmd_gtxcsum_off, 4, 0, &cmd_gtxcsum_off, sizeof(cmd_gtxcsum_off) },
 	{ &cmd_gsg_off, 4, 0, &cmd_gsg_off, sizeof(cmd_gsg_off) },
 	{ &cmd_gtso_off, 4, 0, &cmd_gtso_off, sizeof(cmd_gtso_off) },
-	{ &cmd_gufo_off, 4, 0, &cmd_gufo_off, sizeof(cmd_gufo_off) },
 	{ &cmd_ggso_off, 4, 0, &cmd_ggso_off, sizeof(cmd_ggso_off) },
 	{ &cmd_ggro_off, 4,0, &cmd_ggro_off, sizeof(cmd_ggro_off) },
 	{ &cmd_gflags_off, 4, 0, &cmd_gflags_off, sizeof(cmd_gflags_off) },
@@ -367,7 +348,6 @@ static const struct cmd_expect cmd_expect_set_features_min_off_min_off[] = {
 	{ &cmd_gtxcsum_off, 4, 0, &cmd_gtxcsum_off, sizeof(cmd_gtxcsum_off) },
 	{ &cmd_gsg_off, 4, 0, &cmd_gsg_off, sizeof(cmd_gsg_off) },
 	{ &cmd_gtso_off, 4, 0, &cmd_gtso_off, sizeof(cmd_gtso_off) },
-	{ &cmd_gufo_off, 4, 0, &cmd_gufo_off, sizeof(cmd_gufo_off) },
 	{ &cmd_ggso_off, 4, 0, &cmd_ggso_off, sizeof(cmd_ggso_off) },
 	{ &cmd_ggro_off, 4,0, &cmd_ggro_off, sizeof(cmd_ggro_off) },
 	{ &cmd_gflags_off, 4, 0, &cmd_gflags_off, sizeof(cmd_gflags_off) },
@@ -385,7 +365,6 @@ static const struct cmd_expect cmd_expect_set_features_min_on_min_off[] = {
 	{ &cmd_gtxcsum_off, 4, 0, &cmd_gtxcsum_off, sizeof(cmd_gtxcsum_off) },
 	{ &cmd_gsg_off, 4, 0, &cmd_gsg_off, sizeof(cmd_gsg_off) },
 	{ &cmd_gtso_off, 4, 0, &cmd_gtso_off, sizeof(cmd_gtso_off) },
-	{ &cmd_gufo_off, 4, 0, &cmd_gufo_off, sizeof(cmd_gufo_off) },
 	{ &cmd_ggso_off, 4, 0, &cmd_ggso_off, sizeof(cmd_ggso_off) },
 	{ &cmd_ggro_on, 4,0, &cmd_ggro_on, sizeof(cmd_ggro_on) },
 	{ &cmd_gflags_off, 4, 0, &cmd_gflags_off, sizeof(cmd_gflags_off) },
@@ -396,7 +375,6 @@ static const struct cmd_expect cmd_expect_set_features_min_on_min_off[] = {
 	{ &cmd_gtxcsum_off, 4, 0, &cmd_gtxcsum_off, sizeof(cmd_gtxcsum_off) },
 	{ &cmd_gsg_off, 4, 0, &cmd_gsg_off, sizeof(cmd_gsg_off) },
 	{ &cmd_gtso_off, 4, 0, &cmd_gtso_off, sizeof(cmd_gtso_off) },
-	{ &cmd_gufo_off, 4, 0, &cmd_gufo_off, sizeof(cmd_gufo_off) },
 	{ &cmd_ggso_off, 4, 0, &cmd_ggso_off, sizeof(cmd_ggso_off) },
 	{ &cmd_ggro_off, 4,0, &cmd_ggro_off, sizeof(cmd_ggro_off) },
 	{ &cmd_gflags_off, 4, 0, &cmd_gflags_off, sizeof(cmd_gflags_off) },
@@ -414,7 +392,6 @@ static const struct cmd_expect cmd_expect_set_features_min_off_unsup_on[] = {
 	{ &cmd_gtxcsum_off, 4, 0, &cmd_gtxcsum_off, sizeof(cmd_gtxcsum_off) },
 	{ &cmd_gsg_off, 4, 0, &cmd_gsg_off, sizeof(cmd_gsg_off) },
 	{ &cmd_gtso_off, 4, 0, &cmd_gtso_off, sizeof(cmd_gtso_off) },
-	{ &cmd_gufo_off, 4, 0, &cmd_gufo_off, sizeof(cmd_gufo_off) },
 	{ &cmd_ggso_off, 4, 0, &cmd_ggso_off, sizeof(cmd_ggso_off) },
 	{ &cmd_ggro_off, 4,0, &cmd_ggro_off, sizeof(cmd_ggro_off) },
 	{ &cmd_gflags_off, 4, 0, &cmd_gflags_off, sizeof(cmd_gflags_off) },
@@ -425,7 +402,6 @@ static const struct cmd_expect cmd_expect_set_features_min_off_unsup_on[] = {
 	{ &cmd_gtxcsum_off, 4, 0, &cmd_gtxcsum_off, sizeof(cmd_gtxcsum_off) },
 	{ &cmd_gsg_off, 4, 0, &cmd_gsg_off, sizeof(cmd_gsg_off) },
 	{ &cmd_gtso_off, 4, 0, &cmd_gtso_off, sizeof(cmd_gtso_off) },
-	{ &cmd_gufo_off, 4, 0, &cmd_gufo_off, sizeof(cmd_gufo_off) },
 	{ &cmd_ggso_off, 4, 0, &cmd_ggso_off, sizeof(cmd_ggso_off) },
 	{ &cmd_ggro_off, 4,0, &cmd_ggro_off, sizeof(cmd_ggro_off) },
 	{ &cmd_gflags_off, 4, 0, &cmd_gflags_off, sizeof(cmd_gflags_off) },
@@ -443,7 +419,6 @@ static const struct cmd_expect cmd_expect_set_features_ipv4_off_many_on[] = {
 	{ &cmd_gtxcsum_off, 4, 0, &cmd_gtxcsum_off, sizeof(cmd_gtxcsum_off) },
 	{ &cmd_gsg_off, 4, 0, &cmd_gsg_off, sizeof(cmd_gsg_off) },
 	{ &cmd_gtso_off, 4, 0, &cmd_gtso_off, sizeof(cmd_gtso_off) },
-	{ &cmd_gufo_off, 4, 0, &cmd_gufo_off, sizeof(cmd_gufo_off) },
 	{ &cmd_ggso_off, 4, 0, &cmd_ggso_off, sizeof(cmd_ggso_off) },
 	{ &cmd_ggro_off, 4,0, &cmd_ggro_off, sizeof(cmd_ggro_off) },
 	{ &cmd_gflags_off, 4, 0, &cmd_gflags_off, sizeof(cmd_gflags_off) },
@@ -454,7 +429,6 @@ static const struct cmd_expect cmd_expect_set_features_ipv4_off_many_on[] = {
 	{ &cmd_gtxcsum_on, 4, 0, &cmd_gtxcsum_on, sizeof(cmd_gtxcsum_on) },
 	{ &cmd_gsg_on, 4, 0, &cmd_gsg_on, sizeof(cmd_gsg_on) },
 	{ &cmd_gtso_on, 4, 0, &cmd_gtso_on, sizeof(cmd_gtso_on) },
-	{ &cmd_gufo_off, 4, 0, &cmd_gufo_off, sizeof(cmd_gufo_off) },
 	{ &cmd_ggso_on, 4, 0, &cmd_ggso_on, sizeof(cmd_ggso_on) },
 	{ &cmd_ggro_on, 4,0, &cmd_ggro_on, sizeof(cmd_ggro_on) },
 	{ &cmd_gflags_off, 4, 0, &cmd_gflags_off, sizeof(cmd_gflags_off) },
@@ -471,18 +445,18 @@ static struct test_case {
 	{ 0, "-k devname", cmd_expect_get_features_off_old },
 	{ 0, "-k dev_unsup", cmd_expect_get_features_off_old_some_unsup },
 	{ 0, "-k dev_priv", cmd_expect_get_features_off_old_some_priv },
-	{ 0, "-K devname rx off tx off sg off tso off ufo off gso off lro off rxvlan off txvlan off ntuple off rxhash off gro off",
+	{ 0, "-K devname rx off tx off sg off tso off gso off lro off rxvlan off txvlan off ntuple off rxhash off gro off",
 	  cmd_expect_set_features_off_old },
-	{ 0, "-K devname rx on tx on sg on tso on ufo on gso on lro on rxvlan on txvlan on ntuple on rxhash on gro on",
+	{ 0, "-K devname rx on tx on sg on tso on gso on lro on rxvlan on txvlan on ntuple on rxhash on gro on",
 	  cmd_expect_set_features_on_old },
 	{ 1, "-K devname tx on sg on", cmd_expect_set_features_unsup_on_old },
 	{ 0, "--show-offload devname", cmd_expect_get_features_min_off },
 	{ 0, "--show-features devname", cmd_expect_get_features_max_on },
-	{ 0, "-K devname rx on tx on sg on tso on ufo on gso on gro on",
+	{ 0, "-K devname rx on tx on sg on tso on gso on gro on",
 	  cmd_expect_set_features_min_off_min_on },
-	{ 0, "-K devname rx off tx off sg off tso off ufo off gso off gro off",
+	{ 0, "-K devname rx off tx off sg off tso off gso off gro off",
 	  cmd_expect_set_features_min_off_min_off },
-	{ 0, "-K devname rx off tx off sg off tso off ufo off gso off gro off",
+	{ 0, "-K devname rx off tx off sg off tso off gso off gro off",
 	  cmd_expect_set_features_min_on_min_off },
 	{ 1, "-K devname tx on sg on",
 	  cmd_expect_set_features_min_off_unsup_on },
-- 
1.8.3.1
