From: Varun Chandramohan <varunc@linux.vnet.ibm.com>
Subject: Re: [PATCH 4/4] Initialize and fill IPv6 route age
Date: Tue, 24 Jul 2007 09:50:57 +0530
Message-ID: <46A57E29.9040404@linux.vnet.ibm.com>
References: <20070723101318.c773f600.varunc@linux.vnet.ibm.com> <20070723123429.15715972@oldman.hamilton.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sri@us.ibm.com, dlstevens@us.ibm.com,
	varuncha@in.ibm.com
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:57563 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750738AbXGXEUm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jul 2007 00:20:42 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l6O4Kggh016911
	for <netdev@vger.kernel.org>; Tue, 24 Jul 2007 00:20:42 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l6O4KfNY192500
	for <netdev@vger.kernel.org>; Mon, 23 Jul 2007 22:20:41 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l6O4KfT7008253
	for <netdev@vger.kernel.org>; Mon, 23 Jul 2007 22:20:41 -0600
In-Reply-To: <20070723123429.15715972@oldman.hamilton.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> On Mon, 23 Jul 2007 10:13:18 +0530
> Varun Chandramohan <varunc@linux.vnet.ibm.com> wrote:
>
>   
>> The age field of the ipv6 route structures are initilized with the current timeval at the time of route       creation. When the route dump is called the route age value stored in the structure is subtracted from the     present timeval and the difference is passed on as the route age.
>>
>> Signed-off-by: Varun Chandramohan <varunc@linux.vnet.ibm.com>
>> ---
>>  include/net/ip6_fib.h   |    1 +
>>  include/net/ip6_route.h |    3 +++
>>  net/ipv6/addrconf.c     |    5 +++++
>>  net/ipv6/route.c        |   23 +++++++++++++++++++----
>>  4 files changed, 28 insertions(+), 4 deletions(-)
>>
>> diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
>> index c48ea87..e30a1cf 100644
>> --- a/include/net/ip6_fib.h
>> +++ b/include/net/ip6_fib.h
>> @@ -98,6 +98,7 @@ struct rt6_info
>>  	
>>  	u32				rt6i_flags;
>>  	u32				rt6i_metric;
>> +	time_t				rt6i_age;
>>  	atomic_t			rt6i_ref;
>>  	struct fib6_table		*rt6i_table;
>>  
>> diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
>> index 5456fdd..fc9716c 100644
>> --- a/include/net/ip6_route.h
>> +++ b/include/net/ip6_route.h
>> @@ -36,6 +36,9 @@ struct route_info {
>>  #define RT6_LOOKUP_F_REACHABLE	0x2
>>  #define RT6_LOOKUP_F_HAS_SADDR	0x4
>>  
>> +#define RT6_SET_ROUTE_INFO 0x0
>> +#define RT6_GET_ROUTE_INFO 0x1
>> +
>>  extern struct rt6_info	ip6_null_entry;
>>  
>>  #ifdef CONFIG_IPV6_MULTIPLE_TABLES
>> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
>> index 5a5f8bd..715c766 100644
>> --- a/net/ipv6/addrconf.c
>> +++ b/net/ipv6/addrconf.c
>> @@ -4187,6 +4187,7 @@ EXPORT_SYMBOL(unregister_inet6addr_notif
>>  
>>  int __init addrconf_init(void)
>>  {
>> +	struct timeval tv;
>>  	int err = 0;
>>  
>>  	/* The addrconf netdev notifier requires that loopback_dev
>> @@ -4214,10 +4215,14 @@ int __init addrconf_init(void)
>>  	if (err)
>>  		return err;
>>  
>> +	do_gettimeofday(&tv);
>>     
>
> Better to use ktime_t or timespec in new code.
>   
You are saying not to use timeval as its going to be removed sometime in
future? If not, may i know why should we use timespec or ktime?
I need only seconds granularity so i was wondering if that matters.

Regards,
Varun
