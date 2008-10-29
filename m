From: Andrew Morton <akpm@linux-foundation.org>
Subject: linux-next: arm allmodconfig
Date: Tue, 28 Oct 2008 17:56:04 -0700
Message-ID: <20081028175604.81c31cea.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>,
	Dave Airlie <airlied@linux.ie>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.arm.linux.org.uk,
	Herbert Xu <herbert
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:54388 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751962AbYJ2A6Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2008 20:58:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> arch/arm/mm/dma-mapping.c: In function `dma_sync_sg_for_cpu':
> arch/arm/mm/dma-mapping.c:588: warning: statement with no effect

Something in here:

                dmabounce_sync_for_cpu(dev, sg_dma_address(s), 0,
                                        sg_dma_len(s), dir);                    

> kernel/sched.c: In function `add_preempt_count':
> kernel/sched.c:4294: warning: unsupported arg to `__builtin_return_address'
> kernel/sched.c:4296: warning: unsupported arg to `__builtin_return_address'
> kernel/sched.c:4298: warning: unsupported arg to `__builtin_return_address'
> kernel/sched.c: In function `sub_preempt_count':
> kernel/sched.c:4294: warning: unsupported arg to `__builtin_return_address'
> kernel/sched.c:4296: warning: unsupported arg to `__builtin_return_address'
> kernel/sched.c:4298: warning: unsupported arg to `__builtin_return_address'

Related to CALLER_ADDR2, etc.

> drivers/atm/zatm.c: In function `refill_pool':
> drivers/atm/zatm.c:226: warning: `virt_to_bus' is deprecated (declared at /usr/src/devel/arch/arm/include/asm/memory.h:184)
> 
<50ish similar warnings snipped>

> drivers/atm/ambassador.h:257:1: warning: "FLASH_BASE" redefined
> In file included from arch/arm/mach-versatile/include/mach/irqs.h:22,
>                  from /usr/src/devel/arch/arm/include/asm/irq.h:4,
>                  from /usr/src/devel/arch/arm/include/asm/hardirq.h:6,
>                  from include/linux/hardirq.h:7,
>                  from include/asm-generic/local.h:5,
>                  from /usr/src/devel/arch/arm/include/asm/local.h:1,
>                  from include/linux/module.h:20,
>                  from drivers/atm/ambassador.c:25:
> arch/arm/mach-versatile/include/mach/platform.h:443:1: warning: this is the location of the previous definition
> In file included from drivers/atm/ambassador.c:44:
> drivers/atm/ambassador.h:258:1: warning: "FLASH_SIZE" redefined
> In file included from arch/arm/mach-versatile/include/mach/irqs.h:22,
>                  from /usr/src/devel/arch/arm/include/asm/irq.h:4,
>                  from /usr/src/devel/arch/arm/include/asm/hardirq.h:6,
>                  from include/linux/hardirq.h:7,
>                  from include/asm-generic/local.h:5,
>                  from /usr/src/devel/arch/arm/include/asm/local.h:1,
>                  from include/linux/module.h:20,
>                  from drivers/atm/ambassador.c:25:
> arch/arm/mach-versatile/include/mach/platform.h:444:1: warning: this is the location of the previous definition

This has been there for ages.  FLASH_BASE and FLASH_SIZE are silly
identifier for any code to use anywhere, really.

> drivers/atm/ambassador.c: In function `check_area':
> drivers/atm/ambassador.c:425: warning: `virt_to_bus' is deprecated (declared at /usr/src/devel/arch/arm/include/asm/memory.h:184)
<zillions more of these>

> In file included from drivers/atm/iphase.c:65:
> drivers/atm/iphase.h:332:1: warning: "EPROM_SIZE" redefined
> In file included from arch/arm/mach-versatile/include/mach/irqs.h:22,
>                  from /usr/src/devel/arch/arm/include/asm/irq.h:4,
>                  from /usr/src/devel/arch/arm/include/asm/hardirq.h:6,
>                  from include/linux/hardirq.h:7,
>                  from include/asm-generic/local.h:5,
>                  from /usr/src/devel/arch/arm/include/asm/local.h:1,
>                  from include/linux/module.h:20,
>                  from drivers/atm/iphase.c:43:
> arch/arm/mach-versatile/include/mach/platform.h:453:1: warning: this is the location of the previous definition

EPROM_SIZE namespace clash.

> crypto/testmgr.c: In function `alg_test_comp':
> crypto/testmgr.c:829: warning: 'ret' might be used uninitialized in this function

There's no way for the compiler to know that this code isn't buggy.

Suggest that this be fixed via uninitialized_var() or, better, convert
to a do{}while() loop.

I notice that test_comp() also has two locals called `ret' - one
shadowing the other.

> mm/mlock.c: In function `__mlock_vma_pages_range':
> mm/mlock.c:169: warning: 'ret' might be used uninitialized in this function

Again, gcc can't know this is unbuggy.  a do{}while() conversion would
fix it, I guess.

> In file included from drivers/atm/eni.c:29:
> drivers/atm/midway.h:19:1: warning: "EPROM_SIZE" redefined
> In file included from arch/arm/mach-versatile/include/mach/irqs.h:22,
>                  from /usr/src/devel/arch/arm/include/asm/irq.h:4,
>                  from /usr/src/devel/arch/arm/include/asm/hardirq.h:6,
>                  from include/linux/hardirq.h:7,
>                  from include/asm-generic/local.h:5,
>                  from /usr/src/devel/arch/arm/include/asm/local.h:1,
>                  from include/linux/module.h:20,
>                  from drivers/atm/eni.c:6:
> arch/arm/mach-versatile/include/mach/platform.h:453:1: warning: this is the location of the previous definition

