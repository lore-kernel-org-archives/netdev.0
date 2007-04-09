From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [PATCH 2/2] NET: Multiqueue network device support.
Date: Mon, 9 Apr 2007 13:43:11 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC329029E3EE5@orsmsx414.amr.corp.intel.com>
References: <20070409.133753.108740229.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<jgarzik@pobox.com>, "cramerj" <cramerj@intel.com>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	"Leech, Christopher" <christopher.leech@intel.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:48893 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965583AbXDIUnN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Apr 2007 16:43:13 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20070409.133753.108740229.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net] 
> Sent: Monday, April 09, 2007 1:38 PM
> To: Waskiewicz Jr, Peter P
> Cc: netdev@vger.kernel.org; linux-kernel@vger.kernel.org; 
> jgarzik@pobox.com; cramerj; Kok, Auke-jan H; Leech, Christopher
> Subject: Re: [PATCH 2/2] NET: Multiqueue network device support.
> 
> From: Peter P.Waskiewicz Jr. <peter.p.waskiewicz.jr@intel.com>
> Date: Mon, 09 Apr 2007 13:50:52 -0700
> 
> > From: Peter P. Waskiewicz Jr. <peter.p.waskiewicz.jr@intel.com>
> > 
> > Added an API and associated supporting routines for 
> multiqueue network devices.
> > This allows network devices supporting multiple TX queues 
> to configure 
> > each queue within the netdevice and manage each queue 
> independantly.  
> > Changes to the PRIO Qdisc also allow a user to map multiple 
> flows to 
> > individual TX queues, taking advantage of each queue on the device.
> > 
> > Signed-off-by: Peter P. Waskiewicz Jr 
> > <peter.p.waskiewicz.jr@intel.com>
> > Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> 
> This looks definitely better than the previous 
> implementation, myself and others will review this in more 
> depth though.
> 
> > + 	alloc_size = (sizeof(struct net_device_subqueue) * queue_count);
> > + 
> > + 	p = kzalloc(alloc_size, GFP_KERNEL);
> > + 	if (!p) {
> > + 		printk(KERN_ERR "alloc_netdev: Unable to 
> allocate queues.\n");
> > + 		return NULL;
> > + 	}
> > + 
> > + 	dev->egress_subqueue = (struct net_device_subqueue *)p;
> 
> No need for a cast, 'p' is "void *".

True, but the assignment for "dev" above also casts this void * to
struct net_device *:

        dev = (struct net_device *)
                (((long)p + NETDEV_ALIGN_CONST) & ~NETDEV_ALIGN_CONST);
        dev->padded = (char *)dev - (char *)p;

Shall I remove my cast?

Thanks for the feedback,

-PJ Waskiewicz
