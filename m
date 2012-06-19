From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [RFC net-next 04/14] Fix qlogic/qlge
Date: Tue, 19 Jun 2012 18:13:58 +0300
Message-ID: <1340118848-30978-5-git-send-email-yuvalmin@broadcom.com>
References: <1340118848-30978-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, "Yuval Mintz" <yuvalmin@broadcom.com>,
	"Anirban Chakraborty" <anirban.chakraborty@qlogic.com>,
	"Jitendra Kalsaria" <jitendra.kalsaria@qlogic.com>,
	"Ron Mercer" <ron.mercer@qlogic.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2600 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753424Ab2FSPQ3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jun 2012 11:16:29 -0400
In-Reply-To: <1340118848-30978-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Cc: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Cc: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Cc: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlge/qlge_main.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlge/qlge_main.c b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
index 09d8d33..c6c91de 100644
--- a/drivers/net/ethernet/qlogic/qlge/qlge_main.c
+++ b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
@@ -4646,10 +4646,12 @@ static int __devinit qlge_probe(struct pci_dev *pdev,
 	struct net_device *ndev = NULL;
 	struct ql_adapter *qdev = NULL;
 	static int cards_found = 0;
-	int err = 0;
+	int err = 0, ncpu;
+
+	ncpu = min_t(int, num_online_cpus(), DEFAULT_MAX_NUM_RSS_QUEUES);
 
 	ndev = alloc_etherdev_mq(sizeof(struct ql_adapter),
-			min(MAX_CPUS, (int)num_online_cpus()));
+				 min(MAX_CPUS, ncpu));
 	if (!ndev)
 		return -ENOMEM;
 
-- 
1.7.9.rc2
