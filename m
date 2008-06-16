From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: Re: [PATCH 3/3] netdevice: order of synchronization of IFF_PROMISC
 and IFF_ALLMULTI
Date: Mon, 16 Jun 2008 17:39:29 +0800
Message-ID: <485634D1.2010603@cn.fujitsu.com>
References: <48562F9A.5030509@cn.fujitsu.com> <485631FF.7040509@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:50527 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752766AbYFPJnP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Jun 2008 05:43:15 -0400
In-Reply-To: <485631FF.7040509@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy said the following on 2008-6-16 17:27:
> Wang Chen wrote:
>> IFF_PROMISC should be set before IFF_ALLMULTI.
>>
>> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
>> ---
>>  net/8021q/vlan_dev.c |   25 +++++++++++++++++++------
>>  1 files changed, 19 insertions(+), 6 deletions(-)
>>
>> diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
>> index 5d055c2..14742e3 100644
>> --- a/net/8021q/vlan_dev.c
>> +++ b/net/8021q/vlan_dev.c
>> @@ -547,10 +547,14 @@ static int vlan_dev_open(struct net_device *dev)
>>      }
>>      memcpy(vlan->real_dev_addr, real_dev->dev_addr, ETH_ALEN);
>>  
>> -    if (dev->flags & IFF_ALLMULTI)
>> -        dev_set_allmulti(real_dev, 1);
>> +    /* NOTE: order of synchronization of IFF_PROMISC and IFF_ALLMULTI
>> +       is important. Some (broken) drivers set IFF_PROMISC, when
>> +       IFF_ALLMULTI is requested not asking us and not reporting.
>> +     */
>>      if (dev->flags & IFF_PROMISC)
>>          dev_set_promiscuity(real_dev, 1);
>> +    if (dev->flags & IFF_ALLMULTI)
>> +        dev_set_allmulti(real_dev, 1);
> 
> 
> What exactly is the problem here? The VLAN code is obviously not
> one of the broken drivers, so why should it care what other drivers
> do?
> 

I think the problem is that allmulti is not valid if promis is not on.

And about the comment, I copy it from dev_change_flags() and think
it seems suit for here.
Did I misunderstand this comment?

