From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH net-next v2 1/3] macvlan: don't update the uc and vlan
 list for L2 forwarding offload
Date: Fri, 6 Jun 2014 11:45:56 +0800
Message-ID: <53913974.3080006@huawei.com>
References: <1401969663-4464-1-git-send-email-dingtianhong@huawei.com> <1401969663-4464-2-git-send-email-dingtianhong@huawei.com> <53908814.8080303@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Vlad Yasevich <vyasevich@gmail.com>, <kaber@trash.net>,
	<davem@davemloft.net>, <edumazet@google.com>,
	<vyasevic@redhat.com>, <makita.toshiaki@lab.ntt.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:55367 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751774AbaFFDsP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2014 23:48:15 -0400
In-Reply-To: <53908814.8080303@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/6/5 23:09, Vlad Yasevich wrote:
> On 06/05/2014 08:01 AM, Ding Tianhong wrote:
>> If lowerdev supports L2 forwarding offload, no need to set mac address
>> to uc list and vlan list, so also don't do that when the macvlan mac address
>> changes.
> 
> Same issue as in v1.  Please explain how this actually works, since the
> new address never makes it to the hw.
> 

Hi, vlad:

The fwd only support 82599 nic, and when fwd_priv is true, this means the lowerdev support L2 forwarding offload, and will set the macvlan
to the ixgbe_fwd_adapter->netdev, and then it is clear that the lowerdev could know that the the upper device is macvlan and could handle
the skb to the upperdev.

If I miss something, please remind me, thanks.

Ding

> -vlad
>>
>> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
>> ---
>>  drivers/net/macvlan.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
>> index 453d55a..c3a54a6 100644
>> --- a/drivers/net/macvlan.c
>> +++ b/drivers/net/macvlan.c
>> @@ -515,7 +515,7 @@ static int macvlan_sync_address(struct net_device *dev, unsigned char *addr)
>>  	struct net_device *lowerdev = vlan->lowerdev;
>>  	int err;
>>  
>> -	if (!(dev->flags & IFF_UP)) {
>> +	if (!(dev->flags & IFF_UP) || vlan->fwd_priv) {
>>  		/* Just copy in the new address */
>>  		ether_addr_copy(dev->dev_addr, addr);
>>  	} else {
>>
> 
> 
> 
