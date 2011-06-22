From: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Subject: [PATCH 4/7] qlcnic: fix initial number of msix entries in adapter.
Date: Wed, 22 Jun 2011 05:55:59 -0700
Message-ID: <1308747359-23891-1-git-send-email-anirban.chakraborty@qlogic.com>
Cc: David Miller <davem@davemloft.net>,
	Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from vpn.pathscale.com ([198.186.3.75]:52071 "HELO mx.mv.qlogic.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with SMTP
	id S1757502Ab1FVNDy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jun 2011 09:03:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>

Calculation of number of MSI-X vectors was wrong on uniprocessor
systems.

Signed-off-by: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
Signed-off-by: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
---
 drivers/net/qlcnic/qlcnic.h      |    1 -
 drivers/net/qlcnic/qlcnic_main.c |    6 ++----
 2 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic.h b/drivers/net/qlcnic/qlcnic.h
index e5bb332..58d7616 100644
--- a/drivers/net/qlcnic/qlcnic.h
+++ b/drivers/net/qlcnic/qlcnic.h
@@ -900,7 +900,6 @@ struct qlcnic_ipaddr {
 	((adapter)->flags & (QLCNIC_MSI_ENABLED | QLCNIC_MSIX_ENABLED))
 
 #define QLCNIC_DEF_NUM_STS_DESC_RINGS	4
-#define QLCNIC_MIN_NUM_RSS_RINGS	2
 #define QLCNIC_MSIX_TBL_SPACE		8192
 #define QLCNIC_PCI_REG_MSIX_TBL 	0x44
 #define QLCNIC_MSIX_TBL_PGSIZE		4096
diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index a656a12..a050746 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -418,10 +418,8 @@ qlcnic_setup_intr(struct qlcnic_adapter *adapter)
 	int num_msix;
 
 	if (adapter->msix_supported) {
-		num_msix = (num_online_cpus() >=
-			QLCNIC_DEF_NUM_STS_DESC_RINGS) ?
-			QLCNIC_DEF_NUM_STS_DESC_RINGS :
-			QLCNIC_MIN_NUM_RSS_RINGS;
+		num_msix = rounddown_pow_of_two(min_t(int, num_online_cpus(),
+				QLCNIC_DEF_NUM_STS_DESC_RINGS));
 	} else
 		num_msix = 1;
 
-- 
1.7.4.1

