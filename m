From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [virtio-net] BUG: sleeping function called from invalid context
	at kernel/mutex.c:616
Date: Mon, 28 Oct 2013 20:49:11 +0800
Message-ID: <20131028124911.GA13923@localhost>
References: <20131020023418.GA6737@localhost> <526638D4.1030403@redhat.com>
	<20131023232033.GA7404@localhost> <526DF9A4.70709@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <526DF9A4.70709@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 28, 2013 at 01:44:04PM +0800, Jason Wang wrote:
> On 10/24/2013 07:20 AM, Fengguang Wu wrote:
> > Yes it reduces the sleeping function bug:
> >
> > /kernel/x86_64-lkp-CONFIG_SCSI_DEBUG/7c4ed2767afb813493b0a8fb18d666cd44550963
> >
> > +------------------------------------------------------------------------------------+-----------+--------------+--------------+
> > |                                                                                    | v3.12-rc3 | 3ab098df35f8 | 7c4ed2767afb |
> > +------------------------------------------------------------------------------------+-----------+--------------+--------------+
> > | good_boots                                                                         | 30        | 0            | 93           |
> > | has_kernel_error_warning                                                           | 0         | 20           | 7            |
> > | BUG:sleeping_function_called_from_invalid_context_at_kernel/mutex.c                | 0         | 20           |              |
> > | INFO:rcu_sched_self-detected_stall_on_CPU(t=jiffies_g=c=q=)                        | 0         | 0            | 1            |
> > | INFO:task_blocked_for_more_than_seconds                                            | 0         | 0            | 2            |
> > | INFO:NMI_handler(arch_trigger_all_cpu_backtrace_handler)took_too_long_to_run:msecs | 0         | 0            | 1            |
> > | Kernel_panic-not_syncing:hung_task:blocked_tasks                                   | 0         | 0            | 1            |
> > | BUG:kernel_test_crashed                                                            | 0         | 0            | 3            |
> > | BUG:kernel_test_hang                                                               | 0         | 0            | 1            |
> > +------------------------------------------------------------------------------------+-----------+--------------+--------------+
> >
> > However I'll need to increase tests on v3.12-rc3 to make sure it's not
> > the patch that added the other error messages.
> >
> > Thanks,
> > Fengguang
> 
> Thanks, any more update on the result of v3.12-rc3 for this?

Yes, it's confirmed that there are no new error types in 7c4ed2767afb
comparing to v3.12-rc3, so your fix is fine.

/kernel/x86_64-lkp-CONFIG_SCSI_DEBUG/7c4ed2767afb813493b0a8fb18d666cd44550963

+------------------------------------------------------------------------------------+-----------+--------------+--------------+
|                                                                                    | v3.12-rc3 | 3ab098df35f8 | 7c4ed2767afb |
+------------------------------------------------------------------------------------+-----------+--------------+--------------+
| good_boots                                                                         | 877       | 0            | 93           |
| has_kernel_error_warning                                                           | 154       | 20           | 7            |
| BUG:kernel_test_hang                                                               | 112       | 0            | 1            |
| INFO:rcu_sched_self-detected_stall_on_CPU(t=jiffies_g=c=q=)                        | 1         | 0            | 1            |
| INFO:task_blocked_for_more_than_seconds                                            | 18        | 0            | 2            |
| INFO:NMI_handler(arch_trigger_all_cpu_backtrace_handler)took_too_long_to_run:msecs | 11        | 0            | 1            |
| Kernel_panic-not_syncing:hung_task:blocked_tasks                                   | 11        | 0            | 1            |
| BUG:kernel_test_crashed                                                            | 13        | 0            | 3            |
| Out_of_memory:Kill_process                                                         | 9         |              |              |
| BUG:kernel_early_hang_without_any_printk_output                                    | 1         |              |              |
| page_allocation_failure:order:,mode                                                | 1         |              |              |
| Kernel_panic-not_syncing:Out_of_memory_and_no_killable_processes                   | 2         |              |              |
| BUG:sleeping_function_called_from_invalid_context_at_kernel/mutex.c                | 0         | 20           |              |
+------------------------------------------------------------------------------------+-----------+--------------+--------------+

Thanks,
Fengguang
