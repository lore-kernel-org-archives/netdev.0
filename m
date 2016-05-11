From: Eric Dumazet <edumazet@google.com>
Subject: Re: [RFC PATCH 0/2] net: threadable napi poll loop
Date: Wed, 11 May 2016 07:40:13 -0700
Message-ID: <CANn89i+Op8UsvrsZKKzHfC5j6gLMmY1ZbCg=OY8o4oW8RT5sxg@mail.gmail.com>
References: <cover.1462886866.git.pabeni@redhat.com>
	<1462890590.23934.68.camel@edumazet-glaptop3.roam.corp.google.com>
	<90f3db8c-c30c-b204-576a-454939ac93ce@stressinduktion.org>
	<CANn89i+YKrVOgfFwW-2psfCzq5_YLdmbV06-H-1FCOwXdMBuzQ@mail.gmail.com>
	<94f323a9-515e-4d75-cac8-ef0214f0499e@stressinduktion.org>
	<1462920697.23934.113.camel@edumazet-glaptop3.roam.corp.google.com>
	<20160511065527.GD3193@twins.programming.kicks-ass.net>
	<de6ef948-65a4-e7e0-718e-6d37474f65d4@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Peter Zijlstra <peterz@infradead.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Paolo Abeni <pabeni@redhat.com>,
	netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jiri Pirko <jiri@mellanox.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Alexander Duyck <aduyck@mirantis.com>,
	Tom Herbert <tom@herbertland.com>,
	Ingo Molnar <mingo@kernel.org>, Rik van Riel <riel@redhat.com>,
	LKML <linux-kernel@vger.kernel.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <de6ef948-65a4-e7e0-718e-6d37474f65d4@stressinduktion.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 11, 2016 at 6:13 AM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:

> This looks racy to me as the ksoftirqd could be in the progress to stop
> and we would miss another softirq invocation.

Looking at smpboot_thread_fn(), it looks fine :

                if (!ht->thread_should_run(td->cpu)) {
                        preempt_enable_no_resched();
                        schedule();
                } else {
                        __set_current_state(TASK_RUNNING);
                        preempt_enable();
                        ht->thread_fn(td->cpu);
                }
