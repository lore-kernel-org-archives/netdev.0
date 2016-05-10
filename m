From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [RFC PATCH 0/2] net: threadable napi poll loop
Date: Wed, 11 May 2016 00:32:48 +0200
Message-ID: <94f323a9-515e-4d75-cac8-ef0214f0499e@stressinduktion.org>
References: <cover.1462886866.git.pabeni@redhat.com>
 <1462890590.23934.68.camel@edumazet-glaptop3.roam.corp.google.com>
 <90f3db8c-c30c-b204-576a-454939ac93ce@stressinduktion.org>
 <CANn89i+YKrVOgfFwW-2psfCzq5_YLdmbV06-H-1FCOwXdMBuzQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Paolo Abeni <pabeni@redhat.com>,
	netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jiri Pirko <jiri@mellanox.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Alexander Duyck <aduyck@mirantis.com>,
	Tom Herbert <tom@herbertland.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@kernel.org>, Rik van Riel <riel@redhat.com>,
	LKML <linux-kernel@vger.kernel.org>
To: Eric Dumazet <edumazet@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CANn89i+YKrVOgfFwW-2psfCzq5_YLdmbV06-H-1FCOwXdMBuzQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10.05.2016 23:09, Eric Dumazet wrote:
> On Tue, May 10, 2016 at 1:46 PM, Hannes Frederic Sowa
> <hannes@stressinduktion.org> wrote:
> 
>> I agree here, but I don't think this patch particularly is a lot of
>> bloat and something very interesting people can play with and extend upon.
>>
> 
> Sure, very rarely patch authors think their stuff is bloat.
> 
> I prefer to fix kernel softirq.c, or at least show me that you tried
> hard enough.
> 
> I am pretty sure that the following would work :
> 
> When ksoftirqd is scheduled, remember this in a per cpu variable
> (ksoftiqd_scheduled)
> 
> When enabling BH , do not call do_softirq() if this variable is set.
> 
> ksoftirqd would clear the variable at the right place (probably in
> run_ksoftirqd())
> 
> Sure, this might add a lot of latency regressions, but lets fix them.

Probably, yes.

We had a version which limited the number of restarts if softirqs were
invoked from local_bh_enable (so that at least timers etc. would run)
and would defer all other work to ksoftirqd. That also solved the
initial live lock problem. I do have concerns about the fairness of this
approach, but we now have to investigate this. ;)

Not only did we want to present this solely as a bugfix but also as as
performance enhancements in case of virtio (as you can see in the cover
letter). Given that a long time ago there was a tendency to remove
softirqs completely, we thought it might be very interesting, that a
threaded napi in general seems to be absolutely viable nowadays and
might offer new features.

Bye,
Hannes
