From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Subject: [PATCH net-next 05/10] liquidio: iq/oq limits
Date: Tue, 28 Jun 2016 17:54:27 -0700
Message-ID: <1467161672-21063-6-git-send-email-rvatsavayi@caviumnetworks.com>
References: <1467161672-21063-1-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>,
	Derek Chickles <derek.chickles@caviumnetworks.com>,
	Satanand Burla <satananda.burla@caviumnetworks.com>,
	Felix Manlunas <felix.manlunas@caviumnetworks.com>,
	Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0059.outbound.protection.outlook.com ([207.46.100.59]:46448
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752448AbcF2AzO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Jun 2016 20:55:14 -0400
In-Reply-To: <1467161672-21063-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes the dependency of number of iq/oq's on
number of cpus.

Signed-off-by: Derek Chickles <derek.chickles@caviumnetworks.com>
Signed-off-by: Satanand Burla <satananda.burla@caviumnetworks.com>
Signed-off-by: Felix Manlunas <felix.manlunas@caviumnetworks.com>
Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_main.c | 6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index 4528396..313ab32 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -3518,7 +3518,6 @@ static int setup_nic_devices(struct octeon_device *octeon_dev)
 	struct liquidio_if_cfg_resp *resp;
 	struct octdev_props *props;
 	int retval, num_iqueues, num_oqueues;
-	int num_cpus = num_online_cpus();
 	union oct_nic_if_cfg if_cfg;
 	unsigned int base_queue;
 	unsigned int gmx_port_id;
@@ -3560,10 +3559,7 @@ static int setup_nic_devices(struct octeon_device *octeon_dev)
 		gmx_port_id =
 			CFG_GET_GMXID_NIC_IF(octeon_get_conf(octeon_dev), i);
 		ifidx_or_pfnum = i;
-		if (num_iqueues > num_cpus)
-			num_iqueues = num_cpus;
-		if (num_oqueues > num_cpus)
-			num_oqueues = num_cpus;
+
 		dev_dbg(&octeon_dev->pci_dev->dev,
 			"requesting config for interface %d, iqs %d, oqs %d\n",
 			ifidx_or_pfnum, num_iqueues, num_oqueues);
-- 
1.8.3.1
