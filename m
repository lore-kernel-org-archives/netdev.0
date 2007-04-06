From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH 4/4] Add loopback address type inline
Date: Fri, 06 Apr 2007 02:38:18 -0400
Message-ID: <4615EADA.5090802@hp.com>
References: <11758281872074-git-send-email-brian.haley@hp.com>	<151538c13022864224f5ff440e1147f884abb492.1175794415.git.brian.haley@hp.com>	<4615BCBD.2030607@hp.com> <20070406.125154.73441979.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: =?windows-1252?Q?YOSHIFUJI_Hideaki_/_=3F=3F=3F=3F?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.cce.hp.com ([161.114.21.22]:14148 "EHLO
	ccerelrim01.cce.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751674AbXDFHLw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Apr 2007 03:11:52 -0400
In-Reply-To: <20070406.125154.73441979.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

YOSHIFUJI Hideaki / ???? wrote:
>> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
>> index 32c6398..06ee92d 100644
>> --- a/net/ipv6/route.c
>> +++ b/net/ipv6/route.c
>> @@ -1067,7 +1067,6 @@ int ip6_route_add(struct fib6_config *cfg)
>>   	struct net_device *dev = NULL;
>>   	struct inet6_dev *idev = NULL;
>>   	struct fib6_table *table;
>> -	int addr_type;
>>
>>   	if (cfg->fc_dst_len > 128 || cfg->fc_src_len > 128)
>>   		return -EINVAL;
>> @@ -1108,9 +1107,7 @@ int ip6_route_add(struct fib6_config *cfg)
>>   		cfg->fc_protocol = RTPROT_BOOT;
>>   	rt->rt6i_protocol = cfg->fc_protocol;
>>
>> -	addr_type = ipv6_addr_type(&cfg->fc_dst);
>> -
>> -	if (addr_type & IPV6_ADDR_MULTICAST)
>> +	if (ipv6_addr_type_multicast(&cfg->fc_dst))
>>   		rt->u.dst.input = ip6_mc_input;
>>   	else
>>   		rt->u.dst.input = ip6_forward;
> 
> different commit...

This and the previous patch were layered, and I couldn't add the rest of 
this change without the loopback inline:

> @@ -1133,7 +1130,8 @@ int ip6_route_add(struct fib6_config *cfg)
>  	   they would result in kernel looping; promote them to reject routes
>  	 */
>  	if ((cfg->fc_flags & RTF_REJECT) ||
> -	    (dev && (dev->flags&IFF_LOOPBACK) && !(addr_type&IPV6_ADDR_LOOPBACK))) {
> +	    (dev && (dev->flags&IFF_LOOPBACK) &&
> +	     !ipv6_addr_loopback(&cfg->fc_dst))) {
>  		/* hold loopback dev/idev if we haven't done so. */
>  		if (dev != &loopback_dev) {
>  			if (dev) {

because they both used addr_type.

I'll put this all in one patch together next time so it's more obvious.

-Brian
