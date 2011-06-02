From: amit.salecha@qlogic.com
Subject: [PATCHv2 NEXT 1/1] netxen: suppress false lro warning messages
Date: Thu,  2 Jun 2011 05:24:14 -0700
Message-ID: <1307017454-10826-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	anirban.chakraborty@qlogic.com,
	Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>,
	Amit Kumar Salecha <amit.salecha@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from vpn.pathscale.com ([198.186.3.75]:32996 "HELO mx.mv.qlogic.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with SMTP
	id S933477Ab1FBMbW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Jun 2011 08:31:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>

When interface is down, driver prints false warning messages
during lro configuration through ethtool.

Signed-off-by: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/netxen/netxen_nic_hw.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index 5cef718..3f89e57 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -809,6 +809,9 @@ int netxen_config_hw_lro(struct netxen_adapter *adapter, int enable)
 	u64 word;
 	int rv = 0;
 
+	if (!test_bit(__NX_FW_ATTACHED, &adapter->state))
+		return 0;
+
 	memset(&req, 0, sizeof(nx_nic_req_t));
 
 	req.qhdr = cpu_to_le64(NX_HOST_REQUEST << 23);
@@ -959,6 +962,9 @@ int netxen_send_lro_cleanup(struct netxen_adapter *adapter)
 	u64 word;
 	int rv;
 
+	if (!test_bit(__NX_FW_ATTACHED, &adapter->state))
+		return 0;
+
 	memset(&req, 0, sizeof(nx_nic_req_t));
 	req.qhdr = cpu_to_le64(NX_HOST_REQUEST << 23);
 
-- 
1.7.3.3

