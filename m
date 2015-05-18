From: Shradha Shah <sshah@solarflare.com>
Subject: [PATCH net-next 15/16] sfc: Implement dummy disable of VF spoof check
 for EF10
Date: Mon, 18 May 2015 16:31:38 +0100
Message-ID: <555A05DA.9000804@solarflare.com>
References: <555A044A.4060202@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo04.seg.att.com ([209.65.160.86]:47145 "EHLO
	nbfkord-smmo04.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932124AbbERPbv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2015 11:31:51 -0400
In-Reply-To: <555A044A.4060202@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Shradha Shah <sshah@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10_sriov.c | 6 ++++++
 drivers/net/ethernet/sfc/ef10_sriov.h | 7 ++-----
 2 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10_sriov.c b/drivers/net/ethernet/sfc/ef10_sriov.c
index edc34f3..3969b1b 100644
--- a/drivers/net/ethernet/sfc/ef10_sriov.c
+++ b/drivers/net/ethernet/sfc/ef10_sriov.c
@@ -667,6 +667,12 @@ reset_nic:
 	return rc ? rc : rc2;
 }
 
+int efx_ef10_sriov_set_vf_spoofchk(struct efx_nic *efx, int vf_i,
+				   bool spoofchk)
+{
+	return spoofchk ? -EOPNOTSUPP : 0;
+}
+
 int efx_ef10_sriov_set_vf_link_state(struct efx_nic *efx, int vf_i,
 				     int link_state)
 {
diff --git a/drivers/net/ethernet/sfc/ef10_sriov.h b/drivers/net/ethernet/sfc/ef10_sriov.h
index 91393a6..7171029 100644
--- a/drivers/net/ethernet/sfc/ef10_sriov.h
+++ b/drivers/net/ethernet/sfc/ef10_sriov.h
@@ -49,11 +49,8 @@ int efx_ef10_sriov_set_vf_mac(struct efx_nic *efx, int vf, u8 *mac);
 int efx_ef10_sriov_set_vf_vlan(struct efx_nic *efx, int vf_i,
 			       u16 vlan, u8 qos);
 
-static inline int efx_ef10_sriov_set_vf_spoofchk(struct efx_nic *efx, int vf,
-						 bool spoofchk)
-{
-	return -EOPNOTSUPP;
-}
+int efx_ef10_sriov_set_vf_spoofchk(struct efx_nic *efx, int vf,
+				   bool spoofchk);
 
 int efx_ef10_sriov_get_vf_config(struct efx_nic *efx, int vf_i,
 				 struct ifla_vf_info *ivf);
