From: Eric Dumazet <edumazet@google.com>
Subject: Re: [RFC PATCH 0/2] net: threadable napi poll loop
Date: Mon, 16 May 2016 06:38:52 -0700
Message-ID: <CANn89iLph4R=YYqNJfZ8AudOueWD+gyoOxxc098bFv0=5L-X3A@mail.gmail.com>
References: <cover.1462886866.git.pabeni@redhat.com>
	<1462890590.23934.68.camel@edumazet-glaptop3.roam.corp.google.com>
	<90f3db8c-c30c-b204-576a-454939ac93ce@stressinduktion.org>
	<CANn89i+YKrVOgfFwW-2psfCzq5_YLdmbV06-H-1FCOwXdMBuzQ@mail.gmail.com>
	<94f323a9-515e-4d75-cac8-ef0214f0499e@stressinduktion.org>
	<1462920697.23934.113.camel@edumazet-glaptop3.roam.corp.google.com>
	<20160511065527.GD3193@twins.programming.kicks-ass.net>
	<1463003804.23934.154.camel@edumazet-glaptop3.roam.corp.google.com>
	<1463158203.11721.25.camel@redhat.com>
	<CANn89iLxx-K6XDgU=c+6S1ExtSoCqQyG+7XjzJW+xoL3ACJYuQ@mail.gmail.com>
	<1463159940.11721.37.camel@redhat.com>
	<CANn89iJER4ziKLsAkSpKMRKBtHApzsHOnSndXJn2oTsf_01beA@mail.gmail.com>
	<1463404232.4921.26.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jiri Pirko <jiri@mellanox.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Alexander Duyck <aduyck@mirantis.com>,
	Tom Herbert <tom@herbertland.com>,
	Ingo Molnar <mingo@kernel.org>, Rik van Riel <riel@redhat.com>,
	LKML <linux-kernel@vger.kernel.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1463404232.4921.26.camel@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 16, 2016 at 6:10 AM, Paolo Abeni <pabeni@redhat.com> wrote:
>
> I'm sorry for the not-so-prompt reply. I had to use a different H/W, so
> I had to re-run the tests with all the patch flavors to get comparable
> results.
>
> While I can confirm that adding the '!ksoftirqd_running()' condition
> improves the throughput a little, but in a reproducible way, removing
> the '!in_interrupt()' don't change the result measurably, in my
> environment.
>
> While running the test against a kernel with the above chunk applied I
> got a couple of:
>
> [  702.791025] NOHZ: local_softirq_pending 08
>
> Not seen with the other versions of this patch.

I've seen this message in all versions, depending on the workload.

Either a barrier of some kind is missing, or we uncover an existing bug.

Note that in my tests on an older base kernel (something based on 3.11
but with thousands of patches),
I would not have the scary rcu messages that I got with current
upstream kernels.
