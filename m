From: Martin Lau <kafai@fb.com>
Subject: Re: [RFC PATCH net-next 0/5] tcp: TCP tracer
Date: Tue, 16 Dec 2014 10:28:41 -0800
Message-ID: <20141216182840.GD1542549@devbig242.prn2.facebook.com>
References: <CAADnVQJ+8mtB8LD=U7XbxOC2hxhDChxOELhZ3NEYeoTk1G3LYg@mail.gmail.com>
 <1418659395.9773.13.camel@edumazet-glaptop2.roam.corp.google.com>
 <D0B44739.74E8A%bmatheny@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Blake Matheny <bmatheny@fb.com>,
	Laurent Chavey <chavey@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Lawrence Brakmo <brakmo@fb.com>, Josef Bacik <jbacik@fb.com>,
	Kernel Team <Kernel-team@fb.com>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:15374 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750941AbaLPS2w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2014 13:28:52 -0500
Content-Disposition: inline
In-Reply-To: <D0B44739.74E8A%bmatheny@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> >On Sun, 2014-12-14 at 22:55 -0800, Alexei Starovoitov wrote:
> >
> >> I think patches 1 and 3 are good additions, since they establish
> >> few permanent points of instrumentation in tcp stack.
> >> Patches 4-5 look more like use cases of tracepoints established
> >> before. They may feel like simple additions and, no doubt,
> >> they are useful, but since they expose things via tracing
> >> infra they become part of api and cannot be changed later,
> >> when more stats would be needed.
We can consider to reuse the events's format (tracing/events/*/format). I think
blktrace.c is using similar approach in trace-cmd.

> >> I think systemtap like scripting on top of patches 1 and 3
> >> should solve your use case ?
We have quite a few different versions running in the production.  It may not
be operationally easy.

> >> Also, have you looked at recent eBPF work?
> >> Though it's not completely ready yet, soon it should
> >> be able to do the same stats collection as you have
> >> in 4/5 without adding permanent pieces to the kernel.
We are keeping an eye on the eBPF work.


> On 12/15/14, 8:03 AM, "Eric Dumazet" <eric.dumazet@gmail.com> wrote:
> 
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
For the data collecting part, it would be nice to do it in the TCP itself.

Having a getsockopt will be useful for the new application/library to take
advantage of.

For the continuous monitoring/logging purpose, ftrace can provide event
triggered tracing instead of periodically consulting ss.

Thanks,
--Martin
