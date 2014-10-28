From: Eric Dumazet <edumazet@google.com>
Subject: Re: irq disable in __netdev_alloc_frag() ?
Date: Mon, 27 Oct 2014 19:46:20 -0700
Message-ID: <CANn89i+U0=YrwoUSASejsS37EiXO7dKR25Vx04at3PqGA1EpHA@mail.gmail.com>
References: <CAMEtUuwsUqd-U8ZSEXCB+a7cvLpbuRjPU2m0Ux84q6cxoWSx+g@mail.gmail.com>
	<1414029160.2094.8.camel@edumazet-glaptop2.roam.corp.google.com>
	<544873DF.1040403@gmail.com>
	<1414036276.2094.18.camel@edumazet-glaptop2.roam.corp.google.com>
	<20141027213523.799da09c@redhat.com>
	<alpine.DEB.2.11.1410272129530.21936@gentwo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Network Development <netdev@vger.kernel.org>
To: Christoph Lameter <cl@linux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f177.google.com ([209.85.216.177]:62485 "EHLO
	mail-qc0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752327AbaJ1CqV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Oct 2014 22:46:21 -0400
Received: by mail-qc0-f177.google.com with SMTP id l6so4850584qcy.22
        for <netdev@vger.kernel.org>; Mon, 27 Oct 2014 19:46:21 -0700 (PDT)
In-Reply-To: <alpine.DEB.2.11.1410272129530.21936@gentwo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 27, 2014 at 7:30 PM, Christoph Lameter <cl@linux.com> wrote:
> On Mon, 27 Oct 2014, Jesper Dangaard Brouer wrote:
>
>> > Same could be done with some kmem_cache_alloc() : SLAB uses hard irq
>> > masking while some caches are never used from hard irq context.
>>
>> Sounds interesting.
>
> SLUB does not disable interrupts in the fast paths.
>

Unfortunately, SLUB is more expensive than SLAB for many networking workloads.

The cost of disabling interrupts is pure noise compared to cache line misses.

SLUB has poor behavior compared to SLAB with alien caches,
even with the side effect that 'struct page' is 64 bytes aligned
instead of being 56 bytes with SLAB

Note that I am not doing SLUB/SLAB tests every day, so it might be
better nowadays.
