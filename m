From: Hannes Frederic Sowa <hannes@redhat.com>
Subject: Re: [PATCH net-next v4] net: ipv6: Make address flushing on ifdown optional
Date: Thu, 08 Oct 2015 21:47:25 +0200
Message-ID: <877fmxcfci.fsf@stressinduktion.org>
References: <1444231059-14830-1-git-send-email-dsa@cumulusnetworks.com> <877fmxf9iq.fsf@stressinduktion.org> <5616C5AE.8010707@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nicolas.dichtel@6wind.com
To: David Ahern <dsa@cumulusnetworks.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58469 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752249AbbJHTr2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Oct 2015 15:47:28 -0400
In-Reply-To: <5616C5AE.8010707@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

David Ahern <dsa@cumulusnetworks.com> writes:
> On 10/8/15 1:25 PM, Hannes Frederic Sowa wrote:
>>> diff --git a/include/net/if_inet6.h b/include/net/if_inet6.h
>>> index 1c8b6820b694..f190a14148ab 100644
>>> --- a/include/net/if_inet6.h
>>> +++ b/include/net/if_inet6.h
>>> @@ -72,6 +72,7 @@ struct inet6_ifaddr {
>>>   	int			regen_count;
>>>
>>>   	bool			tokenized;
>>> +	bool			managed;
>>
>> IMHO the naming of the bool is a bit too vague. ;) Would you mind
>> renaming it to something like puuh... user_managed, non_autoconf,
>> manual_conf etc.?  'managed' seems so often used in the context of
>> temporary addresses, I first thought about that.
>>
>> enum { USER_SPACE, KERNEL_AUTOCONF } managed_by;
>
> I have no preference on naming; unless other preferences are stated I'll 
> do v5 with it renamed to 'user_managed'.

I think this is more appropriate. Thanks!

>>> @@ -2689,6 +2692,9 @@ static int inet6_addr_add(struct net *net, int ifindex,
>>>   			    valid_lft, prefered_lft);
>>>
>>>   	if (!IS_ERR(ifp)) {
>>> +		if (!expires)
>>> +			ifp->managed = true;
>>> +
>>
>> This assumes that user space managed addresses don't time out. This is
>> in fact not true. I am not sure if it matters a lot, as most addresses
>> added from user space with a timeout most probably will be added because
>> of autoconf, but they are not managed by kernel autoconf. Not sure if we
>> want to make this more explicit, certainly it would avoid surprises.
>
> Not exactly. I'm taking the easy way out and saying only addresses with 
> no expiration time fall into the 'user managed' category and retained on 
> an ifdown. Trying to accommodate lifetimes is a PITA. I mentioned that 
> in the documentation:
>    "static global addresses with no expiration time are not flushed"

Hmm, I thought a call to addrconf_verify on up would be sufficient but
haven't looked into that too closely.

Anyway, this logic actually only makes sense with addresses which don't
expire.

Thanks,
Hannes
