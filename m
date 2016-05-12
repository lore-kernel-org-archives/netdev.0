From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH 0/2] net: threadable napi poll loop
Date: Thu, 12 May 2016 13:49:39 -0700
Message-ID: <1463086179.23934.162.camel@edumazet-glaptop3.roam.corp.google.com>
References: <cover.1462886866.git.pabeni@redhat.com>
	 <1462890590.23934.68.camel@edumazet-glaptop3.roam.corp.google.com>
	 <90f3db8c-c30c-b204-576a-454939ac93ce@stressinduktion.org>
	 <CANn89i+YKrVOgfFwW-2psfCzq5_YLdmbV06-H-1FCOwXdMBuzQ@mail.gmail.com>
	 <94f323a9-515e-4d75-cac8-ef0214f0499e@stressinduktion.org>
	 <1462920697.23934.113.camel@edumazet-glaptop3.roam.corp.google.com>
	 <20160511065527.GD3193@twins.programming.kicks-ass.net>
	 <1463003804.23934.154.camel@edumazet-glaptop3.roam.corp.google.com>
	 <1463083620.5281.1.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Peter Zijlstra <peterz@infradead.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Eric Dumazet <edumazet@google.com>,
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
In-Reply-To: <1463083620.5281.1.camel@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2016-05-12 at 22:07 +0200, Paolo Abeni wrote:

> > > static inline bool ksoftirqd_running(void)
> > > {
> > > 	return __this_cpu_read(ksoftirqd)->state == TASK_RUNNING;
> 
> here something like:
> 
> 	struct task_struct *tsk = __this_cpu_read(ksoftirqd);
>         return tsk && (tsk->state == TASK_RUNNING);
> 
> is needed since __this_cpu_read(ksoftirqd) can be NULL on boot.

Indeed I've seen this but only when backporting to an older linux kernel
this morning.

Have you got this with current linux kernel ?
