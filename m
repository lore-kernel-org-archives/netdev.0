From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: irq disable in __netdev_alloc_frag() ?
Date: Wed, 22 Oct 2014 22:14:04 -0700
Message-ID: <1414041244.2094.26.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAMEtUuwsUqd-U8ZSEXCB+a7cvLpbuRjPU2m0Ux84q6cxoWSx+g@mail.gmail.com>
	 <1414029160.2094.8.camel@edumazet-glaptop2.roam.corp.google.com>
	 <544873DF.1040403@gmail.com>
	 <1414036276.2094.18.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1414036570.2094.19.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAMEtUuytvhHJEGCmwkgH9EesCJdDhOn=5AujFymWPxg7g+E3og@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	Network Development <netdev@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:64608 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750813AbaJWFOG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Oct 2014 01:14:06 -0400
Received: by mail-pd0-f175.google.com with SMTP id y13so380470pdi.6
        for <netdev@vger.kernel.org>; Wed, 22 Oct 2014 22:14:05 -0700 (PDT)
In-Reply-To: <CAMEtUuytvhHJEGCmwkgH9EesCJdDhOn=5AujFymWPxg7g+E3og@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-10-22 at 21:29 -0700, Alexei Starovoitov wrote:

> my numbers were from just released Xeon E5-1630 v3
> which is haswell-ep
> I think Alexander's idea is worth pursuing.
> Code-wise the bloat is minimal: one extra netdev_alloc_cache
> and few 'if' which one to choose.


> Most of the time only one of them is used, since
> systems with napi and not-napi nics are very rare.


> I think it should help virtualization case as well,
> since virtio_net is napi already.

Really, I doubt this will make any difference in real workloads
where bottleneck is memory bandwidth, not the time taken by
pushf/cli/popf.

What difference do you have on a real workload like : netperf TCP_RR or
UDP_RR ?
