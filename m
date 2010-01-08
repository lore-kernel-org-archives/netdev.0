From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: Re: [net-next-2.6 PATCH 3/5] ethtool: Introduce n-tuple filter
 programming support
Date: Fri, 8 Jan 2010 00:34:23 -0800 (Pacific Standard Time)
Message-ID: <Pine.WNT.4.64.1001080028250.15300@ppwaskie-MOBL2.amr.corp.intel.com>
References: <20100107044741.28605.31414.stgit@localhost.localdomain>
 <20100107044905.28605.54076.stgit@localhost.localdomain>
 <20100108.002342.144442434.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"deri@ntop.org" <deri@ntop.org>,
	"Gasparakis, Joseph" <joseph.gasparakis@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:3288 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751740Ab0AHIeY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Jan 2010 03:34:24 -0500
In-Reply-To: <20100108.002342.144442434.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 8 Jan 2010, David Miller wrote:

> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: Wed, 06 Jan 2010 20:49:06 -0800
> 
> > @@ -500,6 +529,8 @@ struct ethtool_ops {
> >  	int	(*set_rxnfc)(struct net_device *, struct ethtool_rxnfc *);
> >  	int     (*flash_device)(struct net_device *, struct ethtool_flash *);
> >  	int	(*reset)(struct net_device *, u32 *);
> > +	int	(*set_rx_ntuple)(struct net_device *, struct ethtool_rx_ntuple *);
> > +	int	(*get_rx_ntuple)(struct net_device *, struct ethtool_rx_ntuple *, void *);
> >  };
> >  #endif /* __KERNEL__ */
> >  
> > @@ -559,6 +590,9 @@ struct ethtool_ops {
> >  #define	ETHTOOL_FLASHDEV	0x00000033 /* Flash firmware to device */
> >  #define	ETHTOOL_RESET		0x00000034 /* Reset hardware */
> >  
> > +#define ETHTOOL_SRXNTUPLE	0x00000035 /* Add an n-tuple filter to device */
> > +#define ETHTOOL_GRXNTUPLE	0x00000036 /* Get n-tuple filters from device */
> > +
> 
> Command value ETHTOOL_GRXNTUPLE and the ethtool_ops callback
> ->get_rx_ntuple() for it are declared, but I see no implementation
> added to net/core/ethtool.c

Yes, I left that in there somewhat accidentally.  I had every intention in 
putting a get routine in, but I couldn't come up with a generic way to 
work with most hardware (how to get all filters back and dump them).  The 
82599 needs to query the hardware for each filter currently programmed, 
and I'm not sure what the niu hardware layout is for the filters.

I can remove the get stubs for now, since I have no good solution to dump 
the filters that is generic.

Thanks,
-PJ
