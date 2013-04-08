From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: add checks if dev->netdev_ops is NULL in
 register_netdevice()
Date: Mon, 08 Apr 2013 11:34:42 -0400 (EDT)
Message-ID: <20130408.113442.1325175593182860872.davem@davemloft.net>
References: <51629159.9040000@huawei.com>
	<1365434194.3887.13.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dingtianhong@huawei.com, edumazet@google.com,
	alexander.h.duyck@intel.com, netdev@vger.kernel.org,
	lizefan@huawei.com, huxinwei@huawei.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48616 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936306Ab3DHPeq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Apr 2013 11:34:46 -0400
In-Reply-To: <1365434194.3887.13.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 08 Apr 2013 08:16:34 -0700

> On Mon, 2013-04-08 at 17:43 +0800, dingtianhong wrote:
>> In some cases netdev->netdev_ops could be NULL in the register_netdevice(),
>> thus a NULL point deference happens and lead to oops:
> 
>>  	/* Init, if this function is available */
>> -	if (dev->netdev_ops->ndo_init) {
>> +	if (dev->netdev_ops && dev->netdev_ops->ndo_init) {
>>  		ret = dev->netdev_ops->ndo_init(dev);
>>  		if (ret) {
>>  			if (ret > 0)
>> -- 1.8.0
>> 
> 
> Seriously ?
> 
> This patch is not needed, and not complete anyway.
> 
> Fix the driver instead, we don't want this to happen.

Agreed, I'm not seriously considering patches like this at all.
