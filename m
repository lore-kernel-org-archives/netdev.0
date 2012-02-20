From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: build failure after merge of the final tree
 (net-next tree related)
Date: Mon, 20 Feb 2012 00:46:31 -0500 (EST)
Message-ID: <20120220.004631.1816710786293972830.davem@davemloft.net>
References: <20120220161545.0078a76d8050c56955427455@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, danny.kukawka@bisect.de
To: sfr@canb.auug.org.au
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120220161545.0078a76d8050c56955427455@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Mon, 20 Feb 2012 16:15:45 +1100

> Hi all,
> 
> After merging the final tree, today's linux-next build (powerpc
> allyesconfig) failed like this:
> 
> drivers/net/ethernet/xilinx/ll_temac_main.c: In function 'temac_set_mac_address':
> drivers/net/ethernet/xilinx/ll_temac_main.c:332:3: error: 'dev' undeclared (first use in this function)
> 
> Caused by commit 5a5e7c364486 ("xilinx ll_temac: use eth_hw_addr_random()
> instead of random_ether_addr()").
> 
> I have reverted that commit for today.

I've fixed it as follows:

--------------------
ll_temac: Fix build.

Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/ethernet/xilinx/ll_temac_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/xilinx/ll_temac_main.c b/drivers/net/ethernet/xilinx/ll_temac_main.c
index eb28541..d21591a 100644
--- a/drivers/net/ethernet/xilinx/ll_temac_main.c
+++ b/drivers/net/ethernet/xilinx/ll_temac_main.c
@@ -329,7 +329,7 @@ static int temac_set_mac_address(struct net_device *ndev, void *address)
 	if (!is_valid_ether_addr(ndev->dev_addr))
 		eth_hw_addr_random(ndev);
 	else
-		dev->addr_assign_type &= ~NET_ADDR_RANDOM;
+		ndev->addr_assign_type &= ~NET_ADDR_RANDOM;
 
 	/* set up unicast MAC address filter set its mac address */
 	mutex_lock(&lp->indirect_mutex);
-- 
1.7.7.6
