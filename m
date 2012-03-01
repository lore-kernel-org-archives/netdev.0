From: Kees Cook <keescook@chromium.org>
Subject: Re: [PATCH v12 01/13] sk_run_filter: add support for custom
 load_pointer
Date: Thu, 1 Mar 2012 15:37:12 -0800
Message-ID: <20120301233712.GS3990@outflux.net>
References: <1330559620-23543-1-git-send-email-wad@chromium.org>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Will Drewry <wad@chromium.org>, linux-kernel@vger.kernel.org,
        linux-arch@vger.kernel.org, linux-doc@vger.kernel.org,
        kernel-hardening@lists.openwall.com, netdev@vger.kernel.org,
        x86@kernel.org, arnd@arndb.de, davem@davemloft.net, hpa@zytor.com,
        mingo@redhat.com, oleg@redhat.com, peterz@infradead.org,
        rdunlap@xenotime.net, mcgrathr@chromium.org, tglx@linutronix.de,
        luto@mit.edu, eparis@redhat.com, serge.hallyn@canonical.com,
        djm@mindrot.org, scarybeasts@gmail.com, indan@nul.nu,
        pmoore@redhat.com, corbet@lwn.net, eric.dumazet@gmail.com,
        markus@chromium.org, coreyb@linux.vnet.ibm.com
To: akpm@linux-foundation.org, sfr@canb.auug.org.au
Return-path: <kernel-hardening-return-1019-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
Content-Disposition: inline
In-Reply-To: <1330559620-23543-1-git-send-email-wad@chromium.org>
List-Id: netdev.vger.kernel.org

Hi,

So far, it looks like everyone who spoke up is satisfied with this patch
series. Or their MUAs got caught up on a leap-year bug and missed the
posting. ;)

Is it time to pull this into -next so more people can feel it? I brought
Andy Lutomirski's patches forward (needed to bump the prctl values), and
updated my git tree. If we're ready, here it is in all its request-pull
format glory:

The following changes since commit 2422c8368337196594265d52cad7316c9404bfcf:
  Stephen Rothwell (1):
        Add linux-next specific files for 20120301

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/kees/linux.git seccomp

Andy Lutomirski (1):
      Add PR_{GET,SET}_NO_NEW_PRIVS to prevent execve from granting privs

John Johansen (1):
      Fix apparmor for PR_{GET,SET}_NO_NEW_PRIVS

Kees Cook (1):
      seccomp: remove duplicated failure logging

Will Drewry (12):
      sk_run_filter: add support for custom load_pointer
      net/compat.c,linux/filter.h: share compat_sock_fprog
      seccomp: kill the seccomp_t typedef
      asm/syscall.h: add syscall_get_arch
      arch/x86: add syscall_get_arch to syscall.h
      seccomp: add system call filtering using BPF
      seccomp: add SECCOMP_RET_ERRNO
      signal, x86: add SIGSYS info and make it synchronous.
      seccomp: Add SECCOMP_RET_TRAP
      ptrace,seccomp: Add PTRACE_SECCOMP support
      x86: Enable HAVE_ARCH_SECCOMP_FILTER
      Documentation: prctl/seccomp_filter

 Documentation/prctl/seccomp_filter.txt |  156 +++++++++++++
 arch/Kconfig                           |   24 ++
 arch/x86/Kconfig                       |    1 +
 arch/x86/ia32/ia32_signal.c            |    4 +
 arch/x86/include/asm/ia32.h            |    6 +
 arch/x86/include/asm/syscall.h         |   23 ++
 arch/x86/kernel/ptrace.c               |    7 +-
 fs/exec.c                              |   10 +-
 include/asm-generic/siginfo.h          |   22 ++
 include/asm-generic/syscall.h          |   14 ++
 include/linux/Kbuild                   |    1 +
 include/linux/audit.h                  |    8 +-
 include/linux/filter.h                 |   57 +++++
 include/linux/prctl.h                  |   15 ++
 include/linux/ptrace.h                 |    5 +-
 include/linux/sched.h                  |    4 +-
 include/linux/seccomp.h                |   99 +++++++-
 include/linux/security.h               |    1 +
 kernel/auditsc.c                       |    9 +-
 kernel/fork.c                          |    3 +
 kernel/seccomp.c                       |  378 ++++++++++++++++++++++++++++++--
 kernel/signal.c                        |    9 +-
 kernel/sys.c                           |   12 +-
 net/compat.c                           |    8 -
 net/core/filter.c                      |  117 ++++++++++-
 samples/Makefile                       |    2 +-
 samples/seccomp/Makefile               |   38 ++++
 samples/seccomp/bpf-direct.c           |  176 +++++++++++++++
 samples/seccomp/bpf-fancy.c            |  102 +++++++++
 samples/seccomp/bpf-helper.c           |   89 ++++++++
 samples/seccomp/bpf-helper.h           |  238 ++++++++++++++++++++
 samples/seccomp/dropper.c              |   68 ++++++
 security/apparmor/domain.c             |   35 +++
 security/commoncap.c                   |    7 +-
 security/selinux/hooks.c               |   10 +-
 35 files changed, 1695 insertions(+), 63 deletions(-)
 create mode 100644 Documentation/prctl/seccomp_filter.txt
 create mode 100644 samples/seccomp/Makefile
 create mode 100644 samples/seccomp/bpf-direct.c
 create mode 100644 samples/seccomp/bpf-fancy.c
 create mode 100644 samples/seccomp/bpf-helper.c
 create mode 100644 samples/seccomp/bpf-helper.h
 create mode 100644 samples/seccomp/dropper.c


-- 
Kees Cook
ChromeOS Security
