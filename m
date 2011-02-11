From: Ian Molton <ian.molton@collabora.co.uk>
Subject: Re: [PATCH] Add JMEMCMP to Berkeley Packet Filters
Date: Fri, 11 Feb 2011 02:02:11 +0000
Message-ID: <4D5498A3.5070602@collabora.co.uk>
References: <1297341067-12264-1-git-send-email-ian.molton@collabora.co.uk>	<1297341067-12264-2-git-send-email-ian.molton@collabora.co.uk>	<1297344292.2493.3.camel@edumazet-laptop>	<4D53E9BE.4030500@collabora.co.uk> <AANLkTimOzvMx0FUaqxaa2QVV2FzsuhP8gQVX_CFmhiNR@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	rdunlap@xenotime.net, isdn@linux-pingi.de, paulus@samba.org,
	arnd@arndb.de, davem@davemloft.net, herbert@gondor.apana.org.au,
	ebiederm@xmission.com, alban.crequy@collabora.co.uk,
	astanciu@ixiacom.com
To: Octavian Purdila <tavi.purdila@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bhuna.collabora.co.uk ([93.93.128.226]:49681 "EHLO
	bhuna.collabora.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757643Ab1BKCCO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Feb 2011 21:02:14 -0500
In-Reply-To: <AANLkTimOzvMx0FUaqxaa2QVV2FzsuhP8gQVX_CFmhiNR@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/02/11 15:27, Octavian Purdila wrote:
> On Thu, Feb 10, 2011 at 3:35 PM, Ian Molton<ian.molton@collabora.co.uk>  wrote:
>> On 10/02/11 13:24, Eric Dumazet wrote:
>>
>> Hi!
>>
>> Thanks for reviewing! :)
>>
>>>> * Can sk_run_filter() be called in a context where kmalloc(GFP_KERNEL) is
>>>>    not allowed (I think not)
>>>
>>> You cannot use GFP_KERNEL in sk_run_filter() : We run in {soft}irq mode,
>>> in input path.
>>
>> Ok, that can be sorted.
>>
>>>> * Data section allocated with second call to sock_kmalloc().
>>>> * Should the patch be broken into two - one to add the data uploading,
>>>>    one to add the JMEMCMP insn. ?
>>>
>>> May I ask why it is needed at all ?
>>
>> So we can match strings in packet filters... I don't think I understand the
>> question...
>>
>
> Adding a data section (some sort of persistent memory storage that the
> filter can access) is also useful for creating capture triggers, e.g.
> starting capturing after a marker packet has arrived.

Nice to see that people are thinking of more use-cases.

Eric, I think I understand what you meant now...

Our use case is experimental for now, so I wanted to see if other people 
would find this useful, as adding an experimental feature that is never 
used seems pointless.

In our case, we need to match strings in d-bus packets. if the packet is 
not intended for the recipient, it gets dropped, thus avoiding a 
pointless context switch.

-Ian
