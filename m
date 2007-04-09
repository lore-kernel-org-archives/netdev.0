From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] NET: Multiqueue network device support.
Date: Mon, 09 Apr 2007 13:37:53 -0700 (PDT)
Message-ID: <20070409.133753.108740229.davem@davemloft.net>
References: <20070409204908.31370.9954.stgit@gitlost.site>
	<20070409205052.31370.97137.stgit@gitlost.site>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jgarzik@pobox.com, cramerj@intel.com, auke-jan.h.kok@intel.com,
	christopher.leech@intel.com
To: peter.p.waskiewicz.jr@intel.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S965522AbXDIUhy@vger.kernel.org>
In-Reply-To: <20070409205052.31370.97137.stgit@gitlost.site>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Peter P.Waskiewicz Jr. <peter.p.waskiewicz.jr@intel.com>
Date: Mon, 09 Apr 2007 13:50:52 -0700

> From: Peter P. Waskiewicz Jr. <peter.p.waskiewicz.jr@intel.com>
> 
> Added an API and associated supporting routines for multiqueue network devices.
> This allows network devices supporting multiple TX queues to configure each
> queue within the netdevice and manage each queue independantly.  Changes to the
> PRIO Qdisc also allow a user to map multiple flows to individual TX queues,
> taking advantage of each queue on the device.
> 
> Signed-off-by: Peter P. Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>

This looks definitely better than the previous implementation,
myself and others will review this in more depth though.

> + 	alloc_size = (sizeof(struct net_device_subqueue) * queue_count);
> + 
> + 	p = kzalloc(alloc_size, GFP_KERNEL);
> + 	if (!p) {
> + 		printk(KERN_ERR "alloc_netdev: Unable to allocate queues.\n");
> + 		return NULL;
> + 	}
> + 
> + 	dev->egress_subqueue = (struct net_device_subqueue *)p;

No need for a cast, 'p' is "void *".
