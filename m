From: Guenter Roeck <linux@roeck-us.net>
Subject: [PATCH v2 0/8] Drop support for Renesas H8/300 architecture
Date: Fri, 30 Aug 2013 16:51:26 -0700
Message-ID: <1377906694-9578-1-git-send-email-linux@roeck-us.net>
Cc: linux-ide@vger.kernel.org, netdev@vger.kernel.org,
	linux-watchdog@vger.kernel.org, Wim Van Sebroeck <wim@iguana.be>,
	"David S. Miller" <davem@davemloft.net>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Eric Paris <eparis@redhat.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Jiang Liu <jiang.liu@huawei.com>,
	David Howells <dhowells@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Guenter Roeck <linux@roeck-us.net>
To: linux-kernel@vger.kernel.org
Return-path: <linux-ide-owner@vger.kernel.org>
Sender: linux-ide-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

H8/300 has been dead for several years, the kernel for it has
not compiled for ages, and recent versions of gcc for it are broken.
It is time to drop support for it.

Yes, I understand it is not that simple to drop an architecture,
and it may need some discussion, but someone has to put a stake
into the ground. Keeping a virtually dead architecture on life support
takes resources which are better spent elsewhere.

v2:
- s/Renesys/Renesas/g
- Found and removed more architecture specific code in fs/minix
  and in smc9194 driver
- Added explicit Cc: for h8300 maintainer
- Added subsystem maintainer Acks

