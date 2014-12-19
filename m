From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [RFC PATCH net-next 0/5] tcp: TCP tracer
Date: Thu, 18 Dec 2014 17:42:20 -0800
Message-ID: <CAK6E8=fBb_zjxUBAdgztZRJQw17+z0pcO1DOUBhtOGUY8KEfNw@mail.gmail.com>
References: <CAADnVQL6-72UvvL-T7JUa-6c5+xJ2XggW=iCwb5G_ZbH3r-SZQ@mail.gmail.com>
 <5491F8D1.2090103@fb.com> <D0B86A04.1B29%brakmo@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Josef Bacik <jbacik@fb.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Martin Lau <kafai@fb.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Blake Matheny <bmatheny@fb.com>,
	Laurent Chavey <chavey@google.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Kernel Team <Kernel-team@fb.com>
To: Lawrence Brakmo <brakmo@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f169.google.com ([209.85.214.169]:32881 "EHLO
	mail-ob0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751364AbaLSBnB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Dec 2014 20:43:01 -0500
Received: by mail-ob0-f169.google.com with SMTP id vb8so9360943obc.0
        for <netdev@vger.kernel.org>; Thu, 18 Dec 2014 17:43:01 -0800 (PST)
In-Reply-To: <D0B86A04.1B29%brakmo@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 18, 2014 at 3:43 PM, Lawrence Brakmo <brakmo@fb.com> wrote:
>
>
> On 12/17/14, 1:42 PM, "Josef Bacik" <jbacik@fb.com> wrote:
>
> >>>> It feels that for stats collection only, tracepoints+tcp_trace
> >>>> do not add much additional value vs extending tcp_info
> >>>> and using ss.
> >>> I think we are on the same page. Once 'this should cost nothing if not
> >>> activated' proposition was cleared out.  It was what I meant that
> >>>doing the
> >>> collection part in the TCP itself (instead of tracepoints) would be
> >>>nice.
> >>
> >> agree.
> >>
> >>> I think going forward, as others have suggested, it may be better to
> >>>come
> >>> together and reach a common ground on what to collect first before I
> >>>re-work
> >>> patch 1 to 3 and repost.
> >>
> >> I think as a minimum it will be discussed at netdev01 in Feb,
> >> but I suspect not everyone on this list can(want) go to Ottawa,
> >> so would be nice to have a meetup for bay area folks to
> >> discuss this sooner with public g+ hangout.
> >> Thoughts?
> >>
> >
> >Yeah I think we're all in agreement that this is a good netdev01
> >discussion.  I'm happy to include people who want to talk about this
> >before hand in the bay area meetup we're throwing, but it seems like
> >this is going to be something that the larger community is going to want
> >to talk about so it may be more productive to wait until netdev01.
> >Thanks,
>
>
> Josef: I think a preliminary discussion during the bay area meet up would
> be useful to get some of us in sync.
>
> There are two issues going on. One is the collection of statistics that
> can be read every-so-often and another is the issue of enabling easier
> tracing of TCP state for analysis and debugging.
>
> For statistics collection, extending tcp_info is a viable option although
> we may need to do some modifications to deal with: (1) Having many
> connections most of which are idle. We need an option to only output those
> whose stats have changed since the last read. (2) A mechanism to deal with
> closed connections and their stats. Note that in our current setup neither
> of these is an issue for us.
>
> For tracing and event collection, I see a lot of value in tracepoints that
> could print basic info with perf but also allow us to do more complex
> things by loading a module that hooks to the tracepoints. This is one way
> to set up triggers to collect state for a particular flow.
>
> Yuchung: I agree that a lot of information can be obtained through
> analysis of tcpdumps, but some internal state must be inferred and in many
> instances we can only get bounds.
Hi Larry :)

I definitely see values in tracepoints. I was responding to the commit
message in patch 5/5: "Uncover uplink/backbone/subnet issue, e.g. by
tracking the rxmit rate.". First ss and tcp_info can collect that
data. But rxmit rate is often not enough for diagnosis. One needs to
inspect the loss patterns from packet traces. I am sure you know what
I am talking about.



>
> - Larry
>
