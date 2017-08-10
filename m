From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [PATCH 1/2 net-next] hns3pf: fix hns3_del_tunnel_port()
Date: Thu, 10 Aug 2017 12:54:59 +0300
Message-ID: <20170810090720.eh4l6gxsubmwqxo6@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Salil Mehta <salil.mehta@huawei.com>,
        "David S. Miller" <davem@davemloft.net>,
        Jiri Pirko <jiri@mellanox.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        lipeng <lipeng321@huawei.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Yisen Zhuang <yisen.zhuang@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This function has a copy and paste bug so it accidentally calls the add
function instead of the delete function.

Fixes: 76ad4f0ee747 ("net: hns3: Add support of HNS3 Ethernet Driver for hip08 SoC")
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c
index 069ae426aa24..e519795dff7c 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c
@@ -1138,7 +1138,7 @@ static void hns3_del_tunnel_port(struct net_device *netdev, u16 port,
 	udp_tnl->dst_port = 0;
 	/* TBD send command to hardware to del port  */
 	if (h->ae_algo->ops->del_tunnel_udp)
-		h->ae_algo->ops->add_tunnel_udp(h, port);
+		h->ae_algo->ops->del_tunnel_udp(h, port);
 }
 
 /* hns3_nic_udp_tunnel_add - Get notifiacetion about UDP tunnel ports
