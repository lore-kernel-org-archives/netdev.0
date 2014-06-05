From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH net-next 2/4] net: dev: don't set the same mac address
 for netdev
Date: Thu, 5 Jun 2014 17:50:18 +0800
Message-ID: <53903D5A.7050702@huawei.com>
References: <1401951028-9800-1-git-send-email-dingtianhong@huawei.com> <1401951028-9800-3-git-send-email-dingtianhong@huawei.com> <539033BC.3000703@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>, <kaber@trash.net>,
	<davem@davemloft.net>, <edumazet@google.com>, <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:9138 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750864AbaFEJvR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2014 05:51:17 -0400
In-Reply-To: <539033BC.3000703@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/6/5 17:09, Toshiaki Makita wrote:
> (2014/06/05 15:50), Ding Tianhong wrote:
>> Most of netdev just like bond, team, vlan will set the mac address
>> and propagate to the upperdev or lowerdev regardless the mac address
>> is  same or not, I could not find that the same mac address could
>> make affect, so add equal check when set mac address.
>>
>> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
>> ---
>>  net/core/dev.c | 2 ++
>>  1 file changed, 2 insertions(+)
>>
>> diff --git a/net/core/dev.c b/net/core/dev.c
>> index 5367bfb..4008a51 100644
>> --- a/net/core/dev.c
>> +++ b/net/core/dev.c
>> @@ -5570,6 +5570,8 @@ int dev_set_mac_address(struct net_device *dev, struct sockaddr *sa)
>>  		return -EINVAL;
>>  	if (!netif_device_present(dev))
>>  		return -ENODEV;
>> +	if (ether_addr_equal_64bits(dev->dev_addr, sa->sa_data))
>> +		return 0;
>>  	err = ops->ndo_set_mac_address(dev, sa);
>>  	if (err)
>>  		return err;
>>
> 
> Bridge uses addr_assign_type to check if bridge_id can be propageted by
> bridge ports. If user set mac address, and even if it is the same as
> current one, bridge uses the fact that the mac address is set by user.
> 

OK

> Although I'm not aware of a driver that needs calling of
> ndo_set_mac_address() for the same mac address, this change looks a bit
> risky to me.
> (For example, old bridge code needed this call because it managed
> BR_SET_MAC_ADDR in bridge flags.)
> 
Except the old bridge, I still don't think any other driver need to call ndo_set_mac_address()
for the same mac address, if the dev_set_mac_address() don't do anything for the same address,
I think some drivers should ignore the same mac address themselves just like bonding, macvlan, vlan and so on.

Ding 

> Thanks,
> Toshiaki Makita
> 
