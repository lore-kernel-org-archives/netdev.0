From: Ben Greear <greearb@candelatech.com>
Subject: Re: [RFC] af-packet: Save reference to bound network device.
Date: Wed, 25 May 2011 15:22:20 -0700
Message-ID: <4DDD811C.5030809@candelatech.com>
References: <1306360602-9672-1-git-send-email-greearb@candelatech.com>	<20110525.180113.1194226831134092545.davem@davemloft.net>	<4DDD7D16.6030907@candelatech.com> <20110525.181418.1100603684033986711.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:57959 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754046Ab1EYWWW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 May 2011 18:22:22 -0400
In-Reply-To: <20110525.181418.1100603684033986711.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/25/2011 03:14 PM, David Miller wrote:
> From: Ben Greear<greearb@candelatech.com>
> Date: Wed, 25 May 2011 15:05:10 -0700
>
>> Doesn't this piece of code take care of that?
>> I tested with rmmod..but of course I could have missed something.
>>
>> @@ -2266,6 +2284,10 @@ static int packet_notifier(struct
>> notifier_block *this, unsigned long msg, void
>>   				}
>>   				if (msg == NETDEV_UNREGISTER) {
>>   					po->ifindex = -1;
>> +					if (po->bound_dev) {
>> + dev_put(po->bound_dev);
>> +						po->bound_dev = NULL;
>> +					}
>>   					po->prot_hook.dev = NULL;
>>   				}
>>   				spin_unlock(&po->bind_lock);
>>
>
> Indeed, it should, thanks for pointing that out.
>
> Wait a second, why do you need to store the device a second
> time, can't you get at po->prot_hook.dev in all the necessary
> spots?

I think so...I'll poke at the code a bit and run some more
tests using that instead...

Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

