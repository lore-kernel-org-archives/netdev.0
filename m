From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH v2 net-next] net: Implement fast csum_partial for x86_64
Date: Wed, 6 Jan 2016 18:36:54 -0800
Message-ID: <CALx6S375Z1SqnS1DHj4FOsQGrLeeBPTzQx=v_2c5EFiUFWyAtQ@mail.gmail.com>
References: <1452019261-449449-1-git-send-email-tom@herbertland.com>
	<568DC4C4.2050908@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Kernel Team <kernel-team@fb.com>, tglx@linutronix.de,
	mingo@redhat.com, hpa@zytor.com, x86@kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f177.google.com ([209.85.223.177]:34693 "EHLO
	mail-io0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752320AbcAGCgz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2016 21:36:55 -0500
Received: by mail-io0-f177.google.com with SMTP id 1so191316934ion.1
        for <netdev@vger.kernel.org>; Wed, 06 Jan 2016 18:36:55 -0800 (PST)
In-Reply-To: <568DC4C4.2050908@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 6, 2016 at 5:52 PM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> Hi Tom,
>
> On 05.01.2016 19:41, Tom Herbert wrote:
>>
>> --- /dev/null
>> +++ b/arch/x86/lib/csum-partial_64.S
>> @@ -0,0 +1,147 @@
>> +/* Copyright 2016 Tom Herbert <tom@herbertland.com>
>> + *
>> + * Checksum partial calculation
>> + *
>> + * __wsum csum_partial(const void *buff, int len, __wsum sum)
>> + *
>> + * Computes the checksum of a memory block at buff, length len,
>> + * and adds in "sum" (32-bit)
>> + *
>> + * Returns a 32-bit number suitable for feeding into itself
>> + * or csum_tcpudp_magic
>> + *
>> + * Register usage:
>> + *   %rdi: argument 1, buff
>> + *   %rsi: argument 2, length
>> + *   %rdx: argument 3, add in value
>
>
> I think you forgot to carry-add-in the %rdx register.
>
> The assembly code replaces do_csum but not csum_partial.
>
First instruction is: movl    %edx, %eax      /* Initialize with
initial sum argument */

Tom

> Bye,
> Hannes
>
