From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH 1/2] [RFC] NET: Implement a standard ndev_printk family
Date: Mon, 11 Jun 2007 15:01:59 -0700
Message-ID: <466DC657.2030401@intel.com>
References: <20070611213721.23014.4812.stgit@localhost.localdomain> <1181598880.6020.8.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, davem@davemloft.net,
	arjan@linux.intel.com, shemminger@linux-foundation.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:23329 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751179AbXFKWCg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jun 2007 18:02:36 -0400
In-Reply-To: <1181598880.6020.8.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Joe Perches wrote:
> On Mon, 2007-06-11 at 14:37 -0700, Auke Kok wrote:
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
> 
> msg_enable is more frequently defined in drivers/net as u32 not int.
> 
> egrep -r -w --include=*.[ch] "u32[[:space:]]+msg_enable" drivers/net | wc -l
> egrep -r -w --include=*.[ch] "int[[:space:]]+msg_enable" drivers/net | wc -l
> 
> 29 to 5

yes, we're only using the bottom 15 bits anyway, but the net_device struct 
consistently uses 'int' style members, leaving it up to the compiler to pick an 
appropriate size for each arch. That was the reason I chose int here.

Auke
