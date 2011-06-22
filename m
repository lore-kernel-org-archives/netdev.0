From: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Subject: [PATCH 4/7] qlcnic: fix initial number of msix entries in adapter.
Date: Wed, 22 Jun 2011 05:52:20 -0700
Message-ID: <1308747144-23785-4-git-send-email-anirban.chakraborty@qlogic.com>
References: <1308747144-23785-1-git-send-email-anirban.chakraborty@qlogic.com>
Cc: David Miller <davem@davemloft.net>,
	Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:36207 "EHLO hera.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753924Ab1FVONp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jun 2011 10:13:45 -0400
Received: from mx.mv.qlogic.com (vpn.pathscale.com [198.186.3.75] (may be forged))
	by hera.kernel.org (8.14.4/8.14.3) with SMTP id p5MEDXad019770
	for <netdev@vger.kernel.org>; Wed, 22 Jun 2011 14:13:33 GMT
In-Reply-To: <1308747144-23785-1-git-send-email-anirban.chakraborty@qlogic.com>
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

