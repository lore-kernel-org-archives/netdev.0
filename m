From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH 1/2] [RFC] NET: Implement a standard ndev_printk family
Date: Mon, 11 Jun 2007 13:28:23 -0700
Message-ID: <466DB067.5040109@intel.com>
References: <20070608220007.31573.14931.stgit@localhost.localdomain>	 <20070608162415.1481dfec@localhost.localdomain>	 <4669E967.5030708@intel.com>	 <20070608171040.2b4a2dd7@localhost.localdomain>	 <466D86B2.8070504@intel.com>	 <20070611105018.1beaa396@localhost.localdomain> <1181586492.9836.12.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org, jeff@garzik.org, davem@davemloft.net,
	arjan@linux.intel.com
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:6003 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752201AbXFKU2w (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jun 2007 16:28:52 -0400
In-Reply-To: <1181586492.9836.12.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Joe Perches wrote:
> I like the ndev_printk idea.
> 
> I think a ndev_<level> printks should take a const netdev*
> as the first argument.
> 
> Also, better for the non-debug use of ndev_dbg is to have a
> static inline function so printf args are verified.
> 
> For instance, dev_dbg does:
> 
> static inline int __attribute__ ((format (printf, 2, 3)))
> dev_dbg(struct device * dev, const char * fmt, ...)
> {
>         return 0;
> }
> 
> Perhaps ndev_dbg should look like this:
> 
> static inline int __attribute ((format (printf, 3, 4)))
> __ndev_dbg(const struct net_device *netdev, u32 level, const char *format, ...)
> {
> 	return 0;
> }
> 
> #define ndev_dbg(netdev, level, fmt, args...) \
> 	__ndev_dbg(netdev, NETIF_MSG_##level, fmt, ##args)
> 

I'll take both of these comments into consideration and post a new version in a 
bit...

Thanks.

Auke
