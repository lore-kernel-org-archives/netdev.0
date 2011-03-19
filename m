From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH 2/4] ipv4: fix route deletion for IPs on many subnets
Date: Sat, 19 Mar 2011 23:41:36 +0200 (EET)
Message-ID: <alpine.LFD.2.00.1103192339200.2471@ja.ssi.bg>
References: <alpine.LFD.2.00.1103190113420.1678@ja.ssi.bg> <20110318.215751.108772214.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:34143 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757590Ab1CSVgY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 19 Mar 2011 17:36:24 -0400
In-Reply-To: <20110318.215751.108772214.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


 	Hello,

On Fri, 18 Mar 2011, David Miller wrote:

> From: Julian Anastasov <ja@ssi.bg>
> Date: Sat, 19 Mar 2011 01:17:01 +0200 (EET)
>
>> +	if (ifa->ifa_flags & IFA_F_SECONDARY) {
>>  		prim = inet_ifa_byprefix(in_dev, any, ifa->ifa_mask);
>>  		if (prim == NULL) {
>>  			printk(KERN_WARNING "fib_del_ifaddr: bug: prim == NULL\n");
>>  			return;
>>  		}
>> +		if (iprim && iprim != prim) {
>> + printk(KERN_WARNING "fib_del_ifaddr: bug: iprim != prim\n");
>> +			return;
>> +		}
>> +	} else if (!ipv4_is_zeronet(any) &&
>> + (any != ifa->ifa_local || ifa->ifa_prefixlen < 32)) {
>> +		fib_magic(RTM_DELROUTE,
>> + dev->flags & IFF_LOOPBACK ? RTN_LOCAL : RTN_UNICAST,
>> +			  any, ifa->ifa_prefixlen, prim);
>> +		subnet = 1;
>>  	}
>>
>>  	/* Deletion is more complicated than add.
>> @@ -755,6 +769,49 @@ static void fib_del_ifaddr(struct in_ifa
> ...
>> + /* Ignore ifa1 if it uses different primary IP (prefsrc) */
>> +		if (ifa1->ifa_flags & IFA_F_SECONDARY) {
>> +			/* Another address from our subnet? */
> ...
>> + ifa1->ifa_mask != prim1->ifa_mask ||
>> + !inet_ifa_match(ifa1->ifa_address, prim1))
>> + prim1 = inet_ifa_byprefix(in_dev,
>> + ifa1->ifa_address,
>> + ifa1->ifa_mask);
>
> Julian there exists all kinds of incorrect indentation in this patch,
> could you please fix it up?

 	It seems my mail client problem is not gone.
I'll use a script from now on. Will resend all patches 1-4
as v2 because all are broken.

Regards

--
Julian Anastasov <ja@ssi.bg>
