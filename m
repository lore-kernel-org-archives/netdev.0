From: "Lino Sanfilippo" <LinoSanfilippo@gmx.de>
Subject: BUG: Wrong dma queue handling in ixp4 driver
Date: Tue, 19 Jul 2016 13:05:58 +0200
Message-ID: <trinity-275fae16-c9c8-4503-85fe-5585fb014c7a-1468926357992@3capp-gmx-bs21>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: khalasa@piap.pl
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hi,

maybe I miss something, but the ixp4 ethernet driver seems to handle dma pools 
in a wrong way: In init_queues() it creates a dma pool for descriptors and then
 only allocates a single descriptor from this pool. The author seems to assume the whole
table has been allocated already, since after that the complete pool size is zeroed:

<snip> 
static int init_queues(struct port *port)
{
	int i;

	if (!ports_open) {
		dma_pool = dma_pool_create(DRV_NAME, &port->netdev->dev,
					   POOL_ALLOC_SIZE, 32, 0);
		if (!dma_pool)
			return -ENOMEM;
	}

	if (!(port->desc_tab = dma_pool_alloc(dma_pool, GFP_KERNEL,
					      &port->desc_tab_phys)))
		return -ENOMEM;
	memset(port->desc_tab, 0, POOL_ALLOC_SIZE);
<snap>

Regards,
Lino
