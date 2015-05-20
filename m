From: Shradha Shah <sshah@solarflare.com>
Subject: [PATCH net-next v3 15/16] sfc: Implement dummy disable of VF spoof
 check for EF10
Date: Wed, 20 May 2015 11:12:30 +0100
Message-ID: <555C5E0E.5050308@solarflare.com>
References: <555C5C91.4000004@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo02.seg.att.com ([209.65.160.78]:38898 "EHLO
	nbfkord-smmo02.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753186AbbETKMh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2015 06:12:37 -0400
In-Reply-To: <555C5C91.4000004@solarflare.com>
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
