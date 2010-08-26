From: Ben Greear <greearb@candelatech.com>
Subject: Re: [net-next] ipv6: Enable netlink notification for tentative addresses.
Date: Thu, 26 Aug 2010 14:22:31 -0700
Message-ID: <4C76DB17.8080601@candelatech.com>
References: <1282760777-15381-1-git-send-email-greearb@candelatech.com> <20100825.212456.71107442.davem@davemloft.net> <4C76B770.4030800@candelatech.com> <4C76C73F.4080206@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:59008 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752828Ab0HZVWe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Aug 2010 17:22:34 -0400
In-Reply-To: <4C76C73F.4080206@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/26/2010 12:57 PM, Brian Haley wrote:
> On 08/26/2010 02:50 PM, Ben Greear wrote:

>> @@ -697,9 +698,10 @@ ipv6_add_addr(struct inet6_dev *idev, const struct
>> in6_addr *addr, int pfxlen,
>>   out2:
>>          rcu_read_unlock_bh();
>>
>> -       if (likely(err == 0))
>> +       if (likely(err == 0)) {
>>                  atomic_notifier_call_chain(&inet6addr_chain, NETDEV_UP,
>> ifa);
>> -       else {
>> +               inet6_ifa_notify(RTM_NEWADDR, ifa);
>> +       } else {
>>                  kfree(ifa);
>>                  ifa = ERR_PTR(err);
>>          }
>
> This will generate two messages in some cases, for example, when lo is
> configured, or a SIT tunnel is added, see add_addr() in addrconf.c.

Would that cause any problem though?  It seems a common pattern to
send 'new-foo' netlink messages when some value in foo changes.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

