From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net 0/3] Fix for BPF devmap percpu allocation splat
Date: Tue, 17 Oct 2017 17:11:11 +0200
Message-ID: <59E61D8F.5000505@iogearbox.net>
References: <cover.1508251210.git.daniel@iogearbox.net> <063D6719AE5E284EB5DD2968C1650D6DD009980D@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "tj@kernel.org" <tj@kernel.org>, "ast@kernel.org" <ast@kernel.org>,
        "john.fastabend@gmail.com" <john.fastabend@gmail.com>,
        "mark.rutland@arm.com" <mark.rutland@arm.com>,
        "richard@nod.at" <richard@nod.at>,
        "sp3485@columbia.edu" <sp3485@columbia.edu>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>,
        "davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:37950 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1762425AbdJQPLV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2017 11:11:21 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DD009980D@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/17/2017 05:03 PM, David Laight wrote:
> From: Daniel Borkmann
>> Sent: 17 October 2017 15:56
>>
>> The set fixes a splat in devmap percpu allocation when we alloc
>> the flush bitmap. Patch 1 is a prerequisite for the fix in patch 2,
>> patch 1 is rather small, so if this could be routed via -net, for
>> example, with Tejun's Ack that would be good. Patch 3 gets rid of
>> remaining PCPU_MIN_UNIT_SIZE checks, which are percpu allocator
>> internals and should not be used.
>
> Does it make sense to allow the user program to try to allocate ever
> smaller very large maps until it finds one that succeeds - thus
> using up all the percpu space?
>
> Or is this a 'root only' 'shoot self in foot' job?

It's root only although John still has a pending fix to be flushed
out for -net first in the next days to actually enforce that cap
(devmap is not in an official kernel yet at this point, so all good),
but apart from this, all map allocs in general are accounted for
as well.

Thanks,
Daniel
