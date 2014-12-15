From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [RFC PATCH net-next 0/5] tcp: TCP tracer
Date: Mon, 15 Dec 2014 11:56:25 -0800
Message-ID: <CAK6E8=fsKNcVBBewDw89cLLFuQb1a0parZ7hmvuRfherqjXTng@mail.gmail.com>
References: <CAADnVQJ+8mtB8LD=U7XbxOC2hxhDChxOELhZ3NEYeoTk1G3LYg@mail.gmail.com>
 <1418659395.9773.13.camel@edumazet-glaptop2.roam.corp.google.com> <D0B44739.74E8A%bmatheny@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Laurent Chavey <chavey@google.com>, Martin Lau <kafai@fb.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Lawrence Brakmo <brakmo@fb.com>, Josef Bacik <jbacik@fb.com>,
	Kernel Team <Kernel-team@fb.com>
To: Blake Matheny <bmatheny@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f182.google.com ([209.85.223.182]:41171 "EHLO
	mail-ie0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751358AbaLOT5H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Dec 2014 14:57:07 -0500
Received: by mail-ie0-f182.google.com with SMTP id x19so11417239ier.41
        for <netdev@vger.kernel.org>; Mon, 15 Dec 2014 11:57:07 -0800 (PST)
In-Reply-To: <D0B44739.74E8A%bmatheny@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 15, 2014 at 8:08 AM, Blake Matheny <bmatheny@fb.com> wrote:
>
> We have an additional set of patches for web10g that builds on these
> tracepoints. It can be made to work either way, but I agree the idea of
> something like a sockopt would be really nice.

I'd like to compare these patches  with tools that parse pcap files to
generate per-flow counters to collect RTTs, #dupacks, etc. What
additional values or insights do they provide to improve/debug TCP
performance? maybe an example?

IMO these stats provide a general pictures of how TCP works of a
specific network, but not enough to really nail specific bugs in TCP
protocol or implementation. Then SNMP stats or sampling with pcap
traces with offline analysis can achieve the same purpose.

>
>
> -Blake
>
> On 12/15/14, 8:03 AM, "Eric Dumazet" <eric.dumazet@gmail.com> wrote:
>
> >On Sun, 2014-12-14 at 22:55 -0800, Alexei Starovoitov wrote:
> >
> >> I think patches 1 and 3 are good additions, since they establish
> >> few permanent points of instrumentation in tcp stack.
> >> Patches 4-5 look more like use cases of tracepoints established
> >> before. They may feel like simple additions and, no doubt,
> >> they are useful, but since they expose things via tracing
> >> infra they become part of api and cannot be changed later,
> >> when more stats would be needed.
> >> I think systemtap like scripting on top of patches 1 and 3
> >> should solve your use case ?
> >> Also, have you looked at recent eBPF work?
> >> Though it's not completely ready yet, soon it should
> >> be able to do the same stats collection as you have
> >> in 4/5 without adding permanent pieces to the kernel.
> >
> >So it looks like web10g like interfaces are very often requested by
> >various teams.
> >
> >And we have many different views on how to hack this. I am astonished by
> >number of hacks I saw about this stuff going on.
> >
> >What about a clean way, extending current TCP_INFO, which is both
> >available as a getsockopt() for socket owners and ss/iproute2
> >information for 'external entities'
> >
> >If we consider web10g info needed, then adding a ftrace/eBPF like
> >interface is simply yet another piece of code we need to maintain,
> >and the argument of 'this should cost nothing if not activated' is
> >nonsense since major players need to constantly monitor TCP metrics and
> >behavior.
> >
> >It seems both FaceBook and Google are working on a subset of web10g.
> >
> >I suggest we meet together and establish a common ground, preferably
> >after Christmas holidays.
> >
> >Thanks
> >
> >
>
