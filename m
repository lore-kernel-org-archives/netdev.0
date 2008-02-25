From: Kevin Winchester <kjwinchester@gmail.com>
Subject: Re: linux-next: Tree for Feb 24
Date: Sun, 24 Feb 2008 20:23:03 -0400
Message-ID: <47C20A67.4060304@gmail.com>
References: <20080224162309.3e67dd22.sfr@canb.auug.org.au> <200802242100.46474.rjw@sisk.pl> <47C1FF2E.4060600@gmail.com> <200802250043.48765.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	len.brown@intel.com, pavel@suse.cz,
	linux-pm@lists.linux-foundation.org, Ingo Molnar <mingo@elte.hu>,
	peterz@infradead.org, romieu@fr.zoreil.com,
	NetDev <netdev@vger.kernel.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759568AbYBYAXW@vger.kernel.org>
In-Reply-To: <200802250043.48765.rjw@sisk.pl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rafael J. Wysocki wrote:
> On Monday, 25 of February 2008, Kevin Winchester wrote:
>> Rafael J. Wysocki wrote:
>>> On Sunday, 24 of February 2008, Kevin Winchester wrote:
>>>
>>>> Today was different - I attempted to suspend and resume from the console,
>>>> and the machine did not come back up.  I found the following in my log -
>>>> any help would be appreciated.
>>>>
>>>> Feb 24 13:59:56 alekhine kernel: [  456.497875] PM: Syncing filesystems ... done.
>>>> Feb 24 14:00:20 alekhine kernel: [  456.507273] Freezing user space processes ... (elapsed 0.00 seconds) done.
>>>> Feb 24 14:00:20 alekhine kernel: [  456.510447] Freezing remaining freezable tasks ... (elapsed 0.00 seconds) done.
>>>> Feb 24 14:00:20 alekhine kernel: [  456.510754] ACPI: Preparing to enter system sleep state S3
>>>> Feb 24 14:00:20 alekhine kernel: [  456.612370] Suspending console(s)
>>>> Feb 24 14:00:20 alekhine kernel: [  456.616254] sd 3:0:0:0: [sda] Synchronizing SCSI cache
>>>> Feb 24 14:00:20 alekhine kernel: [  456.616521] sd 3:0:0:0: [sda] Stopping disk
>>>> Feb 24 14:00:20 alekhine kernel: [  456.618221] ACPI: PCI interrupt for device 0000:00:11.5 disabled
>>>> Feb 24 14:00:20 alekhine kernel: [  456.630296] ACPI: PCI interrupt for device 0000:00:10.4 disabled
>>>> Feb 24 14:00:20 alekhine kernel: [  456.641085] ACPI: PCI interrupt for device 0000:00:10.3 disabled
>>>> Feb 24 14:00:20 alekhine kernel: [  456.651877] ACPI: PCI interrupt for device 0000:00:10.2 disabled
>>>> Feb 24 14:00:20 alekhine kernel: [  456.662716] ACPI: PCI interrupt for device 0000:00:10.1 disabled
>>>> Feb 24 14:00:20 alekhine kernel: [  456.673550] ACPI: PCI interrupt for device 0000:00:10.0 disabled
>>>> Feb 24 14:00:20 alekhine kernel: [  456.684385] ACPI: PCI interrupt for device 0000:00:0f.1 disabled
>>>> Feb 24 14:00:20 alekhine kernel: [  456.695056] ACPI: PCI interrupt for device 0000:00:0f.0 disabled
>>>> Feb 24 14:00:20 alekhine kernel: [  456.705856] 5 locks held by bash/2929:
>>>> Feb 24 14:00:20 alekhine kernel: [  456.705856]  #0:  (&buffer->mutex){--..}, at: [<c018960c>] sysfs_write_file+0x25/0xe3
>>>> Feb 24 14:00:20 alekhine kernel: [  456.705856]  #1:  (pm_mutex){--..}, at: [<c0138c54>] enter_state+0xea/0x100
>>>> Feb 24 14:00:20 alekhine kernel: [  456.705856]  #2:  (pm_sleep_rwsem){----}, at: [<c023c4b8>] device_suspend+0x25/0x251
>>>> Feb 24 14:00:20 alekhine kernel: [  456.705856]  #3:  (&data->update_lock#2){--..}, at: [<c029cb2b>] abituguru_suspend+0x13/0x18
>>>> Feb 24 14:00:20 alekhine kernel: [  456.705856]  #4:  (&vptr->lock){++..}, at: [<c0244665>] velocity_suspend+0x37/0x302
>>>> Feb 24 14:00:20 alekhine kernel: [  456.705856] irq event stamp: 19374
>>>> Feb 24 14:00:20 alekhine kernel: [  456.705856] hardirqs last  enabled at (19373): [<c0326664>] __mutex_unlock_slowpath+0xd5/0xef
>>>> Feb 24 14:00:20 alekhine kernel: [  456.705856] hardirqs last disabled at (19374): [<c0327bca>] _spin_lock_irqsave+0xf/0x3c
>>>> Feb 24 14:00:20 alekhine kernel: [  456.705856] softirqs last  enabled at (18484): [<c011e6ba>] __do_softirq+0x99/0x9e
>>>> Feb 24 14:00:20 alekhine kernel: [  456.705856] softirqs last disabled at (18479): [<c0104f15>] do_softirq+0x58/0xa8
>>>> Feb 24 14:00:20 alekhine kernel: [  456.705856] Pid: 2929, comm: bash Not tainted 2.6.25-rc2-next-20080224 #58
>>>> Feb 24 14:00:20 alekhine kernel: [  456.705856]  [<c01177c7>] __schedule_bug+0x58/0x5f
>>>> Feb 24 14:00:20 alekhine kernel: [  456.705856]  [<c0325b43>] schedule+0x67/0x3b3
>>> Well, could you check what's at schedule+0x67, please?
>> Is this how I would do this?  I tried schedule+0x67, but it just showed me the beginning of profile_hit.
>>
>> (gdb) l *(schedule+0x66)
>> 0xc0325b42 is in schedule (kernel/sched.c:3836).
>> 3831		 * Test if we are atomic. Since do_exit() needs to call into
>> 3832		 * schedule() atomically, we ignore that path for now.
>> 3833		 * Otherwise, whine if we are scheduling when we should not be.
>> 3834		 */
>> 3835		if (unlikely(in_atomic_preempt_off()) && unlikely(!prev->exit_state))
>> 3836			__schedule_bug(prev);
>> 3837	
>> 3838		profile_hit(SCHED_PROFILING, __builtin_return_address(0));
>> 3839	
>> 3840		schedstat_inc(this_rq(), sched_count);
>>
>> It appears that we are scheduling when we should not be...
>>
>>
>>>> Feb 24 14:00:20 alekhine kernel: [  456.705856]  [<c0121c39>] ? __mod_timer+0x8d/0x98
>>>> Feb 24 14:00:20 alekhine kernel: [  456.705856]  [<c0326043>] schedule_timeout+0x73/0x91
>>>> Feb 24 14:00:20 alekhine kernel: [  456.705856]  [<c012185c>] ? process_timeout+0x0/0xa
>>>> Feb 24 14:00:20 alekhine kernel: [  456.705856]  [<c0326075>] schedule_timeout_uninterruptible+0x14/0x16
>>>> Feb 24 14:00:20 alekhine kernel: [  456.705856]  [<c0121c54>] msleep+0x10/0x16
>>>> Feb 24 14:00:20 alekhine kernel: [  456.705856]  [<c01e0e51>] pci_set_power_state+0x17f/0x200
>>>> Feb 24 14:00:20 alekhine kernel: [  456.705856]  [<c0244917>] velocity_suspend+0x2e9/0x302
>>> velocity_suspend() seems to be at fault.
>> (gdb) l *(velocity_suspend+0x37)
>> 0xc0244665 is in velocity_suspend (drivers/net/via-velocity.c:3399).
>> 3394		if(!netif_running(vptr->dev))
>> 3395			return 0;
>> 3396	
>> 3397		netif_device_detach(vptr->dev);
>> 3398	
>> 3399		spin_lock_irqsave(&vptr->lock, flags);
>> 3400		pci_save_state(pdev);
>> 3401	#ifdef ETHTOOL_GWOL
>> 3402		if (vptr->flags & VELOCITY_FLAGS_WOL_ENABLED) {
>> 3403			velocity_get_ip(vptr);
>> (gdb) 
>> 3404			velocity_save_context(vptr, &vptr->context);
>> 3405			velocity_shutdown(vptr);
>> 3406			velocity_set_wol(vptr);
>> 3407			pci_enable_wake(pdev, PCI_D3hot, 1);
>> 3408			pci_set_power_state(pdev, PCI_D3hot);
> 
> Hm, why doesn't it use pci_choose_state() here?
> 
>> 3409		} else {
>> 3410			velocity_save_context(vptr, &vptr->context);
>> 3411			velocity_shutdown(vptr);
>> 3412			pci_disable_device(pdev);
>> 3413			pci_set_power_state(pdev, pci_choose_state(pdev, state));
>> (gdb) 
>> 3414		}
>> 3415	#else
>> 3416		pci_set_power_state(pdev, pci_choose_state(pdev, state));
>> 3417	#endif
>> 3418		spin_unlock_irqrestore(&vptr->lock, flags);
>> 3419		return 0;
>> 3420	}
>>
>> So velocity_suspend calls spin_lock_irqsave, and then pci_set_power_state
>> which msleep()s.  Is that the root problem here?
> 
> Yes, most probably, it is.
> 
>> (I've added Ingo & Peter to the CC list since they may have some comments on
>> the scheduler/lockdep parts of the trace).   
> 
> Well, it calls many things it shouldn't call under a spinlock, AFAICS.
> 
> Who's maintaining this driver?
> 

Added:

VIA VELOCITY NETWORK DRIVER
P:      Francois Romieu
M:      romieu@fr.zoreil.com
L:      netdev@vger.kernel.org
S:      Maintained
