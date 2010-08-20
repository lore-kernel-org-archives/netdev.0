From: Ben Greear <greearb@candelatech.com>
Subject: Re: ip_tables.h can't be used in C++ programs.
Date: Fri, 20 Aug 2010 16:42:59 -0700
Message-ID: <4C6F1303.70707@candelatech.com>
References: <4C6ECF67.3040508@candelatech.com> <1282346230.3454.193.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:43035 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750875Ab0HTXnA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Aug 2010 19:43:00 -0400
In-Reply-To: <1282346230.3454.193.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/20/2010 04:17 PM, Ben Hutchings wrote:
> On Fri, 2010-08-20 at 11:54 -0700, Ben Greear wrote:
>> This method returns void* but is defined to return
>> a pointer to struct ipt_entry_target.
>>
>> This will not compile under g++ (or, I'm unable to figure out
>> how to make it work w/out editing the header file).
>>
>> Any reason this shouldn't be changed to:
>>
>>    return (struct ipt_entry_target*)e + e->target_offset;
>
> Because that multiplies the offset by sizeof(struct ipt_entry_target)!
>
>> /* Helper functions */
>> static __inline__ struct ipt_entry_target *
>> ipt_get_target(struct ipt_entry *e)
>> {
>>           return (void *)e + e->target_offset;
>> }
>
> For extra unportability, this is relying on the gcc extension for void
> pointer arithmetic.  Try something like:
>
> 	return (struct ipt_entry_target *)((char *)e + e->target_offset);

That compiles fine for me, would be great to get something like
that upstream!

Take it easy,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

