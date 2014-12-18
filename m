From: Lawrence Brakmo <brakmo@fb.com>
Subject: Re: [RFC PATCH net-next 0/5] tcp: TCP tracer
Date: Thu, 18 Dec 2014 23:43:10 +0000
Message-ID: <D0B86A04.1B29%brakmo@fb.com>
References: <CAADnVQL6-72UvvL-T7JUa-6c5+xJ2XggW=iCwb5G_ZbH3r-SZQ@mail.gmail.com>
 <5491F8D1.2090103@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Blake Matheny <bmatheny@fb.com>,
	Laurent Chavey <chavey@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Kernel Team <Kernel-team@fb.com>
To: Josef Bacik <jbacik@fb.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Martin Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:28578 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751150AbaLRXnd convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Dec 2014 18:43:33 -0500
In-Reply-To: <5491F8D1.2090103@fb.com>
Content-Language: en-US
Content-ID: <B50E655DCF5B314586D1FDDD9143B62C@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 12/17/14, 1:42 PM, "Josef Bacik" <jbacik@fb.com> wrote:

>>>> It feels that for stats collection only, tracepoints+tcp_trace
>>>> do not add much additional value vs extending tcp_info
>>>> and using ss.
>>> I think we are on the same page. Once 'this should cost nothing if not
>>> activated' proposition was cleared out.  It was what I meant that
>>>doing the
>>> collection part in the TCP itself (instead of tracepoints) would be
>>>nice.
>>
>> agree.
>>
>>> I think going forward, as others have suggested, it may be better to
>>>come
>>> together and reach a common ground on what to collect first before I
>>>re-work
>>> patch 1 to 3 and repost.
>>
>> I think as a minimum it will be discussed at netdev01 in Feb,
>> but I suspect not everyone on this list can(want) go to Ottawa,
>> so would be nice to have a meetup for bay area folks to
>> discuss this sooner with public g+ hangout.
>> Thoughts?
>>
>
>Yeah I think we're all in agreement that this is a good netdev01
>discussion.  I'm happy to include people who want to talk about this
>before hand in the bay area meetup we're throwing, but it seems like
>this is going to be something that the larger community is going to want
>to talk about so it may be more productive to wait until netdev01.
>Thanks,


Josef: I think a preliminary discussion during the bay area meet up would
be useful to get some of us in sync.

There are two issues going on. One is the collection of statistics that
can be read every-so-often and another is the issue of enabling easier
tracing of TCP state for analysis and debugging.

For statistics collection, extending tcp_info is a viable option although
we may need to do some modifications to deal with: (1) Having many
connections most of which are idle. We need an option to only output those
whose stats have changed since the last read. (2) A mechanism to deal with
closed connections and their stats. Note that in our current setup neither
of these is an issue for us.

For tracing and event collection, I see a lot of value in tracepoints that
could print basic info with perf but also allow us to do more complex
things by loading a module that hooks to the tracepoints. This is one way
to set up triggers to collect state for a particular flow.

Yuchung: I agree that a lot of information can be obtained through
analysis of tcpdumps, but some internal state must be inferred and in many
instances we can only get bounds.

- Larry
