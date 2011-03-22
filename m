From: Brian Haley <brian.haley@hp.com>
Subject: Re: ipv6 secondary ips and default ipv6 ip for new outbound	connections
Date: Mon, 21 Mar 2011 22:14:39 -0400
Message-ID: <4D88060F.2030805@hp.com>
References: <20110318230312.GX13831@surrealistic.net> <4D8413BE.5000305@hp.com> <20110319033507.GY13831@surrealistic.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Jim Westfall <jwestfall@surrealistic.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0027.austin.hp.com ([15.216.28.34]:36242 "EHLO
	g1t0027.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754841Ab1CVCOm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Mar 2011 22:14:42 -0400
In-Reply-To: <20110319033507.GY13831@surrealistic.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/18/2011 11:35 PM, Jim Westfall wrote:
> Brian Haley <brian.haley@hp.com> wrote [03.18.11]:
>> On 03/18/2011 07:03 PM, Jim Westfall wrote:
>>> Hi
>>>
>>> On ipv4 the first ip added to a nic will be used as the source ip for 
>>> new outbound connections.  Any additional ips, in the same netblock, 
>>> will be added as secondaries.
>>>
>>> ipv6 seems to have the opposite behavior.  The last ipv6 ip added to a 
>>> nic is be used for new outbound connections.

<snip>

>> According to commit 8a6ce0c083f5736e90dabe6d8ce077e7dd0fa35f it's done this
>> way for backward-compatibility - we used to always put new addresses at the
>> front, then we started sorting them by scope.  I couldn't find in the archives
>> who needed the backward-compatible behavior (it was way back in 2006), but
>> Yoshifuji proposed it and I Acked it.
>>
>> You could see if this patch helps you out, but I'm not sure if changing this
>> would break someone else, you'd have to see about putting a knob to control
>> this.
>>
>> -Brian
>>
>> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
>> index 3daaf3c..8c7d5a5 100644
>> --- a/net/ipv6/addrconf.c
>> +++ b/net/ipv6/addrconf.c
>> @@ -577,7 +577,7 @@ ipv6_link_dev_addr(struct inet6_dev *idev, struct inet6_ifaddr *ifp)
>>  	list_for_each(p, &idev->addr_list) {
>>  		struct inet6_ifaddr *ifa
>>  			= list_entry(p, struct inet6_ifaddr, if_list);
>> -		if (ifp_scope >= ipv6_addr_src_scope(&ifa->addr))
>> +		if (ifp_scope > ipv6_addr_src_scope(&ifa->addr))
>>  			break;
>>  	}
>>  
> 
> Hi
> 
> Your patch fixes it for me.

Then we need to get Yoshifuji to Ack it since he wanted the previous behavior of
newest-added being first.

-Brian
