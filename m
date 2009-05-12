From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [PowerPC] Next May 8 boot failure: OOPS during ibmveth
 moduleinit
Date: Tue, 12 May 2009 17:44:51 +1000
Message-ID: <20090512174451.eeed4126.sfr@canb.auug.org.au>
References: <20090508180251.f53f204e.sfr@canb.auug.org.au>
	<4A042B20.4090903@in.ibm.com>
	<20090508.125722.54378771.davem@davemloft.net>
	<20090508223332.GA4881@psychotron.englab.brq.redhat.com>
	<4A085B3D.5000806@in.ibm.com>
	<20090512170458.39c4ffb7.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Sachin Sant <sachinp@in.ibm.com>, Jiri Pirko <jpirko@redhat.com>,
	linux-next@vger.kernel.org, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20090512170458.39c4ffb7.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

This fixes it (I wonder if this bug is lurking in any other drivers):

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Tue, 12 May 2009 17:24:02 +1000
Subject: [PATCH] net/ibmveth: fix panic in probe

netdev->dev_addr changed from being an array to being a pointer, so we
should not take its address for memcpy().

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 drivers/net/ibmveth.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ibmveth.c b/drivers/net/ibmveth.c
index 7902e5e..8daffad 100644
--- a/drivers/net/ibmveth.c
+++ b/drivers/net/ibmveth.c
@@ -1285,7 +1285,7 @@ static int __devinit ibmveth_probe(struct vio_dev *dev, const struct vio_device_
  	netdev->features |= NETIF_F_LLTX;
 	spin_lock_init(&adapter->stats_lock);
 
-	memcpy(&netdev->dev_addr, &adapter->mac_addr, netdev->addr_len);
+	memcpy(netdev->dev_addr, &adapter->mac_addr, netdev->addr_len);
 
 	for(i = 0; i<IbmVethNumBufferPools; i++) {
 		struct kobject *kobj = &adapter->rx_buff_pool[i].kobj;
-- 
1.6.3


-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/
