From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [PATCH] NET: Multiqueue network device support.
Date: Mon, 11 Jun 2007 10:57:20 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC3290303AAE8@orsmsx414.amr.corp.intel.com>
References: <466D8BE0.5040708@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>, <jeff@garzik.org>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:65344 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752835AbXFKR5X convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jun 2007 13:57:23 -0400
Content-class: urn:content-classes:message
In-Reply-To: <466D8BE0.5040708@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> PJ Waskiewicz wrote:
> > diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h index 
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
> >  	__u32			priority;
> >  	__u8			local_df:1,
> >  				cloned:1,
> 
> 
> I think we can reuse skb->priority. Assuming only real 
> hardware devices use multiqueue support, there should be no user of
> skb->priority after egress qdisc classification. The only reason
> to preserve it in the qdisc layer is for software devices.

That would be oustanding.

> Grepping through drivers/net shows a few users, bot most seem 
> to be using it on the RX path and some use it to store internal data.

Thank you for hunting this down.  I will test on my little environment
here to see if I run into any issues.

-PJ
