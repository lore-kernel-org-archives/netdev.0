From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: irq disable in __netdev_alloc_frag() ?
Date: Mon, 27 Oct 2014 21:35:23 +0100
Message-ID: <20141027213523.799da09c@redhat.com>
References: <CAMEtUuwsUqd-U8ZSEXCB+a7cvLpbuRjPU2m0Ux84q6cxoWSx+g@mail.gmail.com>
	<1414029160.2094.8.camel@edumazet-glaptop2.roam.corp.google.com>
	<544873DF.1040403@gmail.com>
	<1414036276.2094.18.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, Alexander Duyck <alexander.duyck@gmail.com>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Eric Dumazet <edumazet@google.com>,
	Network Development <netdev@vger.kernel.org>,
	Christoph Lameter <cl@linux.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58464 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751605AbaJ0Ufe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Oct 2014 16:35:34 -0400
In-Reply-To: <1414036276.2094.18.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 22 Oct 2014 20:51:16 -0700
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> On my hosts, this hard irq masking is pure noise.

On my hosts I can measure a significant difference between using
local_irq_disable() vs. local_irq_save(flags)

 *  2.860 ns cost for local_irq_{disable,enable} 
 * 14.840 ns cost for local_irq_save()+local_irq_restore() 

This is quite significant in my nanosec world ;-)

 
> What CPU are you using Alexander ?

I'm using a E5-2695 (Ivy-bridge)

You can easily reproduce my results on your own system with my
time_bench_sample module here:
 https://github.com/netoptimizer/prototype-kernel/blob/master/kernel/lib/time_bench_sample.c#L173

> Same could be done with some kmem_cache_alloc() : SLAB uses hard irq
> masking while some caches are never used from hard irq context.

Sounds interesting.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
