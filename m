From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH net-next] rps: overflow prevention for saturated cpus
Date: Thu, 06 Dec 2012 14:25:17 -0800
Message-ID: <50C11B4D.4040109@hp.com>
References: <1354826194-9289-1-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, edumazet@google.com,
	therbert@google.com
To: Willem de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g6t0185.atlanta.hp.com ([15.193.32.62]:19188 "EHLO
	g6t0185.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752682Ab2LFWZU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Dec 2012 17:25:20 -0500
In-Reply-To: <1354826194-9289-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/06/2012 12:36 PM, Willem de Bruijn wrote:
> RPS and RFS balance load across cpus with flow affinity. This can
> cause local bottlenecks, where a small number or single large flow
> (DoS) can saturate one CPU while others are idle.
>
> This patch maintains flow affinity in normal conditions, but
> trades it for throughput when a cpu becomes saturated. Then, packets
> destined to that cpu (only) are redirected to the lightest loaded cpu
> in the rxqueue's rps_map. This breaks flow affinity under high load
> for some flows, in favor of processing packets up to the capacity
> of the complete rps_map cpuset in all circumstances.

I thought (one of) the ideas behind RFS at least was to give the CPU 
scheduler control over where network processing took place instead of it 
being dictated solely by the addressing.  I would have expected the CPU 
scheduler to migrate some work off the saturated CPU.  Or will this only 
affect RPS and not RFS?

Allowing individual flows to straddle the CPUs - won't that be somewhat 
like what happens in bonding with mode-rr in the outbound case - packet 
reordering evil?  What kind of workload is this targeting that calls for 
such intra-flow parallelism?

With respect to the examples given, what happens when it is TCP traffic 
rather than UDP?

happy benchmarking,

rick jones
