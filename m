From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 12/16] hns3pf: don't check handle during mqprio offload
Date: Mon,  7 Aug 2017 10:15:28 +0200
Message-ID: <20170807081532.32760-13-jiri@resnulli.us>
References: <20170807081532.32760-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        daniel@iogearbox.net, mlxsw@mellanox.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        simon.horman@netronome.com, pieter.jansenvanvuuren@netronome.com,
        dirk.vandermerwe@netronome.com, alexander.h.duyck@intel.com,
        amritha.nambiar@intel.com, oss-drivers@netronome.com,
        yisen.zhuang@huawei.com, salil.mehta@huawei.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:34018 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752510AbdHGIPy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2017 04:15:54 -0400
Received: by mail-wr0-f194.google.com with SMTP id o33so7139270wrb.1
        for <netdev@vger.kernel.org>; Mon, 07 Aug 2017 01:15:53 -0700 (PDT)
In-Reply-To: <20170807081532.32760-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Similar to the rest offloaders of mqprio, no need to check handle.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c
index 6bb1e35..ef57959 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c
@@ -1223,7 +1223,7 @@ static int hns3_nic_setup_tc(struct net_device *dev, enum tc_setup_type type,
 			     u32 handle, u32 chain_index, __be16 protocol,
 			     struct tc_to_netdev *tc)
 {
-	if (handle != TC_H_ROOT || type != TC_SETUP_MQPRIO)
+	if (type != TC_SETUP_MQPRIO)
 		return -EINVAL;
 
 	return hns3_setup_tc(dev, tc->mqprio->num_tc);
-- 
2.9.3
