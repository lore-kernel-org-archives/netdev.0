From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [RFC v2 00/10] Landlock LSM: Unprivileged sandboxing
Date: Thu, 15 Sep 2016 11:19:02 +0200
Message-ID: <20160915091902.GA13132@amd>
References: <1472121165-29071-1-git-send-email-mic@digikod.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, Alexei Starovoitov <ast@kernel.org>,
        Andy Lutomirski <luto@amacapital.net>,
        Arnd Bergmann <arnd@arndb.de>,
        Casey Schaufler <casey@schaufler-ca.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Daniel Mack <daniel@zonque.org>,
        David Drysdale <drysdale@google.com>,
        "David S . Miller" <davem@davemloft.net>,
        Elena Reshetova <elena.reshetova@intel.com>,
        James Morris <james.l.morris@oracle.com>,
        Kees Cook <keescook@chromium.org>,
        Paul Moore <pmoore@redhat.com>,
        Sargun Dhillon <sargun@sargun.me>,
        "Serge E . Hallyn" <serge@hallyn.com>,
        Will Drewry <wad@chromium.org>,
        kernel-hardening@lists.openwall.com, linux-api@vger.kernel.org,
        linux-security-module@vger.kernel.org, netdev@vger.kernel.org
To: =?iso-8859-1?Q?Micka=EBl_Sala=FCn?= <mic@digikod.net>
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1472121165-29071-1-git-send-email-mic@digikod.net>
Sender: owner-linux-security-module@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi!

> This series is a proof of concept to fill some missing part of seccomp as the
> ability to check syscall argument pointers or creating more dynamic security
> policies. The goal of this new stackable Linux Security Module (LSM) called
> Landlock is to allow any process, including unprivileged ones, to create
> powerful security sandboxes comparable to the Seatbelt/XNU Sandbox or the
> OpenBSD Pledge. This kind of sandbox help to mitigate the security impact of
> bugs or unexpected/malicious behaviors in userland applications.
> 
> The first RFC [1] was focused on extending seccomp while staying at the syscall
> level. This brought a working PoC but with some (mitigated) ToCToU race
> conditions due to the seccomp ptrace hole (now fixed) and the non-atomic
> syscall argument evaluation (hence the LSM hooks).

Long and nice description follows. Should it go to Documentation/
somewhere?

Because some documentation would be useful...
								Pavel

>  include/linux/bpf.h                   |  41 +++++
>  include/linux/lsm_hooks.h             |   5 +
>  include/linux/seccomp.h               |  54 ++++++-
>  include/uapi/asm-generic/errno-base.h |   1 +
>  include/uapi/linux/bpf.h              | 103 ++++++++++++
>  include/uapi/linux/seccomp.h          |   2 +
>  kernel/bpf/arraymap.c                 | 222 +++++++++++++++++++++++++
>  kernel/bpf/syscall.c                  |  18 ++-
>  kernel/bpf/verifier.c                 |  32 +++-
>  kernel/fork.c                         |  41 ++++-
>  kernel/seccomp.c                      | 211 +++++++++++++++++++++++-
>  samples/Makefile                      |   2 +-
>  samples/landlock/.gitignore           |   1 +
>  samples/landlock/Makefile             |  16 ++
>  samples/landlock/sandbox.c            | 295 ++++++++++++++++++++++++++++++++++
>  security/Kconfig                      |   1 +
>  security/Makefile                     |   2 +
>  security/landlock/Kconfig             |  19 +++
>  security/landlock/Makefile            |   3 +
>  security/landlock/checker_cgroup.c    |  96 +++++++++++
>  security/landlock/checker_cgroup.h    |  18 +++
>  security/landlock/checker_fs.c        | 183 +++++++++++++++++++++
>  security/landlock/checker_fs.h        |  20 +++
>  security/landlock/lsm.c               | 228 ++++++++++++++++++++++++++
>  security/security.c                   |   1 +
>  25 files changed, 1592 insertions(+), 23 deletions(-)
>  create mode 100644 samples/landlock/.gitignore
>  create mode 100644 samples/landlock/Makefile
>  create mode 100644 samples/landlock/sandbox.c
>  create mode 100644 security/landlock/Kconfig
>  create mode 100644 security/landlock/Makefile
>  create mode 100644 security/landlock/checker_cgroup.c
>  create mode 100644 security/landlock/checker_cgroup.h
>  create mode 100644 security/landlock/checker_fs.c
>  create mode 100644 security/landlock/checker_fs.h
>  create mode 100644 security/landlock/lsm.c
> 

-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