----------------------------------------------------------------
Guenter Roeck (8):
      Drop support for Renesas H8/300 (h8300) architecture
      ide: Drop H8/300 driver
      net/ethernet: smsc9194: Drop conditional code for H8/300
      net/ethernet: Drop H8/300 Ethernet driver
      watchdog: Drop references to H8300 architecture
      Drop MAINTAINERS entry for H8/300
      Drop remaining references to H8/300 architecture
      fs/minix: Drop dependency on H8300

 Documentation/scheduler/sched-arch.txt           |    5 -
 MAINTAINERS                                      |    8 -
 arch/h8300/Kconfig                               |  109 ----
 arch/h8300/Kconfig.cpu                           |  171 ------
 arch/h8300/Kconfig.debug                         |   68 ---
 arch/h8300/Kconfig.ide                           |   44 --
 arch/h8300/Makefile                              |   71 ---
 arch/h8300/README                                |   38 --
 arch/h8300/boot/Makefile                         |   22 -
 arch/h8300/boot/compressed/Makefile              |   37 --
 arch/h8300/boot/compressed/head.S                |   47 --
 arch/h8300/boot/compressed/misc.c                |  180 ------
 arch/h8300/boot/compressed/vmlinux.lds           |   32 -
 arch/h8300/boot/compressed/vmlinux.scr           |    9 -
 arch/h8300/defconfig                             |   42 --
 arch/h8300/include/asm/Kbuild                    |    8 -
 arch/h8300/include/asm/asm-offsets.h             |    1 -
 arch/h8300/include/asm/atomic.h                  |  146 -----
 arch/h8300/include/asm/barrier.h                 |   29 -
 arch/h8300/include/asm/bitops.h                  |  211 -------
 arch/h8300/include/asm/bootinfo.h                |    2 -
 arch/h8300/include/asm/bug.h                     |   12 -
 arch/h8300/include/asm/bugs.h                    |   16 -
 arch/h8300/include/asm/cache.h                   |   13 -
 arch/h8300/include/asm/cachectl.h                |   14 -
 arch/h8300/include/asm/cacheflush.h              |   40 --
 arch/h8300/include/asm/checksum.h                |  102 ----
 arch/h8300/include/asm/cmpxchg.h                 |   60 --
 arch/h8300/include/asm/cputime.h                 |    6 -
 arch/h8300/include/asm/current.h                 |   25 -
 arch/h8300/include/asm/dbg.h                     |    2 -
 arch/h8300/include/asm/delay.h                   |   38 --
 arch/h8300/include/asm/device.h                  |    7 -
 arch/h8300/include/asm/div64.h                   |    1 -
 arch/h8300/include/asm/dma.h                     |   15 -
 arch/h8300/include/asm/elf.h                     |  101 ----
 arch/h8300/include/asm/emergency-restart.h       |    6 -
 arch/h8300/include/asm/fb.h                      |   12 -
 arch/h8300/include/asm/flat.h                    |   26 -
 arch/h8300/include/asm/fpu.h                     |    1 -
 arch/h8300/include/asm/ftrace.h                  |    1 -
 arch/h8300/include/asm/futex.h                   |    6 -
 arch/h8300/include/asm/gpio-internal.h           |   52 --
 arch/h8300/include/asm/hardirq.h                 |   19 -
 arch/h8300/include/asm/hw_irq.h                  |    1 -
 arch/h8300/include/asm/io.h                      |  358 -----------
 arch/h8300/include/asm/irq.h                     |   49 --
 arch/h8300/include/asm/irq_regs.h                |    1 -
 arch/h8300/include/asm/irqflags.h                |   43 --
 arch/h8300/include/asm/kdebug.h                  |    1 -
 arch/h8300/include/asm/kmap_types.h              |    6 -
 arch/h8300/include/asm/local.h                   |    6 -
 arch/h8300/include/asm/local64.h                 |    1 -
 arch/h8300/include/asm/mc146818rtc.h             |    9 -
 arch/h8300/include/asm/mmu_context.h             |   32 -
 arch/h8300/include/asm/mutex.h                   |    9 -
 arch/h8300/include/asm/page.h                    |   78 ---
 arch/h8300/include/asm/page_offset.h             |    3 -
 arch/h8300/include/asm/param.h                   |    9 -
 arch/h8300/include/asm/pci.h                     |   19 -
 arch/h8300/include/asm/percpu.h                  |    6 -
 arch/h8300/include/asm/pgalloc.h                 |    8 -
 arch/h8300/include/asm/pgtable.h                 |   73 ---
 arch/h8300/include/asm/processor.h               |  139 -----
 arch/h8300/include/asm/ptrace.h                  |   33 --
 arch/h8300/include/asm/regs267x.h                |  336 -----------
 arch/h8300/include/asm/regs306x.h                |  212 -------
 arch/h8300/include/asm/scatterlist.h             |    6 -
 arch/h8300/include/asm/sections.h                |    6 -
 arch/h8300/include/asm/segment.h                 |   49 --
 arch/h8300/include/asm/sh_bios.h                 |   29 -
 arch/h8300/include/asm/shm.h                     |   31 -
 arch/h8300/include/asm/shmparam.h                |    6 -
 arch/h8300/include/asm/signal.h                  |   24 -
 arch/h8300/include/asm/smp.h                     |    1 -
 arch/h8300/include/asm/spinlock.h                |    6 -
 arch/h8300/include/asm/string.h                  |   44 --
 arch/h8300/include/asm/switch_to.h               |   50 --
 arch/h8300/include/asm/target_time.h             |    4 -
 arch/h8300/include/asm/termios.h                 |   50 --
 arch/h8300/include/asm/thread_info.h             |  103 ----
 arch/h8300/include/asm/timer.h                   |   25 -
 arch/h8300/include/asm/timex.h                   |   19 -
 arch/h8300/include/asm/tlb.h                     |    8 -
 arch/h8300/include/asm/tlbflush.h                |   55 --
 arch/h8300/include/asm/topology.h                |    6 -
 arch/h8300/include/asm/traps.h                   |   37 --
 arch/h8300/include/asm/types.h                   |    9 -
 arch/h8300/include/asm/uaccess.h                 |  163 ------
 arch/h8300/include/asm/ucontext.h                |   12 -
 arch/h8300/include/asm/unaligned.h               |   11 -
 arch/h8300/include/asm/unistd.h                  |   36 --
 arch/h8300/include/asm/user.h                    |   75 ---
 arch/h8300/include/asm/virtconvert.h             |   20 -
 arch/h8300/include/uapi/asm/Kbuild               |   34 --
 arch/h8300/include/uapi/asm/auxvec.h             |    4 -
 arch/h8300/include/uapi/asm/bitsperlong.h        |    1 -
 arch/h8300/include/uapi/asm/byteorder.h          |    6 -
 arch/h8300/include/uapi/asm/errno.h              |    6 -
 arch/h8300/include/uapi/asm/fcntl.h              |   11 -
 arch/h8300/include/uapi/asm/ioctl.h              |    1 -
 arch/h8300/include/uapi/asm/ioctls.h             |    8 -
 arch/h8300/include/uapi/asm/ipcbuf.h             |    1 -
 arch/h8300/include/uapi/asm/kvm_para.h           |    1 -
 arch/h8300/include/uapi/asm/mman.h               |    1 -
 arch/h8300/include/uapi/asm/msgbuf.h             |   31 -
 arch/h8300/include/uapi/asm/param.h              |   16 -
 arch/h8300/include/uapi/asm/poll.h               |   11 -
 arch/h8300/include/uapi/asm/posix_types.h        |   26 -
 arch/h8300/include/uapi/asm/ptrace.h             |   44 --
 arch/h8300/include/uapi/asm/resource.h           |    6 -
 arch/h8300/include/uapi/asm/sembuf.h             |   25 -
 arch/h8300/include/uapi/asm/setup.h              |    6 -
 arch/h8300/include/uapi/asm/shmbuf.h             |   42 --
 arch/h8300/include/uapi/asm/sigcontext.h         |   18 -
 arch/h8300/include/uapi/asm/siginfo.h            |    6 -
 arch/h8300/include/uapi/asm/signal.h             |  115 ----
 arch/h8300/include/uapi/asm/socket.h             |   79 ---
 arch/h8300/include/uapi/asm/sockios.h            |   13 -
 arch/h8300/include/uapi/asm/stat.h               |   78 ---
 arch/h8300/include/uapi/asm/statfs.h             |    6 -
 arch/h8300/include/uapi/asm/swab.h               |   10 -
 arch/h8300/include/uapi/asm/termbits.h           |  201 -------
 arch/h8300/include/uapi/asm/termios.h            |   44 --
 arch/h8300/include/uapi/asm/types.h              |    1 -
 arch/h8300/include/uapi/asm/unistd.h             |  330 -----------
 arch/h8300/kernel/Makefile                       |   12 -
 arch/h8300/kernel/asm-offsets.c                  |   60 --
 arch/h8300/kernel/entry.S                        |  402 -------------
 arch/h8300/kernel/gpio.c                         |  178 ------
 arch/h8300/kernel/h8300_ksyms.c                  |  100 ----
 arch/h8300/kernel/irq.c                          |  165 ------
 arch/h8300/kernel/module.c                       |   75 ---
 arch/h8300/kernel/process.c                      |  154 -----
 arch/h8300/kernel/ptrace.c                       |  168 ------
 arch/h8300/kernel/setup.c                        |  242 --------
 arch/h8300/kernel/signal.c                       |  444 --------------
 arch/h8300/kernel/sys_h8300.c                    |   48 --
 arch/h8300/kernel/syscalls.S                     |  338 -----------
 arch/h8300/kernel/time.c                         |   66 ---
 arch/h8300/kernel/timer/Makefile                 |    6 -
 arch/h8300/kernel/timer/itu.c                    |   82 ---
 arch/h8300/kernel/timer/timer16.c                |   77 ---
 arch/h8300/kernel/timer/timer8.c                 |  102 ----
 arch/h8300/kernel/timer/tpu.c                    |  100 ----
 arch/h8300/kernel/traps.c                        |  166 ------
 arch/h8300/kernel/vmlinux.lds.S                  |  157 -----
 arch/h8300/lib/Makefile                          |    5 -
 arch/h8300/lib/abs.S                             |   21 -
 arch/h8300/lib/ashrdi3.c                         |   63 --
 arch/h8300/lib/checksum.c                        |  164 ------
 arch/h8300/lib/memcpy.S                          |   84 ---
 arch/h8300/lib/memset.S                          |   61 --
 arch/h8300/lib/romfs.S                           |   57 --
 arch/h8300/mm/Makefile                           |    5 -
 arch/h8300/mm/fault.c                            |   56 --
 arch/h8300/mm/init.c                             |  155 -----
 arch/h8300/mm/kmap.c                             |   58 --
 arch/h8300/mm/memory.c                           |   54 --
 arch/h8300/platform/h8300h/Makefile              |    7 -
 arch/h8300/platform/h8300h/aki3068net/Makefile   |    5 -
 arch/h8300/platform/h8300h/aki3068net/crt0_ram.S |  110 ----
 arch/h8300/platform/h8300h/generic/Makefile      |    5 -
 arch/h8300/platform/h8300h/generic/crt0_ram.S    |  107 ----
 arch/h8300/platform/h8300h/generic/crt0_rom.S    |  122 ----
 arch/h8300/platform/h8300h/h8max/Makefile        |    5 -
 arch/h8300/platform/h8300h/h8max/crt0_ram.S      |  110 ----
 arch/h8300/platform/h8300h/irq.c                 |   82 ---
 arch/h8300/platform/h8300h/ptrace_h8300h.c       |  284 ---------
 arch/h8300/platform/h8s/Makefile                 |    7 -
 arch/h8300/platform/h8s/edosk2674/Makefile       |    5 -
 arch/h8300/platform/h8s/edosk2674/crt0_ram.S     |  130 ----
 arch/h8300/platform/h8s/edosk2674/crt0_rom.S     |  186 ------
 arch/h8300/platform/h8s/generic/Makefile         |    5 -
 arch/h8300/platform/h8s/generic/crt0_ram.S       |  127 ----
 arch/h8300/platform/h8s/generic/crt0_rom.S       |  128 ----
 arch/h8300/platform/h8s/irq.c                    |  104 ----
 arch/h8300/platform/h8s/ptrace_h8s.c             |   84 ---
 drivers/ide/Kconfig                              |    7 -
 drivers/ide/Makefile                             |    2 -
 drivers/ide/ide-h8300.c                          |  109 ----
 drivers/net/Space.c                              |    3 +-
 drivers/net/ethernet/8390/Kconfig                |    7 -
 drivers/net/ethernet/8390/Makefile               |    1 -
 drivers/net/ethernet/8390/ne-h8300.c             |  684 ----------------------
 drivers/net/ethernet/smsc/smc9194.c              |   24 -
 drivers/watchdog/Kconfig                         |    2 -
 drivers/watchdog/Makefile                        |    2 -
 fs/minix/Kconfig                                 |    2 +-
 include/linux/serial_sci.h                       |    2 +-
 include/uapi/linux/audit.h                       |    1 -
 include/uapi/linux/elf-em.h                      |    1 -
 tools/testing/ktest/examples/crosstests.conf     |    6 -
 193 files changed, 3 insertions(+), 11742 deletions(-)
 delete mode 100644 arch/h8300/Kconfig
 delete mode 100644 arch/h8300/Kconfig.cpu
 delete mode 100644 arch/h8300/Kconfig.debug
 delete mode 100644 arch/h8300/Kconfig.ide
 delete mode 100644 arch/h8300/Makefile
 delete mode 100644 arch/h8300/README
 delete mode 100644 arch/h8300/boot/Makefile
 delete mode 100644 arch/h8300/boot/compressed/Makefile
 delete mode 100644 arch/h8300/boot/compressed/head.S
 delete mode 100644 arch/h8300/boot/compressed/misc.c
 delete mode 100644 arch/h8300/boot/compressed/vmlinux.lds
 delete mode 100644 arch/h8300/boot/compressed/vmlinux.scr
 delete mode 100644 arch/h8300/defconfig
 delete mode 100644 arch/h8300/include/asm/Kbuild
 delete mode 100644 arch/h8300/include/asm/asm-offsets.h
 delete mode 100644 arch/h8300/include/asm/atomic.h
 delete mode 100644 arch/h8300/include/asm/barrier.h
 delete mode 100644 arch/h8300/include/asm/bitops.h
 delete mode 100644 arch/h8300/include/asm/bootinfo.h
 delete mode 100644 arch/h8300/include/asm/bug.h
 delete mode 100644 arch/h8300/include/asm/bugs.h
 delete mode 100644 arch/h8300/include/asm/cache.h
 delete mode 100644 arch/h8300/include/asm/cachectl.h
 delete mode 100644 arch/h8300/include/asm/cacheflush.h
 delete mode 100644 arch/h8300/include/asm/checksum.h
 delete mode 100644 arch/h8300/include/asm/cmpxchg.h
 delete mode 100644 arch/h8300/include/asm/cputime.h
 delete mode 100644 arch/h8300/include/asm/current.h
 delete mode 100644 arch/h8300/include/asm/dbg.h
 delete mode 100644 arch/h8300/include/asm/delay.h
 delete mode 100644 arch/h8300/include/asm/device.h
 delete mode 100644 arch/h8300/include/asm/div64.h
 delete mode 100644 arch/h8300/include/asm/dma.h
 delete mode 100644 arch/h8300/include/asm/elf.h
 delete mode 100644 arch/h8300/include/asm/emergency-restart.h
 delete mode 100644 arch/h8300/include/asm/fb.h
 delete mode 100644 arch/h8300/include/asm/flat.h
 delete mode 100644 arch/h8300/include/asm/fpu.h
 delete mode 100644 arch/h8300/include/asm/ftrace.h
 delete mode 100644 arch/h8300/include/asm/futex.h
 delete mode 100644 arch/h8300/include/asm/gpio-internal.h
 delete mode 100644 arch/h8300/include/asm/hardirq.h
 delete mode 100644 arch/h8300/include/asm/hw_irq.h
 delete mode 100644 arch/h8300/include/asm/io.h
 delete mode 100644 arch/h8300/include/asm/irq.h
 delete mode 100644 arch/h8300/include/asm/irq_regs.h
 delete mode 100644 arch/h8300/include/asm/irqflags.h
 delete mode 100644 arch/h8300/include/asm/kdebug.h
 delete mode 100644 arch/h8300/include/asm/kmap_types.h
 delete mode 100644 arch/h8300/include/asm/local.h
 delete mode 100644 arch/h8300/include/asm/local64.h
 delete mode 100644 arch/h8300/include/asm/mc146818rtc.h
 delete mode 100644 arch/h8300/include/asm/mmu_context.h
 delete mode 100644 arch/h8300/include/asm/mutex.h
 delete mode 100644 arch/h8300/include/asm/page.h
 delete mode 100644 arch/h8300/include/asm/page_offset.h
 delete mode 100644 arch/h8300/include/asm/param.h
 delete mode 100644 arch/h8300/include/asm/pci.h
 delete mode 100644 arch/h8300/include/asm/percpu.h
 delete mode 100644 arch/h8300/include/asm/pgalloc.h
 delete mode 100644 arch/h8300/include/asm/pgtable.h
 delete mode 100644 arch/h8300/include/asm/processor.h
 delete mode 100644 arch/h8300/include/asm/ptrace.h
 delete mode 100644 arch/h8300/include/asm/regs267x.h
 delete mode 100644 arch/h8300/include/asm/regs306x.h
 delete mode 100644 arch/h8300/include/asm/scatterlist.h
 delete mode 100644 arch/h8300/include/asm/sections.h
 delete mode 100644 arch/h8300/include/asm/segment.h
 delete mode 100644 arch/h8300/include/asm/sh_bios.h
 delete mode 100644 arch/h8300/include/asm/shm.h
 delete mode 100644 arch/h8300/include/asm/shmparam.h
 delete mode 100644 arch/h8300/include/asm/signal.h
 delete mode 100644 arch/h8300/include/asm/smp.h
 delete mode 100644 arch/h8300/include/asm/spinlock.h
 delete mode 100644 arch/h8300/include/asm/string.h
 delete mode 100644 arch/h8300/include/asm/switch_to.h
 delete mode 100644 arch/h8300/include/asm/target_time.h
 delete mode 100644 arch/h8300/include/asm/termios.h
 delete mode 100644 arch/h8300/include/asm/thread_info.h
 delete mode 100644 arch/h8300/include/asm/timer.h
 delete mode 100644 arch/h8300/include/asm/timex.h
 delete mode 100644 arch/h8300/include/asm/tlb.h
 delete mode 100644 arch/h8300/include/asm/tlbflush.h
 delete mode 100644 arch/h8300/include/asm/topology.h
 delete mode 100644 arch/h8300/include/asm/traps.h
 delete mode 100644 arch/h8300/include/asm/types.h
 delete mode 100644 arch/h8300/include/asm/uaccess.h
 delete mode 100644 arch/h8300/include/asm/ucontext.h
 delete mode 100644 arch/h8300/include/asm/unaligned.h
 delete mode 100644 arch/h8300/include/asm/unistd.h
 delete mode 100644 arch/h8300/include/asm/user.h
 delete mode 100644 arch/h8300/include/asm/virtconvert.h
 delete mode 100644 arch/h8300/include/uapi/asm/Kbuild
 delete mode 100644 arch/h8300/include/uapi/asm/auxvec.h
 delete mode 100644 arch/h8300/include/uapi/asm/bitsperlong.h
 delete mode 100644 arch/h8300/include/uapi/asm/byteorder.h
 delete mode 100644 arch/h8300/include/uapi/asm/errno.h
 delete mode 100644 arch/h8300/include/uapi/asm/fcntl.h
 delete mode 100644 arch/h8300/include/uapi/asm/ioctl.h
 delete mode 100644 arch/h8300/include/uapi/asm/ioctls.h
 delete mode 100644 arch/h8300/include/uapi/asm/ipcbuf.h
 delete mode 100644 arch/h8300/include/uapi/asm/kvm_para.h
 delete mode 100644 arch/h8300/include/uapi/asm/mman.h
 delete mode 100644 arch/h8300/include/uapi/asm/msgbuf.h
 delete mode 100644 arch/h8300/include/uapi/asm/param.h
 delete mode 100644 arch/h8300/include/uapi/asm/poll.h
 delete mode 100644 arch/h8300/include/uapi/asm/posix_types.h
 delete mode 100644 arch/h8300/include/uapi/asm/ptrace.h
 delete mode 100644 arch/h8300/include/uapi/asm/resource.h
 delete mode 100644 arch/h8300/include/uapi/asm/sembuf.h
 delete mode 100644 arch/h8300/include/uapi/asm/setup.h
 delete mode 100644 arch/h8300/include/uapi/asm/shmbuf.h
 delete mode 100644 arch/h8300/include/uapi/asm/sigcontext.h
 delete mode 100644 arch/h8300/include/uapi/asm/siginfo.h
 delete mode 100644 arch/h8300/include/uapi/asm/signal.h
 delete mode 100644 arch/h8300/include/uapi/asm/socket.h
 delete mode 100644 arch/h8300/include/uapi/asm/sockios.h
 delete mode 100644 arch/h8300/include/uapi/asm/stat.h
 delete mode 100644 arch/h8300/include/uapi/asm/statfs.h
 delete mode 100644 arch/h8300/include/uapi/asm/swab.h
 delete mode 100644 arch/h8300/include/uapi/asm/termbits.h
 delete mode 100644 arch/h8300/include/uapi/asm/termios.h
 delete mode 100644 arch/h8300/include/uapi/asm/types.h
 delete mode 100644 arch/h8300/include/uapi/asm/unistd.h
 delete mode 100644 arch/h8300/kernel/Makefile
 delete mode 100644 arch/h8300/kernel/asm-offsets.c
 delete mode 100644 arch/h8300/kernel/entry.S
 delete mode 100644 arch/h8300/kernel/gpio.c
 delete mode 100644 arch/h8300/kernel/h8300_ksyms.c
 delete mode 100644 arch/h8300/kernel/irq.c
 delete mode 100644 arch/h8300/kernel/module.c
 delete mode 100644 arch/h8300/kernel/process.c
 delete mode 100644 arch/h8300/kernel/ptrace.c
 delete mode 100644 arch/h8300/kernel/setup.c
 delete mode 100644 arch/h8300/kernel/signal.c
 delete mode 100644 arch/h8300/kernel/sys_h8300.c
 delete mode 100644 arch/h8300/kernel/syscalls.S
 delete mode 100644 arch/h8300/kernel/time.c
 delete mode 100644 arch/h8300/kernel/timer/Makefile
 delete mode 100644 arch/h8300/kernel/timer/itu.c
 delete mode 100644 arch/h8300/kernel/timer/timer16.c
 delete mode 100644 arch/h8300/kernel/timer/timer8.c
 delete mode 100644 arch/h8300/kernel/timer/tpu.c
 delete mode 100644 arch/h8300/kernel/traps.c
 delete mode 100644 arch/h8300/kernel/vmlinux.lds.S
 delete mode 100644 arch/h8300/lib/Makefile
 delete mode 100644 arch/h8300/lib/abs.S
 delete mode 100644 arch/h8300/lib/ashrdi3.c
 delete mode 100644 arch/h8300/lib/checksum.c
 delete mode 100644 arch/h8300/lib/memcpy.S
 delete mode 100644 arch/h8300/lib/memset.S
 delete mode 100644 arch/h8300/lib/romfs.S
 delete mode 100644 arch/h8300/mm/Makefile
 delete mode 100644 arch/h8300/mm/fault.c
 delete mode 100644 arch/h8300/mm/init.c
 delete mode 100644 arch/h8300/mm/kmap.c
 delete mode 100644 arch/h8300/mm/memory.c
 delete mode 100644 arch/h8300/platform/h8300h/Makefile
 delete mode 100644 arch/h8300/platform/h8300h/aki3068net/Makefile
 delete mode 100644 arch/h8300/platform/h8300h/aki3068net/crt0_ram.S
 delete mode 100644 arch/h8300/platform/h8300h/generic/Makefile
 delete mode 100644 arch/h8300/platform/h8300h/generic/crt0_ram.S
 delete mode 100644 arch/h8300/platform/h8300h/generic/crt0_rom.S
 delete mode 100644 arch/h8300/platform/h8300h/h8max/Makefile
 delete mode 100644 arch/h8300/platform/h8300h/h8max/crt0_ram.S
 delete mode 100644 arch/h8300/platform/h8300h/irq.c
 delete mode 100644 arch/h8300/platform/h8300h/ptrace_h8300h.c
 delete mode 100644 arch/h8300/platform/h8s/Makefile
 delete mode 100644 arch/h8300/platform/h8s/edosk2674/Makefile
 delete mode 100644 arch/h8300/platform/h8s/edosk2674/crt0_ram.S
 delete mode 100644 arch/h8300/platform/h8s/edosk2674/crt0_rom.S
 delete mode 100644 arch/h8300/platform/h8s/generic/Makefile
 delete mode 100644 arch/h8300/platform/h8s/generic/crt0_ram.S
 delete mode 100644 arch/h8300/platform/h8s/generic/crt0_rom.S
 delete mode 100644 arch/h8300/platform/h8s/irq.c
 delete mode 100644 arch/h8300/platform/h8s/ptrace_h8s.c
 delete mode 100644 drivers/ide/ide-h8300.c
 delete mode 100644 drivers/net/ethernet/8390/ne-h8300.c
