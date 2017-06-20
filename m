From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net] sfc: remove duplicate up_write on VF filter_sem
Date: Tue, 20 Jun 2017 13:08:51 +0100
Message-ID: <b718af2e-5737-3d98-0f45-cfbb25d43349@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: <linux-net-drivers@solarflare.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dispatch1-us1.ppe-hosted.com ([67.231.154.164]:38417 "EHLO
        dispatch1-us1.ppe-hosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751133AbdFTMJD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Jun 2017 08:09:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Somehow two copies of the line 'up_write(&vf->efx->filter_sem);' got into
 efx_ef10_sriov_set_vf_vlan().  This would put the mutex in a bad state and
 cause all subsequent down attempts to hang.

Fixes: 671b53eec2ed ("sfc: Ensure down_write(&filter_sem) and up_write() are matched before calling efx_net_open()")
Signed-off-by: Edward Cree <ecree@solarflare.com>
---
This should probably go to stable kernels as well.

 drivers/net/ethernet/sfc/ef10_sriov.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10_sriov.c b/drivers/net/ethernet/sfc/ef10_sriov.c
index b7e4345..019cef1 100644
--- a/drivers/net/ethernet/sfc/ef10_sriov.c
+++ b/drivers/net/ethernet/sfc/ef10_sriov.c
@@ -661,8 +661,6 @@ int efx_ef10_sriov_set_vf_vlan(struct efx_nic *efx, int vf_i, u16 vlan,
 		up_write(&vf->efx->filter_sem);
 		mutex_unlock(&vf->efx->mac_lock);
 
-		up_write(&vf->efx->filter_sem);
-
 		rc2 = efx_net_open(vf->efx->net_dev);
 		if (rc2)
 			goto reset_nic;
