From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] qlcnic: fix a loop exit condition better
Date: Thu, 24 Dec 2015 12:21:22 +0300
Message-ID: <20151224092122.GG29642@mwanda>
References: <20151215201734.GJ5177@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, manish.chopra@qlogic.com,
	kernel-janitors@vger.kernel.org
To: Dept-GELinuxNICDev@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:17161 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754103AbbLXJVb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Dec 2015 04:21:31 -0500
Content-Disposition: inline
In-Reply-To: <20151215201734.GJ5177@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the original code, if we succeeded on the last iteration through the
loop then we still returned failure.

Fixes: 389e4e04ad2d ('qlcnic: fix a timeout loop')
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_vnic.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_vnic.c
index b1a452f..3490675 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_vnic.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_vnic.c
@@ -252,7 +252,7 @@ int qlcnic_83xx_check_vnic_state(struct qlcnic_adapter *adapter)
 		state = QLCRDX(ahw, QLC_83XX_VNIC_STATE);
 	}
 
-	if (!idc->vnic_wait_limit) {
+	if (state != QLCNIC_DEV_NPAR_OPER) {
 		dev_err(&adapter->pdev->dev,
 			"vNIC mode not operational, state check timed out.\n");
 		return -EIO;
