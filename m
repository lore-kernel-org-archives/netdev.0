From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [PATCH net-next] hinic: uninitialized variable in
 hinic_api_cmd_init()
Date: Thu, 24 Aug 2017 13:47:39 +0300
Message-ID: <20170824104739.gw422ufydwmiu4gi@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Aviad Krawczyk <aviad.krawczyk@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:34999 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751191AbdHXKr5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Aug 2017 06:47:57 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We never set the error code in this function.

Fixes: eabf0fad81d5 ("net-next/hinic: Initialize api cmd resources")
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/net/ethernet/huawei/hinic/hinic_hw_api_cmd.c b/drivers/net/ethernet/huawei/hinic/hinic_hw_api_cmd.c
index 8901801fe426..c40603a183df 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_hw_api_cmd.c
+++ b/drivers/net/ethernet/huawei/hinic/hinic_hw_api_cmd.c
@@ -941,6 +941,7 @@ int hinic_api_cmd_init(struct hinic_api_cmd_chain **chain,
 		if (IS_ERR(chain[chain_type])) {
 			dev_err(&pdev->dev, "Failed to create chain %d\n",
 				chain_type);
+			err = PTR_ERR(chain[chain_type]);
 			goto err_create_chain;
 		}
 	}
