From: Ursula Braun <ubraun-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH net 1/9] net/smc: add missing dev_put
Date: Thu, 21 Sep 2017 09:16:26 +0200
Message-ID: <20170921071634.16883-2-ubraun@linux.vnet.ibm.com>
References: <20170921071634.16883-1-ubraun@linux.vnet.ibm.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jwi-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org,
        schwidefsky-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org, heiko.carstens-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org,
        raspl-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, ubraun-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170921071634.16883-1-ubraun-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Hans Wippel <hwippel-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>

In the infiniband part, SMC currently uses get_netdev which calls
dev_hold on the returned net device. However, the SMC code never calls
dev_put on that net device resulting in a wrong reference count.

This patch adds a dev_put after the usage of the net device to fix the
issue.

Signed-off-by: Hans Wippel <hwippel-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Signed-off-by: Ursula Braun <ubraun-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 net/smc/smc_ib.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/smc/smc_ib.c b/net/smc/smc_ib.c
index 547e0e113b17..0b5852299158 100644
--- a/net/smc/smc_ib.c
+++ b/net/smc/smc_ib.c
@@ -380,6 +380,7 @@ static int smc_ib_fill_gid_and_mac(struct smc_ib_device *smcibdev, u8 ibport)
 	ndev = smcibdev->ibdev->get_netdev(smcibdev->ibdev, ibport);
 	if (ndev) {
 		memcpy(&smcibdev->mac, ndev->dev_addr, ETH_ALEN);
+		dev_put(ndev);
 	} else if (!rc) {
 		memcpy(&smcibdev->mac[ibport - 1][0],
 		       &smcibdev->gid[ibport - 1].raw[8], 3);
-- 
2.13.5

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
