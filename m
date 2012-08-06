From: Li Wei <lw@cn.fujitsu.com>
Subject: Re: [PATCH v2] ipv4/ipv6: multicast api unappropriate errno fix.
Date: Mon, 06 Aug 2012 09:19:55 +0800
Message-ID: <501F1BBB.5010108@cn.fujitsu.com>
References: <1343977605-14446-1-git-send-email-lw@cn.fujitsu.com> <501B99E1.9090803@cn.fujitsu.com> <OF074B1468.BAD353FE-ON85257A4F.0041C4E9-85257A4F.0042D425@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:63221 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753032Ab2HFBUo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 5 Aug 2012 21:20:44 -0400
In-Reply-To: <OF074B1468.BAD353FE-ON85257A4F.0041C4E9-85257A4F.0042D425@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/03/2012 08:09 PM, David Stevens wrote:
> netdev-owner@vger.kernel.org wrote on 08/03/2012 05:29:05 AM:
> 
>> @@ -1933,10 +1933,8 @@ int ip_mc_source(int add, int omode, struct 
>> sock *sk, struct
>>            (pmc->multi.imr_ifindex == imr.imr_ifindex))
>>           break;
>>     }
>> -   if (!pmc) {      /* must have a prior join */
>> -      err = -EINVAL;
>> -      goto done;
>> -   }
>> +   if (!pmc)      /* must have a prior join */
>> +      goto done;   /* err = -EADDRNOTAVAIL */
> 
> RFC3678, section 4.1.3:
>         "When the option itself is not legal on the group (i.e., when 
> trying a
>    Source-Specific option on a group after doing IP_ADD_MEMBERSHIP, or
>    when trying an Any-Source option without doing IP_ADD_MEMBERSHIP) the
>    error generated is EINVAL."
> 
>>     }
>> -   if (rv == 0)      /* address already there is an error */
>> +   if (rv == 0) {      /* address already there is an error */
>> +      err = -EADDRINUSE;
>>        goto done;
>> +   }
> 
> EADDRINUSE is not one of the API's listed error codes. Section 4.1.3
> of RFC3678 specifies:
>   "When the option would be legal on the group, but an address is
>    invalid (e.g., when trying to block a source that is already blocked
>    by the socket, or when trying to drop an unjoined group) the error
>    generated is EADDRNOTAVAIL."
> 
> At least some of this patch directly differs with RFC3678.

I read the RFC and found you are right, thanks :)

> 
>                                                         +-DLS
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
