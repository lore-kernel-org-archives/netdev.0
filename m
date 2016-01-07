From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v2 net-next] net: Implement fast csum_partial for x86_64
Date: Thu, 7 Jan 2016 03:43:13 +0100
Message-ID: <568DD0C1.1070100@stressinduktion.org>
References: <1452019261-449449-1-git-send-email-tom@herbertland.com>
 <568DC4C4.2050908@stressinduktion.org>
 <CALx6S375Z1SqnS1DHj4FOsQGrLeeBPTzQx=v_2c5EFiUFWyAtQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Kernel Team <kernel-team@fb.com>, tglx@linutronix.de,
	mingo@redhat.com, hpa@zytor.com, x86@kernel.org
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:56598 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752726AbcAGCnS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2016 21:43:18 -0500
Received: from compute2.internal (compute2.nyi.internal [10.202.2.42])
	by mailout.nyi.internal (Postfix) with ESMTP id 8F33B2082C
	for <netdev@vger.kernel.org>; Wed,  6 Jan 2016 21:43:17 -0500 (EST)
In-Reply-To: <CALx6S375Z1SqnS1DHj4FOsQGrLeeBPTzQx=v_2c5EFiUFWyAtQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07.01.2016 03:36, Tom Herbert wrote:
> On Wed, Jan 6, 2016 at 5:52 PM, Hannes Frederic Sowa
> <hannes@stressinduktion.org> wrote:
>> Hi Tom,
>>
>> On 05.01.2016 19:41, Tom Herbert wrote:
>>>
>>> --- /dev/null
>>> +++ b/arch/x86/lib/csum-partial_64.S
>>> @@ -0,0 +1,147 @@
>>> +/* Copyright 2016 Tom Herbert <tom@herbertland.com>
>>> + *
>>> + * Checksum partial calculation
>>> + *
>>> + * __wsum csum_partial(const void *buff, int len, __wsum sum)
>>> + *
>>> + * Computes the checksum of a memory block at buff, length len,
>>> + * and adds in "sum" (32-bit)
>>> + *
>>> + * Returns a 32-bit number suitable for feeding into itself
>>> + * or csum_tcpudp_magic
>>> + *
>>> + * Register usage:
>>> + *   %rdi: argument 1, buff
>>> + *   %rsi: argument 2, length
>>> + *   %rdx: argument 3, add in value
>>
>>
>> I think you forgot to carry-add-in the %rdx register.
>>
>> The assembly code replaces do_csum but not csum_partial.
>>
> First instruction is: movl    %edx, %eax      /* Initialize with
> initial sum argument */

Ups, sorry. I only grepped through the source. Meanwhile my test also 
uses non-zero sums and shows that it is fine.

Bye,
Hannes
