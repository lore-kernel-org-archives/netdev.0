From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH net-next V1 1/3] net: Add max rate tx queue attribute
Date: Sun, 15 Mar 2015 09:41:54 +0200
Message-ID: <550537C2.3080107@mellanox.com>
References: <1426150405-7904-1-git-send-email-ogerlitz@mellanox.com>
	<1426150405-7904-2-git-send-email-ogerlitz@mellanox.com>
 <20150315.010727.1396856705582316764.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <john.r.fastabend@intel.com>, <netdev@vger.kernel.org>,
	<amirv@mellanox.com>, <idos@mellanox.com>, <matanb@mellanox.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db3on0065.outbound.protection.outlook.com ([157.55.234.65]:35520
	"EHLO emea01-db3-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751180AbbCOHmc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 15 Mar 2015 03:42:32 -0400
In-Reply-To: <20150315.010727.1396856705582316764.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/15/2015 7:07 AM, David Miller wrote:
> From: Or Gerlitz <ogerlitz@mellanox.com>
> Date: Thu, 12 Mar 2015 10:53:23 +0200
>
>> +	if (dev->netdev_ops->ndo_set_tx_maxrate) {
>> +		err = dev->netdev_ops->ndo_set_tx_maxrate(dev, index, rate);
>> +	} else {
>> +		rtnl_unlock();
>> +		return -EOPNOTSUPP;
>> +	}
>> +
>> +	rtnl_unlock();
>> +	if (!err) {
>> +		queue->tx_maxrate = rate;
>> +		return len;
>> +	}
> This is more succinctly expressed as:
>
> 	err = -EOPNOTSUPP;
> 	if (dev->netdev_ops->ndo_set_tx_maxrate) {
> 		err = dev->netdev_ops->ndo_set_tx_maxrate(dev, index, rate);
> 	if (!err) {
> 		queue->tx_maxrate = rate;
> 		return len;
> 	}
> 	return err;
>

sure, I'll fix that.
