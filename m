From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH v2 net-next] net: sched: run ingress qdisc without locks
Date: Sun, 3 May 2015 17:42:08 +0200
Message-ID: <20150503174208.5b1548ba@redhat.com>
References: <1430544448-19777-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, "David S. Miller" <davem@davemloft.net>,
	John Fastabend <john.r.fastabend@intel.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46337 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750815AbbECPma (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 May 2015 11:42:30 -0400
In-Reply-To: <1430544448-19777-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri,  1 May 2015 22:27:28 -0700
Alexei Starovoitov <ast@plumgrid.com> wrote:

> From: John Fastabend <john.r.fastabend@intel.com>
> 
> TC classifiers/actions were converted to RCU by John in the series:
> http://thread.gmane.org/gmane.linux.network/329739/focus=329739
> and many follow on patches.
> This is the last patch from that series that finally drops
> ingress spin_lock.

I absolutely love this change.  It is a huge step for ingress
scalability.


> Single cpu ingress+u32 performance goes from 22.9 Mpps to 24.5 Mpps.

I was actually expecting to see a higher performance boost.

 (processing cost per packet)
 (1/(22.9*10^6)*10^9) = 43.67 ns
 (1/(24.5*10^6)*10^9) = 40.82 ns
 improvement diff     = -2.85 ns

The patch is removing two atomic operations, spin_{un,}lock, which I
have benchmarked[1] to cost approx 14ns on my system.  Your system
likely is faster, but not that much (p.s. benchmark your own system
with [1])

[1] https://github.com/netoptimizer/prototype-kernel/blob/master/kernel/lib/time_bench_sample.c

> In two cpu case when both cores are receiving traffic on the same
> device and go into the same ingress+u32 the performance jumps
> from 4.5 + 4.5 Mpps to 23.5 + 23.5 Mpps

This looks good for scalability :-)))

> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
> Acked-by: Daniel Borkmann <daniel@iogearbox.net>

Acked-by: Jesper Dangaard Brouer <brouer@redhat.com>

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
