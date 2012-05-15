From: Manish Chopra <manish.chopra@qlogic.com>
Subject: [PATCH NEXT 2/2] qlcnic-ethtool: set the ethtool_dump flag by ETH_FW_DUMP_DISABLE value that is zero, if firmware dump is disabled.
Date: Tue, 15 May 2012 07:13:39 -0400
Message-ID: <1337080419-31786-3-git-send-email-manish.chopra@qlogic.com>
References: <1337080419-31786-1-git-send-email-manish.chopra@qlogic.com>
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Dept_NX_Linux_NIC_Driver@qlogic.com,
	anirban.chakraborty@qlogic.com,
	Manish chopra <manish.chopra@qlogic.com>
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:43781 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1757843Ab2EOLh2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 May 2012 07:37:28 -0400
In-Reply-To: <1337080419-31786-1-git-send-email-manish.chopra@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Manish chopra <manish.chopra@qlogic.com>

Signed-off-by: Manish chopra <manish.chopra@qlogic.com>
---
 .../net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c    |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
index 735423f..9e9e78a 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
@@ -1232,7 +1232,12 @@ qlcnic_get_dump_flag(struct net_device *netdev, struct ethtool_dump *dump)
 		dump->len = fw_dump->tmpl_hdr->size + fw_dump->size;
 	else
 		dump->len = 0;
-	dump->flag = fw_dump->tmpl_hdr->drv_cap_mask;
+
+	if (!fw_dump->enable)
+		dump->flag = ETH_FW_DUMP_DISABLE;
+	else
+		dump->flag = fw_dump->tmpl_hdr->drv_cap_mask;
+
 	dump->version = adapter->fw_version;
 	return 0;
 }
-- 
1.7.1