Zzzz..

> drivers/atm/firestream.c: In function `submit_qentry':
> drivers/atm/firestream.c:608: warning: `bus_to_virt' is deprecated (declared at /usr/src/devel/arch/arm/include/asm/memory.h:189)

zillions more snipped

> include/asm-generic/cmpxchg-local.h:15: warning: 'prev' might be used uninitialized in this function
> drivers/gpu/drm/drm_lock.c: In function `drm_lock_free':
> include/asm-generic/cmpxchg-local.h:15: warning: 'prev' might be used uninitialized in this function
> include/asm-generic/cmpxchg-local.h:15: warning: 'prev' might be used uninitialized in this function
> drivers/gpu/drm/drm_lock.c: In function `drm_notifier':
> include/asm-generic/cmpxchg-local.h:15: warning: 'prev' might be used uninitialized in this function
> drivers/gpu/drm/drm_lock.c: In function `drm_idlelock_release':
> include/asm-generic/cmpxchg-local.h:15: warning: 'prev' might be used uninitialized in this function

didn't look.

> drivers/gpu/drm/drm_agpsupport.c:36:21: asm/agp.h: No such file or directory
> make[3]: *** [drivers/gpu/drm/drm_agpsupport.o] Error 1
> make[2]: *** [drivers/gpu/drm] Error 2
> make[1]: *** [drivers/gpu] Error 2
> make[1]: *** Waiting for unfinished jobs....

DRM has been breaking arm allmodconfig for at least a year.

> include/asm-generic/cmpxchg-local.h:15: warning: 'prev' might be used uninitialized in this function
> kernel/trace/trace_irqsoff.c: In function `start_critical_timings':
> kernel/trace/trace_irqsoff.c:185: warning: unsupported arg to `__builtin_return_address'
> kernel/trace/trace_irqsoff.c: In function `stop_critical_timings':
> kernel/trace/trace_irqsoff.c:222: warning: unsupported arg to `__builtin_return_address'
> sound/soc/codecs/tlv320aic23.c: In function `tlv320aic23_set_dai_sysclk':
> sound/soc/codecs/tlv320aic23.c:424: warning: unused variable `codec'
> kernel/trace/trace_sched_wakeup.c: In function `probe_wakeup_sched_switch':
> kernel/trace/trace_sched_wakeup.c:163: warning: unsupported arg to `__builtin_return_address'
> kernel/trace/trace_sched_wakeup.c:163: warning: unsupported arg to `__builtin_return_address'
> kernel/trace/trace_sched_wakeup.c: In function `probe_wakeup':
> kernel/trace/trace_sched_wakeup.c:265: warning: unsupported arg to `__builtin_return_address'
> kernel/trace/trace_sched_wakeup.c:265: warning: unsupported arg to `__builtin_return_address'

More CALLER_ADDR stuff.

> net/netlabel/netlabel_mgmt.c: In function `netlbl_mgmt_listentry':
> net/netlabel/netlabel_mgmt.c:268: warning: 'ret_val' might be used uninitialized in this function

Assumes that netlbl_af4list_foreach_rcu() will never iterate zero times.

Assumes that entry->type can never have an unexpected value.

gcc cannot get this right, and C-level changes will be needed to shut
this up.


> net/phonet/pn_dev.c: In function `phonet_device_get':
> net/phonet/pn_dev.c:72: warning: 'dev' might be used uninitialized in this function

Assumes that pndevs.list can enver be empty.  Only fixable at the C
level.  uninitialized_var(), or initialize it to NULL or whatever.

> include/asm-generic/xor.h:696: warning: 'xor_block_8regs_p' defined but not used
> include/asm-generic/xor.h:704: warning: 'xor_block_32regs_p' defined but not used

Statically defined storage in a header file.  Puke.

> crypto/async_tx/async_tx.c: In function `async_trigger_callback':
> crypto/async_tx/async_tx.c:584: warning: 'chan' might be used uninitialized in this function

I suppose that if gcc was genius enough they might make this go away. 
But I expect the code could be reorganised to fix this.


> sound/pci/hda/patch_sigmatel.c: In function `stac92xx_smux_enum_put':
> sound/pci/hda/patch_sigmatel.c:571: warning: 'val' might be used uninitialized in this function

This looks like a bug.

> fs/ntfs/compress.c: In function `ntfs_read_compressed_block':
> fs/ntfs/compress.c:521: warning: 'pages' might be used uninitialized in this function

Well that's weird.

> include/linux/slub_def.h:231: warning: 'ret' might be used uninitialized in this function
> include/linux/slub_def.h:231: warning: 'ret' might be used uninitialized in this function
> fs/xfs/quota/xfs_qm_syscalls.c: In function `xfs_qm_dqrele_inodes_ag':
> fs/xfs/quota/xfs_qm_syscalls.c:1039: warning: 'inode_refed' might be used uninitialized in this function
> fs/xfs/xfs_rtalloc.c: In function `xfs_growfs_rt':
> fs/xfs/xfs_rtalloc.c:1875: warning: 'tp' might be used uninitialized in this function
> fs/udf/super.c: In function `udf_process_sequence':
> fs/udf/super.c:1240: warning: 'map' might be used uninitialized in this function

I lost interest here.

> fs/quota_v2.c: In function `v2_read_file_info':
> fs/quota_v2.c:119: warning: integer constant is too large for "unsigned long" type
> fs/quota_v2.c:120: warning: integer constant is too large for "unsigned long" type

That's the new quota stuff.  I thought I fixed that...

