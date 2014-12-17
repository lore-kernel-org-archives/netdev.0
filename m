From: Josef Bacik <jbacik@fb.com>
Subject: Re: [RFC PATCH net-next 0/5] tcp: TCP tracer
Date: Wed, 17 Dec 2014 16:42:41 -0500
Message-ID: <5491F8D1.2090103@fb.com>
References: <CAADnVQL6-72UvvL-T7JUa-6c5+xJ2XggW=iCwb5G_ZbH3r-SZQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Blake Matheny <bmatheny@fb.com>,
	Laurent Chavey <chavey@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Lawrence Brakmo <brakmo@fb.com>,
	Kernel Team <Kernel-team@fb.com>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Martin Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:57628 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751117AbaLQVnF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2014 16:43:05 -0500
In-Reply-To: <CAADnVQL6-72UvvL-T7JUa-6c5+xJ2XggW=iCwb5G_ZbH3r-SZQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/16/2014 10:06 PM, Alexei Starovoitov wrote:
> On Tue, Dec 16, 2014 at 5:30 PM, Martin Lau <kafai@fb.com> wrote:
>>>>>>> I think systemtap like scripting on top of patches 1 and 3
>>>>>>> should solve your use case ?
>>>> We have quite a few different versions running in the production.  It may not
>>>> be operationally easy.
>>>
>>> different versions of kernel or different versions of tcp_tracer ?
>> Former and we are releasing new kernel pretty often.
>
> I see. So for dynamic tracer to be useful in such environment,
> the scripts should be compatible across different kernel version
> without recompilation. All makes sense.
>
>> How does the current TRACE_EVENT do it when it wants to printf more data?
>
> tracepoints, like any other user interface, shouldn't
> break compatibility. With printf it's practically impossible.
> Some subsystems may be breaking this rule arguing that
> tracepoints is a debug facility, but networking tracepoints don't change.
>

So that's what the events/<subsystem>/<event>/format is for, to provide 
a nice way for scripts to know what they are looking at.  For things 
like the tcp estats and other tracing tools we use in production 
internally we use something (our own stuff in case of estats, trace-cmd 
in the case of normal tracepoints) to read the raw data and pull out the 
fields we need, and that way it works no matter what kernel we're on. 
Sometimes tracepoints move and so we have to adjust our scripts, but 
that's the cost of doing business and I think that's acceptable.

>>> It feels that for stats collection only, tracepoints+tcp_trace
>>> do not add much additional value vs extending tcp_info
>>> and using ss.
>> I think we are on the same page. Once 'this should cost nothing if not
>> activated' proposition was cleared out.  It was what I meant that doing the
>> collection part in the TCP itself (instead of tracepoints) would be nice.
>
> agree.
>
>> I think going forward, as others have suggested, it may be better to come
>> together and reach a common ground on what to collect first before I re-work
>> patch 1 to 3 and repost.
>
> I think as a minimum it will be discussed at netdev01 in Feb,
> but I suspect not everyone on this list can(want) go to Ottawa,
> so would be nice to have a meetup for bay area folks to
> discuss this sooner with public g+ hangout.
> Thoughts?
>

Yeah I think we're all in agreement that this is a good netdev01 
discussion.  I'm happy to include people who want to talk about this 
before hand in the bay area meetup we're throwing, but it seems like 
this is going to be something that the larger community is going to want 
to talk about so it may be more productive to wait until netdev01.  Thanks,

Josef
