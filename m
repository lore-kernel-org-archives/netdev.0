From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next] nfp: inform the VF driver needs to be restarted after changing the MAC
Date: Thu, 26 Oct 2017 17:35:38 -0700
Message-ID: <20171027003538.20314-1-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: oss-drivers@netronome.com,
        =?UTF-8?q?Pablo=20Casc=C3=B3n?= <pablo.cascon@netronome.com>,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:45057 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751651AbdJ0AgA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 20:36:00 -0400
Received: by mail-pg0-f68.google.com with SMTP id b192so3991327pga.2
        for <netdev@vger.kernel.org>; Thu, 26 Oct 2017 17:36:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Cascón <pablo.cascon@netronome.com>

Add message to inform the VF MAC was changed and the need to restart
the VF driver for the changes to be effective.

Signed-off-by: Pablo Cascón <pablo.cascon@netronome.com>
Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net_sriov.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_sriov.c b/drivers/net/ethernet/netronome/nfp/nfp_net_sriov.c
index e6d2e06b050c..8b1b962cf1d1 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_sriov.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_sriov.c
@@ -112,7 +112,13 @@ int nfp_app_set_vf_mac(struct net_device *netdev, int vf, u8 *mac)
 	writew(get_unaligned_be16(mac + 4),
 	       app->pf->vfcfg_tbl2 + vf_offset + NFP_NET_VF_CFG_MAC_LO);
 
-	return nfp_net_sriov_update(app, vf, NFP_NET_VF_CFG_MB_UPD_MAC, "MAC");
+	err = nfp_net_sriov_update(app, vf, NFP_NET_VF_CFG_MB_UPD_MAC, "MAC");
+	if (!err)
+		nfp_info(app->pf->cpp,
+			 "MAC %pM set on VF %d, reload the VF driver to make this change effective.\n",
+			 mac, vf);
+
+	return err;
 }
 
 int nfp_app_set_vf_vlan(struct net_device *netdev, int vf, u16 vlan, u8 qos,
-- 
2.14.1
