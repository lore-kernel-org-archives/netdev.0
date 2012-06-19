From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [RFC net-next 08/14] Fix chelsio/cxgb3
Date: Tue, 19 Jun 2012 18:14:02 +0300
Message-ID: <1340118848-30978-9-git-send-email-yuvalmin@broadcom.com>
References: <1340118848-30978-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, "Yuval Mintz" <yuvalmin@broadcom.com>,
	"Divy Le Ray" <divy@chelsio.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4204 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752269Ab2FSPQh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jun 2012 11:16:37 -0400
In-Reply-To: <1340118848-30978-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Cc: Divy Le Ray <divy@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c
index abb6ce7..17d7829 100644
--- a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c
@@ -3050,7 +3050,8 @@ static struct pci_error_handlers t3_err_handler = {
 static void set_nqsets(struct adapter *adap)
 {
 	int i, j = 0;
-	int num_cpus = num_online_cpus();
+	int num_cpus = min_t(int, num_online_cpus(),
+			     DEFAULT_MAX_NUM_RSS_QUEUES);
 	int hwports = adap->params.nports;
 	int nqsets = adap->msix_nvectors - 1;
 
-- 
1.7.9.rc2
