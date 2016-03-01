From: "Rafael J. Wysocki" <rafael@kernel.org>
Subject: Re: [RFC][PATCH] tags: Fix DEFINE_PER_CPU expansions
Date: Tue, 1 Mar 2016 22:39:02 +0100
Message-ID: <CAJZ5v0jgg2saYN5Z=Nh0N6zbHV-t3fD3PZC6jLwKnp4uMpkKfw@mail.gmail.com>
References: <20160301102625.GQ6357@twins.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	"Rafael J. Wysocki" <rjw@rjwysocki.net>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Ingo Molnar <mingo@kernel.org>,
	Paul McKenney <paulmck@linux.vnet.ibm.com>,
	Tejun Heo <tj@kernel.org>, David Miller <davem@davemloft.net>,
	ACPI Devel Maling List <linux-acpi@vger.kernel.org>,
	netdev@vger.kernel.org
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <20160301102625.GQ6357@twins.programming.kicks-ass.net>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 1, 2016 at 11:26 AM, Peter Zijlstra <peterz@infradead.org> wrote:
>
> $ make tags
>   GEN     tags
> ctags: Warning: drivers/acpi/processor_idle.c:64: null expansion of name pattern "\1"
> ctags: Warning: drivers/xen/events/events_2l.c:41: null expansion of name pattern "\1"
> ctags: Warning: kernel/locking/lockdep.c:151: null expansion of name pattern "\1"
> ctags: Warning: kernel/rcu/rcutorture.c:133: null expansion of name pattern "\1"
> ctags: Warning: kernel/rcu/rcutorture.c:135: null expansion of name pattern "\1"
> ctags: Warning: kernel/workqueue.c:323: null expansion of name pattern "\1"
> ctags: Warning: net/ipv4/syncookies.c:53: null expansion of name pattern "\1"
> ctags: Warning: net/ipv6/syncookies.c:44: null expansion of name pattern "\1"
> ctags: Warning: net/rds/page.c:45: null expansion of name pattern "\1"
>
> Which are all the result of the DEFINE_PER_CPU pattern:
>
> scripts/tags.sh:200:    '/\<DEFINE_PER_CPU([^,]*, *\([[:alnum:]_]*\)/\1/v/'
> scripts/tags.sh:201:    '/\<DEFINE_PER_CPU_SHARED_ALIGNED([^,]*, *\([[:alnum:]_]*\)/\1/v/'
>
> The below cures them. All except the workqueue one are within reasonable
> distance of the 80 char limit. TJ do you have any preference on how to
> fix the wq one, or shall we just not care its too long?
>
> Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
> ---
>  drivers/acpi/processor_idle.c  | 4 ++--
>  drivers/xen/events/events_2l.c | 5 +++--
>  kernel/locking/lockdep.c       | 3 +--
>  kernel/rcu/rcutorture.c        | 6 ++----
>  kernel/workqueue.c             | 3 +--
>  net/ipv4/syncookies.c          | 3 +--
>  net/ipv6/syncookies.c          | 3 +--
>  net/rds/page.c                 | 4 ++--
>  8 files changed, 13 insertions(+), 18 deletions(-)
>
> diff --git a/drivers/acpi/processor_idle.c b/drivers/acpi/processor_idle.c
> index 175c86bee3a9..9ca2b2fefd76 100644
> --- a/drivers/acpi/processor_idle.c
> +++ b/drivers/acpi/processor_idle.c
> @@ -61,8 +61,8 @@ module_param(latency_factor, uint, 0644);
>
>  static DEFINE_PER_CPU(struct cpuidle_device *, acpi_cpuidle_device);
>
> -static DEFINE_PER_CPU(struct acpi_processor_cx * [CPUIDLE_STATE_MAX],
> -                                                               acpi_cstate);
> +static
> +DEFINE_PER_CPU(struct acpi_processor_cx * [CPUIDLE_STATE_MAX], acpi_cstate);
>
>  static int disabled_by_idle_boot_param(void)
>  {

For the above:

Acked-by: Rafael J. Wysocki <rafael.j.wysocki@intel.com>
