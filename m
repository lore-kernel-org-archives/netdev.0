From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Optimizing instruction-cache, more packets at each stage
Date: Mon, 18 Jan 2016 09:01:49 -0800
Message-ID: <1453136509.1223.238.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20160115142223.1e92be75@redhat.com>
	 <063D6719AE5E284EB5DD2968C1650D6D1CCC6613@AcuExch.aculab.com>
	 <20160115150025.13a5db04@redhat.com> <56990473.9090300@openwrt.org>
	 <20160118125420.0375ffda@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Felix Fietkau <nbd@openwrt.org>,
	David Laight <David.Laight@ACULAB.COM>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Daniel Borkmann <borkmann@iogearbox.net>,
	Marek Majkowski <marek@cloudflare.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Florian Westphal <fw@strlen.de>,
	Paolo Abeni <pabeni@redhat.com>,
	John Fastabend <john.r.fastabend@intel.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:36311 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752217AbcARRBw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jan 2016 12:01:52 -0500
Received: by mail-pa0-f51.google.com with SMTP id yy13so343930578pab.3
        for <netdev@vger.kernel.org>; Mon, 18 Jan 2016 09:01:51 -0800 (PST)
In-Reply-To: <20160118125420.0375ffda@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-01-18 at 12:54 +0100, Jesper Dangaard Brouer wrote:

> That is very interesting. These kind of icache optimization will then
> likely benefit lower-end devices more than high end Intel CPUs :-)
> 
> AFAIK the Intel CPUs are masking this icache problem, by having a icache
> prefetcher and optimizing how fast the CPU can load/refill from higher
> level caches.  Intel CPUs have a lot of HW-logic around this, which the
> I assume the smaller CPUs don't.  E.g. quote from Intel Optimization
> Reference Manual:
> 
>  "The instruction fetch unit (IFU) can fetch up to 16 bytes of aligned
>   instruction bytes each cycle from the instruction cache to the
>   instruction length decoder (ILD). The instruction queue (IQ) buffers
>   the ILD-processed instructions and can deliver up to four instructions
>   in one cycle to the instruction decoder."
> 

This does not tell how many core/threads can fetch 16 bytes per cycle.

With more than 36 execution units per socket, single peak performance of
one unit does not reflect what happens when all units are busy and
contend on shared resource.

If we want to properly exploit L1 caches of each execution unit, we need
to split the load in a pipeline. But the number of units depend on
hardware capabilities (like L1 cache size). Something hard to code in a
generic way (linux kernel)

For example, having the same core handling RX and TX interrupts are not
the best choice, especially when TX interrupts have to call expensive
callbacks to upper layers (TCP Small Queues).
