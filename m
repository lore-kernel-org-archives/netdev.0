From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [raw v1 2/4] [NET] Use raw_cpu ops for SNMP stats
Date: Tue, 8 Oct 2013 12:21:42 +0200
Message-ID: <20131008102142.GT3081@twins.programming.kicks-ass.net>
References: <20131007183226.334180014@linux.com>
 <0000014194309205-d0af4d2d-a046-4189-b4f0-ffea37374988-000000@email.amazonses.com>
 <20131008072114.GA4455@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Lameter <cl@linux.com>, Tejun Heo <tj@kernel.org>,
	akpm@linuxfoundation.org, Eric Dumazet <edumazet@google.com>,
	netdev@vger.kernel.org, Steven Rostedt <srostedt@redhat.com>,
	linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>
To: Ingo Molnar <mingo@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20131008072114.GA4455@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 08, 2013 at 09:21:14AM +0200, Ingo Molnar wrote:
> 
> * Christoph Lameter <cl@linux.com> wrote:
> 
> > SNMP stats are not protected by preemption but by bh handling.
> 
> Most forms of bh exclusion work via the preemption count though, and 
> softirq contexts themselves are generally not preemptible [to other CPUs] 
> either.
> 
> So the warnings should, in most cases, not trigger.

Right, so softirqs run either in the irq tail at which point
preempt_count += SOFTIRQ_OFFSET and thus preemption is disabled, or it
runs in ksoftirqd which has strict cpu affinity which also disables the
warning, and it also increments preempt_count with SOFTIRQ_OFFSET to
exclude the softirq from interrupts while its running, also disabling
the warning.

So it should very much not trigger.. if it does you want to know about
it.
