From: Martin Lau <kafai@fb.com>
Subject: Re: [RFC PATCH net-next 0/5] tcp: TCP tracer
Date: Tue, 16 Dec 2014 17:30:53 -0800
Message-ID: <20141217013053.GE1542549@devbig242.prn2.facebook.com>
References: <CAADnVQKtEfrEpAqMxf_aOmHmF4WeOQUD-zZpVYR9jnQUjHQgVg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Blake Matheny <bmatheny@fb.com>,
	Laurent Chavey <chavey@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Lawrence Brakmo <brakmo@fb.com>, Josef Bacik <jbacik@fb.com>,
	Kernel Team <Kernel-team@fb.com>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:32157 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750821AbaLQBbG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2014 20:31:06 -0500
Content-Disposition: inline
In-Reply-To: <CAADnVQKtEfrEpAqMxf_aOmHmF4WeOQUD-zZpVYR9jnQUjHQgVg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 16, 2014 at 04:15:24PM -0800, Alexei Starovoitov wrote:
> On Tue, Dec 16, 2014 at 10:28 AM, Martin Lau <kafai@fb.com> wrote:
> > We can consider to reuse the events's format (tracing/events/*/format). I think
> > blktrace.c is using similar approach in trace-cmd.
> 
> yes. tcp_trace is a carbon copy of blktrace applied to tcp.
> 
> >> >> I think systemtap like scripting on top of patches 1 and 3
> >> >> should solve your use case ?
> > We have quite a few different versions running in the production.  It may not
> > be operationally easy.
> 
> different versions of kernel or different versions of tcp_tracer ?
Former and we are releasing new kernel pretty often.

> 
> > Having a getsockopt will be useful for the new application/library to take
> > advantage of.
> >
> > For the continuous monitoring/logging purpose, ftrace can provide event
> > triggered tracing instead of periodically consulting ss.
> 
> so both getsockopt tcp_info approach and ftrace+tcp_trace
> approach can provide the same set of stats per flow, right?
> And the only difference is 'ss' needs polling and ftrace
> collects all events?
> Since they're stats anyway, the polling interval
> shouldn't matter. Just like lost trace events?
> 
> from patch 5 commit log:
> "Define probes and register them to the TCP tracepoints.  The probes
> collect the data defined in struct tcp_sk_trace and record them to
> the tracing's ring_buffer.
> "
> so two trace_seq_printf() from patch 5
> and two new 'struct tcp_trace_stats' and 'tcp_trace_basic'
> from patch 4 will become permanent user api.
> 
> At the same time the commit log is saying:
> "It is still missing a few things that
> we currently have, like:
> - why the sender is blocked? and how long for each reason?
> - some TCP Congestion Control data"
> 
> Does it mean that these printf and structs would have
> to change?
How does the current TRACE_EVENT do it when it wants to printf more data?

> Can 'struct tcp_info' be extended instead of
> adding 'struct tcp_trace_stats' ?
> Then getsockopt and ftrace+tcp_trace will be returning
> the same structs.
> 
> It feels that for stats collection only, tracepoints+tcp_trace
> do not add much additional value vs extending tcp_info
> and using ss.
I think we are on the same page. Once 'this should cost nothing if not
activated' proposition was cleared out.  It was what I meant that doing the
collection part in the TCP itself (instead of tracepoints) would be nice.

> I see the value in tracepoints on its own, since we'll
> be able to use dynamic tracing to do event aggregation,
> filtering, etc. That was my alternative suggestion to
> add only tracepoints from patches 1 and 3.

I think going forward, as others have suggested, it may be better to come
together and reach a common ground on what to collect first before I re-work
patch 1 to 3 and repost.

Thanks,
--Martin
