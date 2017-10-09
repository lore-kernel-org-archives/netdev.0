From: Masahiro Yamada <yamada.masahiro-uWyLwvC0a2jby3iVrkZq2A@public.gmane.org>
Subject: Re: [PATCH 10/12] net/mlx4: replace <linux/radix-tree.h> with <linux/radix-tree-root.h>
Date: Mon, 9 Oct 2017 14:55:52 +0900
Message-ID: <CAK7LNAT4OgL1W-pVjnmvyuY9y1z65cdUzSXF7wRGHNPhHGofkw@mail.gmail.com>
References: <1507479013-5207-1-git-send-email-yamada.masahiro@socionext.com>
 <1507479013-5207-11-git-send-email-yamada.masahiro@socionext.com>
 <20171008.100013.2081721941420989813.davem@davemloft.net> <CAK7LNAQ1BeSb14poieRU4uMsnsEHPNL2zSNtWi1TGN=YrK_8jA@mail.gmail.com>
 <1507483942.11434.4.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>,
        Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
        Ian Abbott <abbotti-GUHe90Wt2aFaa/9Udqfwiw@public.gmane.org>, Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, yishaih-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
        tariqt-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1507483942.11434.4.camel-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

2017-10-09 2:32 GMT+09:00 Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>:
> On Mon, 2017-10-09 at 02:29 +0900, Masahiro Yamada wrote:
>> The idea is simple; include necessary headers explicitly.
>
> Try that for kernel.h
>
> There's a reason aggregation of #includes is useful.
>


We should use a common sense for the balance between
  - aggregation of #includes
  - reduce the number of parsed headers


As I had already said, if you do not like this change, you can just
throw it away.

That's fine because the impact is very limited.
Honestly, I am not so interested in this driver.
I changed sh,  net/mlx4, net/mlx5, drm/i915 for bonus while I am here.


I assume your objection is addressed to this driver change,
not the whole series.


I am more interested in the global headers like
include/linux/{irqdomain.h, fs.h} etc.


radix-tree-root.h vs radix-tree.h
has a big difference in terms of parsed headers (17 vs 128).

For example, the following is the analysis on arm64.



<linux/radix-tree-root.h> include the following 17 headers:

  include/linux/radix-tree-root.h \
  include/linux/types.h \
  include/uapi/linux/types.h \
  arch/arm64/include/generated/uapi/asm/types.h \
  include/uapi/asm-generic/types.h \
  include/asm-generic/int-ll64.h \
  include/uapi/asm-generic/int-ll64.h \
  arch/arm64/include/uapi/asm/bitsperlong.h \
  include/asm-generic/bitsperlong.h \
  include/uapi/asm-generic/bitsperlong.h \
  include/uapi/linux/posix_types.h \
  include/linux/stddef.h \
  include/uapi/linux/stddef.h \
  include/linux/compiler.h \
  include/linux/compiler-gcc.h \
  arch/arm64/include/uapi/asm/posix_types.h \
  include/uapi/asm-generic/posix_types.h \




<linux/radix-tree.h> include the following 128 headers:

  include/linux/radix-tree.h \
  include/linux/bitops.h \
  arch/arm64/include/generated/uapi/asm/types.h \
  include/uapi/asm-generic/types.h \
  include/asm-generic/int-ll64.h \
  include/uapi/asm-generic/int-ll64.h \
  arch/arm64/include/uapi/asm/bitsperlong.h \
  include/asm-generic/bitsperlong.h \
  include/uapi/asm-generic/bitsperlong.h \
  arch/arm64/include/asm/bitops.h \
  include/linux/compiler.h \
  include/linux/compiler-gcc.h \
  include/uapi/linux/types.h \
  include/uapi/linux/posix_types.h \
  include/linux/stddef.h \
  include/uapi/linux/stddef.h \
  arch/arm64/include/uapi/asm/posix_types.h \
  include/uapi/asm-generic/posix_types.h \
  arch/arm64/include/asm/barrier.h \
  include/asm-generic/barrier.h \
  include/asm-generic/bitops/builtin-__ffs.h \
  include/asm-generic/bitops/builtin-ffs.h \
  include/asm-generic/bitops/builtin-__fls.h \
  include/asm-generic/bitops/builtin-fls.h \
  include/asm-generic/bitops/ffz.h \
  include/asm-generic/bitops/fls64.h \
  include/asm-generic/bitops/find.h \
  include/asm-generic/bitops/sched.h \
  include/asm-generic/bitops/hweight.h \
  include/asm-generic/bitops/arch_hweight.h \
  include/asm-generic/bitops/const_hweight.h \
  include/asm-generic/bitops/lock.h \
  include/asm-generic/bitops/non-atomic.h \
  include/asm-generic/bitops/le.h \
  arch/arm64/include/uapi/asm/byteorder.h \
  include/linux/byteorder/big_endian.h \
  include/uapi/linux/byteorder/big_endian.h \
  include/linux/types.h \
  include/linux/swab.h \
  include/uapi/linux/swab.h \
  arch/arm64/include/generated/uapi/asm/swab.h \
  include/uapi/asm-generic/swab.h \
  include/linux/byteorder/generic.h \
  include/linux/bug.h \
  arch/arm64/include/asm/bug.h \
  include/linux/stringify.h \
  arch/arm64/include/asm/asm-bug.h \
  arch/arm64/include/asm/brk-imm.h \
  include/asm-generic/bug.h \
  include/linux/kernel.h \
  /home/masahiro/toolchains/aarch64-linaro-4.9/gcc-linaro-4.9-2016.02-x86_64_aarch64-linux-gnu/lib/gcc/aarch64-linux-gnu/4.9.4/include/stdarg.h
