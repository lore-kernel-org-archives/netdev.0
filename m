From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [RFC net-next 11/14] Fix emulex/benet
Date: Tue, 19 Jun 2012 18:14:05 +0300
Message-ID: <1340118848-30978-12-git-send-email-yuvalmin@broadcom.com>
References: <1340118848-30978-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, "Yuval Mintz" <yuvalmin@broadcom.com>,
	"Sathya Perla" <sathya.perla@emulex.com>,
	"Subbu Seetharaman" <subbu.seetharaman@emulex.com>,
	"Ajit Khaparde" <ajit.khaparde@emulex.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3913 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754439Ab2FSPQx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jun 2012 11:16:53 -0400
In-Reply-To: <1340118848-30978-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Cc: Sathya Perla <sathya.perla@emulex.com>
Cc: Subbu Seetharaman <subbu.seetharaman@emulex.com>
Cc: Ajit Khaparde <ajit.khaparde@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 5a34503..e42597d 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -2153,13 +2153,15 @@ static uint be_num_rss_want(struct be_adapter *adapter)
 static void be_msix_enable(struct be_adapter *adapter)
 {
 #define BE_MIN_MSIX_VECTORS		1
-	int i, status, num_vec, num_roce_vec = 0;
+	int i, status, num_vec, num_roce_vec = 0, ncpu;
+
+	ncpu = min_t(int, num_online_cpus(), DEFAULT_MAX_NUM_RSS_QUEUES);
 
 	/* If RSS queues are not used, need a vec for default RX Q */
-	num_vec = min(be_num_rss_want(adapter), num_online_cpus());
+	num_vec = min(be_num_rss_want(adapter), ncpu);
 	if (be_roce_supported(adapter)) {
 		num_roce_vec = min_t(u32, MAX_ROCE_MSIX_VECTORS,
-					(num_online_cpus() + 1));
+				     (u32)(ncpu + 1));
 		num_roce_vec = min(num_roce_vec, MAX_ROCE_EQS);
 		num_vec += num_roce_vec;
 		num_vec = min(num_vec, MAX_MSIX_VECTORS);
-- 
1.7.9.rc2
