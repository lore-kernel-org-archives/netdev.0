From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: irq disable in __netdev_alloc_frag() ?
Date: Wed, 22 Oct 2014 21:29:22 -0700
Message-ID: <CAMEtUuytvhHJEGCmwkgH9EesCJdDhOn=5AujFymWPxg7g+E3og@mail.gmail.com>
References: <CAMEtUuwsUqd-U8ZSEXCB+a7cvLpbuRjPU2m0Ux84q6cxoWSx+g@mail.gmail.com>
	<1414029160.2094.8.camel@edumazet-glaptop2.roam.corp.google.com>
	<544873DF.1040403@gmail.com>
	<1414036276.2094.18.camel@edumazet-glaptop2.roam.corp.google.com>
	<1414036570.2094.19.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	Network Development <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f50.google.com ([74.125.82.50]:34184 "EHLO
	mail-wg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750812AbaJWE3Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Oct 2014 00:29:24 -0400
Received: by mail-wg0-f50.google.com with SMTP id a1so233243wgh.9
        for <netdev@vger.kernel.org>; Wed, 22 Oct 2014 21:29:22 -0700 (PDT)
In-Reply-To: <1414036570.2094.19.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 22, 2014 at 8:56 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2014-10-22 at 20:51 -0700, Eric Dumazet wrote:
>> On Wed, 2014-10-22 at 20:19 -0700, Alexander Duyck wrote:
>>
>> > Couldn't __netdev_alloc_frag() be forked into two functions, one that is
>> > only called from inside the NAPI context and one that is called for all
>> > other contexts?  It would mean having to double the number of pages
>> > being held per CPU, but I would think something like that would be doable.
>>
>> Possibly, but this looks like code bloat for me.
>>
>> On my hosts, this hard irq masking is pure noise.
>>
>> What CPU are you using Alexander ?
>
> Sorry, the question was for Alexei ;)

my numbers were from just released Xeon E5-1630 v3
which is haswell-ep
I think Alexander's idea is worth pursuing.
Code-wise the bloat is minimal: one extra netdev_alloc_cache
and few 'if' which one to choose.
Most of the time only one of them is used, since
systems with napi and not-napi nics are very rare.
I think it should help virtualization case as well,
since virtio_net is napi already.
