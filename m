From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH] [RFC -v3] NET: Implement a standard ndev_printk family
Date: Tue, 12 Jun 2007 11:38:00 -0700
Message-ID: <466EE808.4040000@intel.com>
References: <20070612004009.1545.12076.stgit@localhost.localdomain> <1181667121.6020.56.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, davem@davemloft.net,
	arjan@linux.intel.com, shemminger@linux-foundation.org,
	randy.dunlap@oracle.com
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:5953 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756169AbXFLSiD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Jun 2007 14:38:03 -0400
In-Reply-To: <1181667121.6020.56.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Joe Perches wrote:
> On Mon, 2007-06-11 at 17:40 -0700, Auke Kok wrote:
>> +#define ndev_err(netdev, level, format, arg...) \
>> +	do { \
>> +		struct net_device *__nd = (netdev); \
>> +		if ((__nd)->msg_enable & NETIF_MSG_##level) \
>> +			printk(KERN_ERR "%s: %s: " format, (__nd)->name, \
>> +				(__nd)->dev.parent->bus_id, ## arg); \
>> +	} while (0)
>> +
> 
> I think it's better to remove the macro concatenation/obfuscation
> of the NETIF_MSG_##level argument and simply pass the appropriate
> NETIF_MSG_<type> directly to these ndev_<level> calls.
> 
> It would also simplify the more than 300 calls in drivers/net of
> 
> 	if (netif_msg_<type>(ptr))
> 		printk(foo)
> 
> to
> 
> 	ndev_<level>(netdev, NETIF_MSG_<type>, fmt, args)

I don't see how that really makes it more usable...

Auke
