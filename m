From: Will Drewry <wad@chromium.org>
Subject: [PATCH v17 00/15] seccomp_filter: BPF-based syscall filtering
Date: Thu, 29 Mar 2012 15:01:45 -0500
Message-ID: <1333051320-30872-1-git-send-email-wad@chromium.org>
Reply-To: kernel-hardening@lists.openwall.com
Cc: linux-security-module@vger.kernel.org,
	linux-arch@vger.kernel.org,
	linux-doc@vger.kernel.org,
	kernel-hardening@lists.openwall.com,
	netdev@vger.kernel.org,
	x86@kernel.org,
	arnd@arndb.de,
	davem@davemloft.net,
	hpa@zytor.com,
	mingo@redhat.com,
	oleg@redhat.com,
	peterz@infradead.org,
	rdunlap@xenotime.net,
	mcgrathr@chromium.org,
	tglx@linutronix.de,
	luto@mit.edu,
	eparis@redhat.com,
	serge.hallyn@canonical.com,
	djm@mindrot.org,
	scarybeasts@gmail.com,
	indan@nul.nu,
	pmoore@redhat.com,
	akpm@linux-foundation.org,
	corbet@lwn.net,
	eric.dumazet@gmail.com,
	markus@chromium.org,
	coreyb@linux.vnet.ibm.com,
	keescook@chromium.org,
	jmorris@namei.org,
	Will Drewry <wad@chromium.org>
To: linux-kernel@vger.kernel.org
Return-path: <kernel-hardening-return-1173-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
List-Id: netdev.vger.kernel.org

Please see prior revisions for a detailed discussion of this patch
series.

This series is a rebase on to:
  b5174fa3a7f4f8f150bfa3b917c92608953dfa0f
with very minor changes due to rebasing and tweaks noticed by a few
initial users.  (I will rebase again for v3.4-rc1 when that time comes.)

I realize now is a noisy time, but I wanted to get the most current
revision on the list.

As per prior posts, I am now including luto@'s PR_SET_NO_NEW_PRIVS
changes in the series for clarity and ease of testing.  This latest
rebased required required bumping the prctl() numbers for the
NO_NEW_PRIVS work due to the new reaper options.

For those inclined, the whole series can be found here too:
   https://github.com/redpig/linux/tree/seccomp

At this point, I'm not aware of any outstanding concerns, complaints,
etc. If there are any, I'd love to know.

Thanks!
will


Andy Lutomirski (1):
  Add PR_{GET,SET}_NO_NEW_PRIVS to prevent execve from granting privs

John Johansen (1):
  Fix apparmor for PR_{GET,SET}_NO_NEW_PRIVS

Kees Cook (1):
  seccomp: remove duplicated failure logging

Will Drewry (12):
  sk_run_filter: add BPF_S_ANC_SECCOMP_LD_W
  net/compat.c,linux/filter.h: share compat_sock_fprog
  seccomp: kill the seccomp_t typedef
  arch/x86: add syscall_get_arch to syscall.h
  asm/syscall.h: add syscall_get_arch
  seccomp: add system call filtering using BPF
  seccomp: add SECCOMP_RET_ERRNO
  signal, x86: add SIGSYS info and make it synchronous.
  seccomp: Add SECCOMP_RET_TRAP
  ptrace,seccomp: Add PTRACE_SECCOMP support
  x86: Enable HAVE_ARCH_SECCOMP_FILTER
  Documentation: prctl/seccomp_filter

 Documentation/prctl/seccomp_filter.txt |  163 ++++++++++++
 arch/Kconfig                           |   24 ++
 arch/x86/Kconfig                       |    1 +
 arch/x86/ia32/ia32_signal.c            |    4 +
 arch/x86/include/asm/ia32.h            |    6 +
 arch/x86/include/asm/syscall.h         |   23 ++
 arch/x86/kernel/ptrace.c               |    7 +-
 fs/exec.c                              |   10 +-
 include/asm-generic/siginfo.h          |   22 ++
 include/asm-generic/syscall.h          |   14 +
 include/linux/Kbuild                   |    1 +
 include/linux/audit.h                  |    8 +-
 include/linux/filter.h                 |   12 +
 include/linux/prctl.h                  |   15 +
 include/linux/ptrace.h                 |    5 +-
 include/linux/sched.h                  |    4 +-
 include/linux/seccomp.h                |  105 +++++++-
 include/linux/security.h               |    1 +
 kernel/auditsc.c                       |   10 +-
 kernel/fork.c                          |    3 +
 kernel/seccomp.c                       |  447 ++++++++++++++++++++++++++++++--
 kernel/signal.c                        |    9 +-
 kernel/sys.c                           |   12 +-
 net/compat.c                           |    8 -
 net/core/filter.c                      |    6 +
 samples/Makefile                       |    2 +-
 samples/seccomp/Makefile               |   38 +++
 samples/seccomp/bpf-direct.c           |  176 +++++++++++++
 samples/seccomp/bpf-fancy.c            |  102 ++++++++
 samples/seccomp/bpf-helper.c           |   89 +++++++
 samples/seccomp/bpf-helper.h           |  238 +++++++++++++++++
 samples/seccomp/dropper.c              |   68 +++++
 security/apparmor/domain.c             |   35 +++
 security/commoncap.c                   |    7 +-
 security/selinux/hooks.c               |   10 +-
 35 files changed, 1628 insertions(+), 57 deletions(-)
 create mode 100644 Documentation/prctl/seccomp_filter.txt
 create mode 100644 samples/seccomp/Makefile
 create mode 100644 samples/seccomp/bpf-direct.c
 create mode 100644 samples/seccomp/bpf-fancy.c
 create mode 100644 samples/seccomp/bpf-helper.c
 create mode 100644 samples/seccomp/bpf-helper.h
 create mode 100644 samples/seccomp/dropper.c

-- 
1.7.5.4
