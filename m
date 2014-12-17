From: Arnaldo Carvalho de Melo <acme@kernel.org>
Subject: Re: [RFC PATCH net-next 0/5] tcp: TCP tracer
Date: Wed, 17 Dec 2014 16:51:21 -0300
Message-ID: <20141217195121.GB3150@kernel.org>
References: <CAADnVQJgUn-hUrR1XLE4J64Ms52zRCRQkJDFUDu9SGTONJ507w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Martin KaFai Lau <kafai@fb.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Lawrence Brakmo <brakmo@fb.com>, Josef Bacik <jbacik@fb.com>,
	Kernel Team <Kernel-team@fb.com>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.19.201]:52369 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750953AbaLQUDN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Dec 2014 15:03:13 -0500
Content-Disposition: inline
In-Reply-To: <CAADnVQJgUn-hUrR1XLE4J64Ms52zRCRQkJDFUDu9SGTONJ507w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Wed, Dec 17, 2014 at 09:14:02AM -0800, Alexei Starovoitov escreveu:
> On Wed, Dec 17, 2014 at 7:07 AM, Arnaldo Carvalho de Melo
> <arnaldo.melo@gmail.com> wrote:
> > I guess even just using 'perf probe' to set those wannabe tracepoints
> > should be enough, no? Then he can refer to those in his perf record
> > call, etc and process it just like with the real tracepoints.
 
> it's far from ideal for two reasons.
> - they have different kernels and dragging along vmlinux
> with debug info or multiple 'perf list' data is too cumbersome

It is not strictly necessary to carry vmlinux, that is just a probe
point resolution time problem, solvable when generating a shell script,
on the development machine, to insert the probes.

> operationally. Permanent tracepoints solve this problem.

Sure, and when available, use them, my suggestion wasn't to use
exclusively any mechanism, but to initially use what is available to
create the tools, then find places that could be improved (if that
proves to be the case) by using a higher performance mechanism.

> - the action upon hitting tracepoint is non-trivial.
> perf probe style of unconditionally walking pointer chains
> will be tripping over wrong pointers.

Huh? Care to elaborate on this one?

> Plus they already need to do aggregation for high
> frequency events.

> As part of acting on trace_transmit_skb() event:
> if (before(tcb->seq, tcp_sk(sk)->snd_nxt)) {
>   tcp_trace_stats_add(...)
> }
> if (jiffies_to_msecs(jiffies - sktr->last_ts) ..) {
>   tcp_trace_stats_add(...)
> }

But aren't these stats TCP already keeps or could be made to?

- Arnaldo
