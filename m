From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [GIT PULL] Namespace file descriptors for 2.6.40
Date: Sat, 21 May 2011 16:39:13 -0700
Message-ID: <m11uzrvd26.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <linux-kernel@vger.kernel.org>,
	Linux Containers <containers@lists.osdl.org>,
	<netdev@vger.kernel.org>,
	James Bottomley <James.Bottomley@HansenPartnership.com>,
	Geert Uytterhoeven <geert@linux-m68k.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:44415 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750963Ab1EUXjY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 May 2011 19:39:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Please pull the namespace file descriptor git tree from:

   git://git.kernel.org/pub/scm/linux/kernel/git/ebiederm/linux-2.6-nsfd.git

In a hopeless quest to avoid conflicts when merging a new system call
and wiring it up I have pulled in bits of net-next and the parisc tree.
You have already pulled the net-next bits.  The parisc bits in my tree
are:

James Bottomley (4):
      [PARISC] wire up fanotify syscalls
      [PARISC] wire up clock_adjtime syscall
      [PARISC] wire up the fhandle syscalls
      [PARISC] wire up syncfs syscall

Meelis Roos (1):
      [PARISC] fix pacache .size with new binutils

Since then I have gained conflicts in alpha and m68k.
For alpha all that is needed is a simple incrementing of
the syscall number in my tree and adding of my syscall to
the end of the list.

For m68k please just delete all of the syscall entries the conflict will
add to arch/m68k/kernel/entry_mm.S.  The m68k tree has consolidated
everything in arch/m68k/kernel/syscalltable.S


This tree adds the files /proc/<pid>/ns/net, /proc/<pid>/ns/ipc,
/proc/<pid>/ns/uts that can be opened to refer to the namespaces of a
process at the time those files are opened, and can be bind mounted to
keep the specified namespace alive without a process.

This tree adds the setns system call that can be used to change the
specified namespace of a process to the namespace specified by a system
call.

This tree adds a new rtnetlink attribute that allows for moving a
network device into a network namespace specified by a file descriptor.

Support for the other namespaces is planned but is not ready for 2.6.40.

These changes dramatically simplify what a userspace process has to do
to keep a namespace alive, and to execute system calls in it.

The shortlog:

Stephen Rothwell (1):
      net: fix get_net_ns_by_fd for !CONFIG_NET_NS

Eric W. Biederman (11):
      ns: proc files for namespace naming policy.
      ns: Introduce the setns syscall
      ns proc: Add support for the network namespace.
      ns proc: Add support for the uts namespace
      ns proc: Add support for the ipc namespace
      net: Allow setting the network namespace by fd
      Merge commit '2e7bad5f34b5beed47542490c760ed26574e38ba' into HEAD
      Merge commit '7143b7d41218d4fc2ea33e6056c73609527ae687' into HEAD
      ns: Wire up the setns system call
      ns: Declare sys_setns in syscalls.h
      ns proc: Return -ENOENT for a nonexistent /proc/self/ns/ entry.

The diffstat:

 arch/alpha/include/asm/unistd.h        |    3 +-
 arch/alpha/kernel/systbls.S            |    1 +
 arch/arm/include/asm/unistd.h          |    1 +
 arch/arm/kernel/calls.S                |    1 +
 arch/avr32/include/asm/unistd.h        |    3 +-
 arch/avr32/kernel/syscall_table.S      |    1 +
 arch/blackfin/include/asm/unistd.h     |    3 +-
 arch/blackfin/mach-common/entry.S      |    1 +
 arch/cris/arch-v10/kernel/entry.S      |    1 +
 arch/cris/arch-v32/kernel/entry.S      |    1 +
 arch/cris/include/asm/unistd.h         |    3 +-
 arch/frv/include/asm/unistd.h          |    3 +-
 arch/frv/kernel/entry.S                |    1 +
 arch/h8300/include/asm/unistd.h        |    3 +-
 arch/h8300/kernel/syscalls.S           |    1 +
 arch/ia64/include/asm/unistd.h         |    3 +-
 arch/ia64/kernel/entry.S               |    1 +
 arch/m32r/include/asm/unistd.h         |    3 +-
 arch/m32r/kernel/syscall_table.S       |    1 +
 arch/m68k/include/asm/unistd.h         |    3 +-
 arch/m68k/kernel/syscalltable.S        |    1 +
 arch/microblaze/include/asm/unistd.h   |    3 +-
 arch/microblaze/kernel/syscall_table.S |    1 +
 arch/mips/include/asm/unistd.h         |   15 ++-
 arch/mips/kernel/scall32-o32.S         |    1 +
 arch/mips/kernel/scall64-64.S          |    1 +
 arch/mips/kernel/scall64-n32.S         |    1 +
 arch/mips/kernel/scall64-o32.S         |    1 +
 arch/mn10300/include/asm/unistd.h      |    3 +-
 arch/mn10300/kernel/entry.S            |    1 +
 arch/parisc/include/asm/unistd.h       |   10 ++-
 arch/parisc/kernel/pacache.S           |    6 +-
 arch/parisc/kernel/sys_parisc32.c      |    8 ++
 arch/parisc/kernel/syscall_table.S     |    7 +
 arch/powerpc/include/asm/systbl.h      |    1 +
 arch/powerpc/include/asm/unistd.h      |    3 +-
 arch/s390/include/asm/unistd.h         |    3 +-
 arch/s390/kernel/syscalls.S            |    1 +
 arch/sh/include/asm/unistd_32.h        |    3 +-
 arch/sh/include/asm/unistd_64.h        |    3 +-
 arch/sh/kernel/syscalls_32.S           |    1 +
 arch/sh/kernel/syscalls_64.S           |    1 +
 arch/sparc/include/asm/unistd.h        |    3 +-
 arch/sparc/kernel/systbls_32.S         |    2 +-
 arch/sparc/kernel/systbls_64.S         |    4 +-
 arch/x86/ia32/ia32entry.S              |    1 +
 arch/x86/include/asm/unistd_32.h       |    3 +-
 arch/x86/include/asm/unistd_64.h       |    2 +
 arch/x86/kernel/syscall_table_32.S     |    1 +
 arch/xtensa/include/asm/unistd.h       |    4 +-
 fs/proc/Makefile                       |    1 +
 fs/proc/base.c                         |   20 ++--
 fs/proc/inode.c                        |    7 +
 fs/proc/internal.h                     |   18 +++
 fs/proc/namespaces.c                   |  198 ++++++++++++++++++++++++++++++++
 include/asm-generic/unistd.h           |    4 +-
 include/linux/if_link.h                |    1 +
 include/linux/proc_fs.h                |   21 ++++
 include/linux/syscalls.h               |    1 +
 include/net/net_namespace.h            |    1 +
 ipc/namespace.c                        |   37 ++++++
 kernel/nsproxy.c                       |   42 +++++++
 kernel/utsname.c                       |   39 ++++++
 net/core/net_namespace.c               |   65 +++++++++++
 net/core/rtnetlink.c                   |    5 +-
 65 files changed, 547 insertions(+), 46 deletions(-)

Thanks,
Eric
