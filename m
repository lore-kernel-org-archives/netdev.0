From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [PATCH 3/3] NET: [CORE] Stack changes to add multiqueue hardware support API
Date: Mon, 18 Jun 2007 13:26:02 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC329030D596A@orsmsx414.amr.corp.intel.com>
References: <4676D891.7080107@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>, <jeff@garzik.org>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>, <hadi@cyberus.ca>
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:45490 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762295AbXFRU0E convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jun 2007 16:26:04 -0400
Content-class: urn:content-classes:message
In-Reply-To: <4676D891.7080107@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> PJ Waskiewicz wrote:
> > Add the multiqueue hardware device support API to the core network 
> > stack.  Allow drivers to allocate multiple queues and 
> manage them at 
> > the netdev level if they choose to do so.
> >   
> 
> Should be 2/3 and qdisc changes should be 3/3. Well actually 
> the qdisc sch_generic changes belong in this patch as well 
> and the qdisc changes should be split in one change per qdisc.

I'll re-arrange the patches.

> >  /* Functions used for multicast support */ diff --git 
> > a/include/linux/skbuff.h b/include/linux/skbuff.h index 
> > e7367c7..8bcd870 100644
> > --- a/include/linux/skbuff.h
> > +++ b/include/linux/skbuff.h
> > @@ -215,6 +215,7 @@ typedef unsigned char *sk_buff_data_t;
> >   *	@pkt_type: Packet class
> >   *	@fclone: skbuff clone status
> >   *	@ip_summed: Driver fed us an IP checksum
> > + *	@queue_mapping: Queue mapping for multiqueue devices
> >   *	@priority: Packet queueing priority
> >   *	@users: User count - see {datagram,tcp}.c
> >   *	@protocol: Packet protocol from driver
> > @@ -269,6 +270,7 @@ struct sk_buff {
> >  			__u16	csum_offset;
> >  		};
> >  	};
> > +	__u16			queue_mapping;
> >   
> 
> We have a 4 byte hole on 64 bit after iif where this would fit in.

I'll move the variable.  Thanks for this!

> > @@ -3377,12 +3381,23 @@ struct net_device *alloc_netdev(int 
> sizeof_priv, const char *name,
> >  	if (sizeof_priv)
> >  		dev->priv = netdev_priv(dev);
> >  
> > +  	alloc_size = (sizeof(struct net_device_subqueue) * queue_count);
> > +  
> > +  	p = kzalloc(alloc_size, GFP_KERNEL);
> > +  	if (!p) {
> > +  		printk(KERN_ERR "alloc_netdev: Unable to 
> allocate queues.\n");
> > +  		return NULL;
> >   
> 
> Same leak here that you already fixed a couple of posts ago.

Heavy sigh...I synced off an older personal git repository.  I'll clean
this and the casts up and repost with the other feedback.

Thanks Patrick,

-PJ Waskiewicz
