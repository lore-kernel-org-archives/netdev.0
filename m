From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [RFC PATCH net-next 0/5] tcp: TCP tracer
Date: Wed, 17 Dec 2014 09:14:02 -0800
Message-ID: <CAADnVQJgUn-hUrR1XLE4J64Ms52zRCRQkJDFUDu9SGTONJ507w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Martin KaFai Lau <kafai@fb.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Lawrence Brakmo <brakmo@fb.com>, Josef Bacik <jbacik@fb.com>,
	Kernel Team <Kernel-team@fb.com>
To: Arnaldo Carvalho de Melo <arnaldo.melo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f47.google.com ([209.85.216.47]:52028 "EHLO
	mail-qa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750951AbaLQROD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2014 12:14:03 -0500
Received: by mail-qa0-f47.google.com with SMTP id s7so11475874qap.34
        for <netdev@vger.kernel.org>; Wed, 17 Dec 2014 09:14:02 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 17, 2014 at 7:07 AM, Arnaldo Carvalho de Melo
<arnaldo.melo@gmail.com> wrote:
>
> I guess even just using 'perf probe' to set those wannabe tracepoints
> should be enough, no? Then he can refer to those in his perf record
> call, etc and process it just like with the real tracepoints.

it's far from ideal for two reasons.
- they have different kernels and dragging along vmlinux
with debug info or multiple 'perf list' data is too cumbersome
operationally. Permanent tracepoints solve this problem.
- the action upon hitting tracepoint is non-trivial.
perf probe style of unconditionally walking pointer chains
will be tripping over wrong pointers.
Plus they already need to do aggregation for high
frequency events.
As part of acting on trace_transmit_skb() event:
if (before(tcb->seq, tcp_sk(sk)->snd_nxt)) {
  tcp_trace_stats_add(...)
}
if (jiffies_to_msecs(jiffies - sktr->last_ts) ..) {
  tcp_trace_stats_add(...)
}
