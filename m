From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH 1/2] [RFC] NET: Implement a standard ndev_printk family
Date: Mon, 11 Jun 2007 15:04:02 -0700
Message-ID: <466DC6D2.908@intel.com>
References: <20070611213721.23014.4812.stgit@localhost.localdomain> <20070611150037.34a33f43.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, davem@davemloft.net,
	arjan@linux.intel.com, joe@perches.com,
	shemminger@linux-foundation.org
To: Randy Dunlap <randy.dunlap@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:11717 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753835AbXFKWEZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jun 2007 18:04:25 -0400
In-Reply-To: <20070611150037.34a33f43.randy.dunlap@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Randy Dunlap wrote:
> On Mon, 11 Jun 2007 14:37:21 -0700 Auke Kok wrote:
> 
>>  include/linux/netdevice.h |   38 ++++++++++++++++++++++++++++++++++++++
>>  net/core/dev.c            |    5 +++++
>>  net/core/ethtool.c        |   14 +++++++-------
>>  3 files changed, 50 insertions(+), 7 deletions(-)
>>
>> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
>> index 3a70f55..d185f41 100644
>> --- a/include/linux/netdevice.h
>> +++ b/include/linux/netdevice.h
>> @@ -540,6 +540,8 @@ struct net_device
>>  	struct device		dev;
>>  	/* space for optional statistics and wireless sysfs groups */
>>  	struct attribute_group  *sysfs_groups[3];
>> +
>> +	int			msg_enable;
>>  };
>>  #define to_net_dev(d) container_of(d, struct net_device, dev)
>>  
>> @@ -838,6 +840,42 @@ enum {
>>  	NETIF_MSG_WOL		= 0x4000,
>>  };
>>  
>> +#define ndev_err(netdev, level, format, arg...) \
>> +	do { if ((netdev)->msg_enable & NETIF_MSG_##level) { \
>> +		printk(KERN_ERR "%s: %s: " format, (netdev)->name, \
>> +		(netdev)->dev.parent->bus_id, ## arg); } } while (0)
>> +
> 
> I would still do what Steve H. suggested, i.e., only evaluate
> macro args one time.  E.g. (not tested & reformatted :)
> 
> +#define ndev_err(netdev, level, format, arg...) \
> +	do { \
> +		struct net_device *__nd = netdev; \
> +		if ((__nd)->msg_enable & NETIF_MSG_##level) \
> +			printk(KERN_ERR "%s: %s: " format, (__nd)->name, \
> +				(__nd)->dev.parent->bus_id, ## arg); \
> +	} while (0)
> +
> 
> Dropping the braces around the printk() too.

ahh, *now* I get it... :)

Auke
