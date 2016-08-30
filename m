From: Bhaktipriya Shridhar <bhaktipriya96@gmail.com>
Subject: [PATCH] bonding: Remove deprecated create_singlethread_workqueue
Date: Tue, 30 Aug 2016 22:02:01 +0530
Message-ID: <20160830163201.GA25869@Karyakshetra>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tejun Heo <tj@kernel.org>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Jay Vosburgh <j.vosburgh@gmail.com>,
        Veaceslav Falico <vfalico@gmail.com>,
        Andy Gospodarek <gospo@cumulusnetworks.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

alloc_ordered_workqueue() with WQ_MEM_RECLAIM set, replaces
deprecated create_singlethread_workqueue(). This is the identity
conversion.

The workqueue "wq" queues multiple work items viz
&bond->mcast_work, &nnw->work, &bond->mii_work, &bond->arp_work,
&bond->alb_work, &bond->mii_work, &bond->ad_work, &bond->slave_arr_work
which require strict execution ordering. Hence, an ordered dedicated
workqueue has been used.

Since, it is a network driver, WQ_MEM_RECLAIM has been set to
ensure forward progress under memory pressure.

Signed-off-by: Bhaktipriya Shridhar <bhaktipriya96@gmail.com>
---
 drivers/net/bonding/bond_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 941ec99..ebaf1a9 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4635,7 +4635,7 @@ static int bond_init(struct net_device *bond_dev)

 	netdev_dbg(bond_dev, "Begin bond_init\n");

-	bond->wq = create_singlethread_workqueue(bond_dev->name);
+	bond->wq = alloc_ordered_workqueue(bond_dev->name, WQ_MEM_RECLAIM);
 	if (!bond->wq)
 		return -ENOMEM;

--
2.1.4
