From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 3/4] net: sched: remove tc_can_offload check from egdev call
Date: Wed, 25 Oct 2017 16:34:59 +0200
Message-ID: <20171025143500.28973-4-jiri@resnulli.us>
References: <20171025143500.28973-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        mlxsw@mellanox.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        michael.chan@broadcom.com, ganeshgr@chelsio.com,
        jeffrey.t.kirsher@intel.com, saeedm@mellanox.com,
        matanb@mellanox.com, leonro@mellanox.com, idosch@mellanox.com,
        jakub.kicinski@netronome.com, simon.horman@netronome.com,
        pieter.jansenvanvuuren@netronome.com, john.hurley@netronome.com,
        alexander.h.duyck@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:45266 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932184AbdJYOfE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2017 10:35:04 -0400
Received: by mail-wm0-f66.google.com with SMTP id q124so2342357wmb.0
        for <netdev@vger.kernel.org>; Wed, 25 Oct 2017 07:35:03 -0700 (PDT)
In-Reply-To: <20171025143500.28973-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Since the only user, mlx5 driver does the check in
mlx5e_setup_tc_block_cb, no need to check here.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 net/sched/cls_api.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 0636c19..81e1eb3 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -1194,7 +1194,7 @@ static int tc_exts_setup_cb_egdev_call(struct tcf_exts *exts,
 		if (!a->ops->get_dev)
 			continue;
 		dev = a->ops->get_dev(a);
-		if (!dev || !tc_can_offload(dev))
+		if (!dev)
 			continue;
 		ret = tc_setup_cb_egdev_call(dev, type, type_data, err_stop);
 		if (ret < 0)
-- 
2.9.5
