From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH v5 14/45] rcu, CPU hotplug: Fix comment referring to
 stop_machine()
Date: Fri, 8 Feb 2013 16:14:39 -0800
Message-ID: <20130209001439.GQ2666@linux.vnet.ibm.com>
References: <20130122073210.13822.50434.stgit@srivatsabhat.in.ibm.com>
 <20130122073630.13822.99359.stgit@srivatsabhat.in.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-doc@vger.kernel.org, peterz@infradead.org, fweisbec@gmail.com,
 linux-kernel@vger.kernel.org, mingo@kernel.org, linux-arch@vger.kernel.org,
 linux@arm.linux.org.uk, xiaoguangrong@linux.vnet.ibm.com,
 wangyun@linux.vnet.ibm.com, nikunj@linux.vnet.ibm.com,
 linux-pm@vger.kernel.org, rusty@rustcorp.com.au, rostedt@goodmis.org,
 rjw@sisk.pl, namhyung@kernel.org, tglx@linutronix.de,
 linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org, oleg@redhat.com,
 sbw@mit.edu, tj@kernel.org, akpm@linux-foundation.org,
 linuxppc-dev@lists.ozlabs.org
To: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <20130122073630.13822.99359.stgit@srivatsabhat.in.ibm.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 22, 2013 at 01:06:34PM +0530, Srivatsa S. Bhat wrote:
> Don't refer to stop_machine() in the CPU hotplug path, since we are going
> to get rid of it. Also, move the comment referring to callback adoption
> to the CPU_DEAD case, because that's where it happens now.
> 
> Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>

Ouch!  That comment is indeed obsolete and must die.

I queued this to -rcu with your Signed-off-by.  However, I omitted
the added comment, as it is imcomplete -- it is easy to look at
rcu_cleanup_dead_cpu() to see what it does.

							Thanx, Paul

> ---
> 
>  kernel/rcutree.c |    9 ++++-----
>  1 file changed, 4 insertions(+), 5 deletions(-)
> 
> diff --git a/kernel/rcutree.c b/kernel/rcutree.c
> index e441b77..ac94474 100644
> --- a/kernel/rcutree.c
> +++ b/kernel/rcutree.c
> @@ -2827,11 +2827,6 @@ static int __cpuinit rcu_cpu_notify(struct notifier_block *self,
>  		break;
>  	case CPU_DYING:
>  	case CPU_DYING_FROZEN:
> -		/*
> -		 * The whole machine is "stopped" except this CPU, so we can
> -		 * touch any data without introducing corruption. We send the
> -		 * dying CPU's callbacks to an arbitrarily chosen online CPU.
> -		 */
>  		for_each_rcu_flavor(rsp)
>  			rcu_cleanup_dying_cpu(rsp);
>  		rcu_cleanup_after_idle(cpu);
> @@ -2840,6 +2835,10 @@ static int __cpuinit rcu_cpu_notify(struct notifier_block *self,
>  	case CPU_DEAD_FROZEN:
>  	case CPU_UP_CANCELED:
>  	case CPU_UP_CANCELED_FROZEN:
> +		/*
> +		 * We send the dead CPU's callbacks to an arbitrarily chosen
> +		 * online CPU.
> +		 */
>  		for_each_rcu_flavor(rsp)
>  			rcu_cleanup_dead_cpu(cpu, rsp);
>  		break;
> 
