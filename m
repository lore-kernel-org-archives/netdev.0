From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net] ethtool: set addr_assign_type to NET_ADDR_SET when
 addr is passed on create
Date: Mon, 7 Jan 2013 18:52:15 +0100
Message-ID: <20130107175215.GD1587@minipsycho.orion>
References: <1357511921-5537-1-git-send-email-jiri@resnulli.us>
 <1357576565.2658.6.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, shemminger@vyatta.com,
	sassmann@redhat.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f43.google.com ([74.125.83.43]:55040 "EHLO
	mail-ee0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754189Ab3AGRwZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jan 2013 12:52:25 -0500
Received: by mail-ee0-f43.google.com with SMTP id e49so9506227eek.2
        for <netdev@vger.kernel.org>; Mon, 07 Jan 2013 09:52:24 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1357576565.2658.6.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Jan 07, 2013 at 05:36:05PM CET, bhutchings@solarflare.com wrote:
>On Sun, 2013-01-06 at 23:38 +0100, Jiri Pirko wrote:
>> In case user passed address via netlink during create, NET_ADDR_PERM was set.
>> That is not correct so fix this by setting NET_ADDR_SET.
>> 
>> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>
>Not sure what this has to do with ethtool...

Should have been "netlink" ...

>
>> ---
>>  net/core/rtnetlink.c | 4 +++-
>>  1 file changed, 3 insertions(+), 1 deletion(-)
>> 
>> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
>> index 9969afb..9a419b0 100644
>> --- a/net/core/rtnetlink.c
>> +++ b/net/core/rtnetlink.c
>> @@ -1667,9 +1667,11 @@ struct net_device *rtnl_create_link(struct net *net,
>>  
>>  	if (tb[IFLA_MTU])
>>  		dev->mtu = nla_get_u32(tb[IFLA_MTU]);
>> -	if (tb[IFLA_ADDRESS])
>> +	if (tb[IFLA_ADDRESS]) {
>>  		memcpy(dev->dev_addr, nla_data(tb[IFLA_ADDRESS]),
>>  				nla_len(tb[IFLA_ADDRESS]));
>> +		dev->addr_assign_type = NET_ADDR_SET;
>> +	}
>>  	if (tb[IFLA_BROADCAST])
>>  		memcpy(dev->broadcast, nla_data(tb[IFLA_BROADCAST]),
>>  				nla_len(tb[IFLA_BROADCAST]));
>
>But if the address is not specified for this new device,
>addr_assign_type remains NET_ADD_PERM, right?  That sort of makes sense
>in that the 'permanent address' of a software device is all-zeroes.  I
>would prefer to have a way for devices to deny having a permanent
>address, but it's a bit late to change that now.

Well if soft-dev uses eth_hw_addr_random() (like team, bridge,
macvlan, etc) it is set to NET_ADDR_RANDOM

And that is exactly the right way to deny having perm address.


>
>Ben.
>
>-- 
>Ben Hutchings, Staff Engineer, Solarflare
>Not speaking for my employer; that's the marketing department's job.
>They asked us to note that Solarflare product names are trademarked.
>
