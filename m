From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v4] net: ipv6: Make address flushing on ifdown
 optional
Date: Thu, 8 Oct 2015 13:36:14 -0600
Message-ID: <5616C5AE.8010707@cumulusnetworks.com>
References: <1444231059-14830-1-git-send-email-dsa@cumulusnetworks.com>
 <877fmxf9iq.fsf@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: nicolas.dichtel@6wind.com
To: Hannes Frederic Sowa <hannes@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:33442 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755889AbbJHTgM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2015 15:36:12 -0400
Received: by pacex6 with SMTP id ex6so63224750pac.0
        for <netdev@vger.kernel.org>; Thu, 08 Oct 2015 12:36:11 -0700 (PDT)
In-Reply-To: <877fmxf9iq.fsf@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Hannes:

On 10/8/15 1:25 PM, Hannes Frederic Sowa wrote:
>> diff --git a/include/net/if_inet6.h b/include/net/if_inet6.h
>> index 1c8b6820b694..f190a14148ab 100644
>> --- a/include/net/if_inet6.h
>> +++ b/include/net/if_inet6.h
>> @@ -72,6 +72,7 @@ struct inet6_ifaddr {
>>   	int			regen_count;
>>
>>   	bool			tokenized;
>> +	bool			managed;
>
> IMHO the naming of the bool is a bit too vague. ;) Would you mind
> renaming it to something like puuh... user_managed, non_autoconf,
> manual_conf etc.?  'managed' seems so often used in the context of
> temporary addresses, I first thought about that.
>
> enum { USER_SPACE, KERNEL_AUTOCONF } managed_by;

I have no preference on naming; unless other preferences are stated I'll 
do v5 with it renamed to 'user_managed'.



>> @@ -2689,6 +2692,9 @@ static int inet6_addr_add(struct net *net, int ifindex,
>>   			    valid_lft, prefered_lft);
>>
>>   	if (!IS_ERR(ifp)) {
>> +		if (!expires)
>> +			ifp->managed = true;
>> +
>
> This assumes that user space managed addresses don't time out. This is
> in fact not true. I am not sure if it matters a lot, as most addresses
> added from user space with a timeout most probably will be added because
> of autoconf, but they are not managed by kernel autoconf. Not sure if we
> want to make this more explicit, certainly it would avoid surprises.

Not exactly. I'm taking the easy way out and saying only addresses with 
no expiration time fall into the 'user managed' category and retained on 
an ifdown. Trying to accommodate lifetimes is a PITA. I mentioned that 
in the documentation:
   "static global addresses with no expiration time are not flushed"

Thanks for the review,
David
