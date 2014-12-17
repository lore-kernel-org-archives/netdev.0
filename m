From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [RFC PATCH net-next 0/5] tcp: TCP tracer
Date: Tue, 16 Dec 2014 19:06:59 -0800
Message-ID: <CAADnVQL6-72UvvL-T7JUa-6c5+xJ2XggW=iCwb5G_ZbH3r-SZQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
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
To: Martin Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f45.google.com ([209.85.192.45]:47859 "EHLO
	mail-qg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751066AbaLQDHA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2014 22:07:00 -0500
Received: by mail-qg0-f45.google.com with SMTP id f51so11063049qge.4
        for <netdev@vger.kernel.org>; Tue, 16 Dec 2014 19:06:59 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 16, 2014 at 5:30 PM, Martin Lau <kafai@fb.com> wrote:
>> >> >> I think systemtap like scripting on top of patches 1 and 3
>> >> >> should solve your use case ?
>> > We have quite a few different versions running in the production.  It may not
>> > be operationally easy.
>>
>> different versions of kernel or different versions of tcp_tracer ?
> Former and we are releasing new kernel pretty often.

I see. So for dynamic tracer to be useful in such environment,
the scripts should be compatible across different kernel version
without recompilation. All makes sense.

> How does the current TRACE_EVENT do it when it wants to printf more data?

tracepoints, like any other user interface, shouldn't
break compatibility. With printf it's practically impossible.
Some subsystems may be breaking this rule arguing that
tracepoints is a debug facility, but networking tracepoints don't change.

>> It feels that for stats collection only, tracepoints+tcp_trace
>> do not add much additional value vs extending tcp_info
>> and using ss.
> I think we are on the same page. Once 'this should cost nothing if not
> activated' proposition was cleared out.  It was what I meant that doing the
> collection part in the TCP itself (instead of tracepoints) would be nice.

agree.

> I think going forward, as others have suggested, it may be better to come
> together and reach a common ground on what to collect first before I re-work
> patch 1 to 3 and repost.

I think as a minimum it will be discussed at netdev01 in Feb,
but I suspect not everyone on this list can(want) go to Ottawa,
so would be nice to have a meetup for bay area folks to
discuss this sooner with public g+ hangout.
Thoughts?
