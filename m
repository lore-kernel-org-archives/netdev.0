From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH net] vlan:make mtu of vlan equal to physical dev
Date: Tue, 18 Oct 2011 19:51:42 -0700
Message-ID: <4E9E3B3E.2070902@candelatech.com>
References: <bc33a6142ce48b71b9c232a9154ed76f6048f0cb.1318068629.git.panweiping3@gmail.com> <4E9E30B8.5030904@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.hengli.com.au,
	"open list:NETWORKING [GENERAL]" <netdev@vger.kernel.org>
To: WeipingPan <panweiping3@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:32932 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752805Ab1JSCvu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2011 22:51:50 -0400
In-Reply-To: <4E9E30B8.5030904@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/18/2011 07:06 PM, WeipingPan wrote:
> Hi, Herbert,
>
> What do you think of this patch ?
>
> thanks
> Weiping Pan
> On 10/08/2011 06:12 PM, Weiping Pan wrote:
>> Default mtu of vlan device is the same with mtu of physical device,
>> for example 1500, but when change physics mtu to 1600,
>> VLAN device's mtu is still 1500.
>> Certainly, you can change vlan device's mtu to 1600 manually,
>> but I think when you change physics device's mtu, VLAN's mtu should be changed
>> automatically instead of by manually.

I don't like the idea.  It's perfectly valid to have the physical dev with 9000 MTU
and have vlans with 1500 MTU.

>> Steps to Reproduce:
>> 1.vconfig add eth4 3
>> 2.ifconfig eth4 mtu 1600
>> 3.check mtu on eth4.3
>>
>> And what's worse is that if you decrease mtu of pyhsical device,
>> and when you want to increase it, the mtu of vlan device won't be changed.

That *might* be worth fixing, but even so, some NICs might handle that
just fine, so my opinion is that this should not change either.

Thanks,
Ben

>>
>> Steps to Reproduce:
>> 1.vconfig add eth4 3
>> 2.ifconfig eth4 mtu 100
>> 3.ifconfig eth4 mtu 1500
>> 4.the mtu of eth4.3 is still 100
>>
>> This bug is reported by Liang Zheng(lzheng@redhat.com).
>>
>> Signed-off-by: Weiping Pan<panweiping3@gmail.com>
>> ---
>> net/8021q/vlan.c | 3 ---
>> 1 files changed, 0 insertions(+), 3 deletions(-)
>>
>> diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
>> index 8970ba1..f6072b4 100644
>> --- a/net/8021q/vlan.c
>> +++ b/net/8021q/vlan.c
>> @@ -417,9 +417,6 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
>> if (!vlandev)
>> continue;
>>
>> - if (vlandev->mtu<= dev->mtu)
>> - continue;
>> -
>> dev_set_mtu(vlandev, dev->mtu);
>> }
>> break;
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at http://vger.kernel.org/majordomo-info.html


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
