From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [RFC PATCH net-next 0/5] tcp: TCP tracer
Date: Sun, 14 Dec 2014 22:55:55 -0800
Message-ID: <CAADnVQJ+8mtB8LD=U7XbxOC2hxhDChxOELhZ3NEYeoTk1G3LYg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Lawrence Brakmo <brakmo@fb.com>, Josef Bacik <jbacik@fb.com>,
	Kernel Team <Kernel-team@fb.com>
To: Martin KaFai Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f45.google.com ([209.85.192.45]:42650 "EHLO
	mail-qg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750837AbaLOGz4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Dec 2014 01:55:56 -0500
Received: by mail-qg0-f45.google.com with SMTP id f51so8056110qge.18
        for <netdev@vger.kernel.org>; Sun, 14 Dec 2014 22:55:55 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Dec 14, 2014 at 5:56 PM, Martin KaFai Lau <kafai@fb.com> wrote:
> Hi,
>
> We have been using the kernel ftrace infra to collect TCP per-flow statistics.
> The following patch set is a first slim-down version of our
> existing implementation. We would like to get some early feedback
> and make it useful for others.
>
> [RFC PATCH net-next 1/5] tcp: Add TCP TRACE_EVENTs:
> Defines some basic tracepoints (by TRACE_EVENT).
>
> [RFC PATCH net-next 2/5] tcp: A perf script for TCP tracepoints:
> A sample perf script with simple ip/port filtering and summary output.
>
> [RFC PATCH net-next 3/5] tcp: Add a few more tracepoints for tcp tracer:
> Declares a few more tracepoints (by DECLARE_TRACE) which are
> used by the tcp_tracer.  The tcp_tracer is in the patch 5/5.
>
> [RFC PATCH net-next 4/5] tcp: Introduce tcp_sk_trace and related structs:
> Defines a few tcp_trace structs which are used to collect statistics
> on each tcp_sock.
>
> [RFC PATCH net-next 5/5] tcp: Add TCP tracer:
> It introduces a tcp_tracer which hooks onto the tracepoints defined in the
> patch 1/5 and 3/5.  It collects data defined in patch 4/5. We currently
> use this tracer to collect per-flow statistics.  The commit log has
> some more details.

I think patches 1 and 3 are good additions, since they establish
few permanent points of instrumentation in tcp stack.
Patches 4-5 look more like use cases of tracepoints established
before. They may feel like simple additions and, no doubt,
they are useful, but since they expose things via tracing
infra they become part of api and cannot be changed later,
when more stats would be needed.
I think systemtap like scripting on top of patches 1 and 3
should solve your use case ?
Also, have you looked at recent eBPF work?
Though it's not completely ready yet, soon it should
be able to do the same stats collection as you have
in 4/5 without adding permanent pieces to the kernel.
