From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: irq disable in __netdev_alloc_frag() ?
Date: Wed, 22 Oct 2014 23:12:21 -0700
Message-ID: <CAMEtUuz+91z1+fhV6J08+q_MqsHMPOf6zx8NEOMY8xMrkdRGag@mail.gmail.com>
References: <CAMEtUuwsUqd-U8ZSEXCB+a7cvLpbuRjPU2m0Ux84q6cxoWSx+g@mail.gmail.com>
	<1414029160.2094.8.camel@edumazet-glaptop2.roam.corp.google.com>
	<544873DF.1040403@gmail.com>
	<1414036276.2094.18.camel@edumazet-glaptop2.roam.corp.google.com>
	<1414036570.2094.19.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAMEtUuytvhHJEGCmwkgH9EesCJdDhOn=5AujFymWPxg7g+E3og@mail.gmail.com>
	<1414041244.2094.26.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	Network Development <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f48.google.com ([74.125.82.48]:53533 "EHLO
	mail-wg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750827AbaJWGMW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Oct 2014 02:12:22 -0400
Received: by mail-wg0-f48.google.com with SMTP id k14so346749wgh.7
        for <netdev@vger.kernel.org>; Wed, 22 Oct 2014 23:12:21 -0700 (PDT)
In-Reply-To: <1414041244.2094.26.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 22, 2014 at 10:14 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
> Really, I doubt this will make any difference in real workloads
> where bottleneck is memory bandwidth, not the time taken by
> pushf/cli/popf.
>
> What difference do you have on a real workload like : netperf TCP_RR or
> UDP_RR ?

there are different workloads. l2/l3 switching is very real
as well. For tcp_rr on the host the difference will be
minimal, since the time is spent elsewhere. For cases
that don't use tcp stack, but do pure l2/l3 processing
all improvements will add up. imo the kernel should be
optimized for all use cases when possible.