\
  include/linux/linkage.h \
  include/linux/export.h \
  arch/arm64/include/asm/linkage.h \
  include/linux/log2.h \
  include/linux/typecheck.h \
  include/linux/printk.h \
  include/linux/init.h \
  include/linux/kern_levels.h \
  include/linux/cache.h \
  include/uapi/linux/kernel.h \
  include/uapi/linux/sysinfo.h \
  arch/arm64/include/asm/cache.h \
  arch/arm64/include/asm/cputype.h \
  arch/arm64/include/asm/sysreg.h \
  include/linux/dynamic_debug.h \
  include/linux/jump_label.h \
  arch/arm64/include/asm/jump_label.h \
  arch/arm64/include/asm/insn.h \
  include/linux/build_bug.h \
  include/linux/list.h \
  include/linux/poison.h \
  include/uapi/linux/const.h \
  include/linux/preempt.h \
  arch/arm64/include/generated/asm/preempt.h \
  include/asm-generic/preempt.h \
  include/linux/thread_info.h \
  include/linux/restart_block.h \
  arch/arm64/include/asm/current.h \
  arch/arm64/include/asm/thread_info.h \
  arch/arm64/include/asm/memory.h \
  arch/arm64/include/asm/page-def.h \
  arch/arm64/include/generated/asm/sizes.h \
  include/asm-generic/sizes.h \
  include/linux/sizes.h \
  include/linux/mmdebug.h \
  include/asm-generic/memory_model.h \
  include/linux/pfn.h \
  arch/arm64/include/asm/stack_pointer.h \
  include/linux/radix-tree-root.h \
  include/linux/rcupdate.h \
  include/linux/atomic.h \
  arch/arm64/include/asm/atomic.h \
  arch/arm64/include/asm/lse.h \
  arch/arm64/include/asm/atomic_ll_sc.h \
  arch/arm64/include/asm/cmpxchg.h \
  include/asm-generic/atomic-long.h \
  include/linux/irqflags.h \
  arch/arm64/include/asm/irqflags.h \
  arch/arm64/include/asm/ptrace.h \
  arch/arm64/include/uapi/asm/ptrace.h \
  arch/arm64/include/asm/hwcap.h \
  arch/arm64/include/uapi/asm/hwcap.h \
  include/asm-generic/ptrace.h \
  include/linux/bottom_half.h \
  include/linux/lockdep.h \
  include/linux/debug_locks.h \
  include/linux/stacktrace.h \
  arch/arm64/include/asm/processor.h \
  include/linux/string.h \
  include/uapi/linux/string.h \
  arch/arm64/include/asm/string.h \
  arch/arm64/include/asm/alternative.h \
  arch/arm64/include/asm/cpucaps.h \
  arch/arm64/include/asm/fpsimd.h \
  arch/arm64/include/asm/hw_breakpoint.h \
  arch/arm64/include/asm/cpufeature.h \
  arch/arm64/include/asm/virt.h \
  arch/arm64/include/asm/sections.h \
  include/asm-generic/sections.h \
  arch/arm64/include/asm/pgtable-hwdef.h \
  include/linux/cpumask.h \
  include/linux/threads.h \
  include/linux/bitmap.h \
  include/linux/rcutree.h \
  include/linux/spinlock_types.h \
  arch/arm64/include/asm/spinlock_types.h \
  include/linux/rwlock_types.h \





-- 
Best Regards
Masahiro Yamada
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
