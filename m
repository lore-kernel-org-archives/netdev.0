From: Kees Cook <keescook@chromium.org>
Subject: Re: [PATCH v18 08/15] seccomp: add system call filtering using BPF
Date: Thu, 12 Apr 2012 15:19:19 -0700
Message-ID: <CAGXu5jKbZ2O0ryrvUVbem7sy6wBVMcbgn_qPWrKss040Rqsi6Q@mail.gmail.com>
References: <1334267284-19166-1-git-send-email-wad@chromium.org>
	<1334267284-19166-8-git-send-email-wad@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, linux-man@vger.kernel.org,
	linux-security-module@vger.kernel.org, linux-arch@vger.kernel.org,
	linux-doc@vger.kernel.org, kernel-hardening@lists.openwall.com,
	netdev@vger.kernel.org, x86@kernel.org, arnd@arndb.de,
	davem@davemloft.net, hpa@zytor.com, mingo@redhat.com,
	oleg@redhat.com, peterz@infradead.org, rdunlap@xenotime.net,
	mcgrathr@chromium.org, tglx@linutronix.de, luto@mit.edu,
	eparis@redhat.com, serge.hallyn@canonical.com, djm@mindrot.org,
	scarybeasts@gmail.com, indan@nul.nu, pmoore@redhat.com,
	akpm@linux-foundation.org, corbet@lwn.net, eric.dumazet@gmail.com,
	markus@chromium.org, coreyb@linux.vnet.ibm.com, jmorris@namei.org
To: Will Drewry <wad@chromium.org>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <1334267284-19166-8-git-send-email-wad@chromium.org>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 12, 2012 at 2:47 PM, Will Drewry <wad@chromium.org> wrote:
> This patch adds support for seccomp mode 2. =A0Mode 2 introduces the
> ability for unprivileged processes to install system call filtering
> policy expressed in terms of a Berkeley Packet Filter (BPF) program.
> This program will be evaluated in the kernel for each system call
> the task makes and computes a result based on data in the format
> of struct seccomp_data.
>
> A filter program may be installed by calling:
> =A0struct sock_fprog fprog =3D { ... };
> =A0...
> =A0prctl(PR_SET_SECCOMP, SECCOMP_MODE_FILTER, &fprog);
>
> The return value of the filter program determines if the system call =
is
> allowed to proceed or denied. =A0If the first filter program installe=
d
> allows prctl(2) calls, then the above call may be made repeatedly
> by a task to further reduce its access to the kernel. =A0All attached
> programs must be evaluated before a system call will be allowed to
> proceed.
>
> Filter programs will be inherited across fork/clone and execve.
> However, if the task attaching the filter is unprivileged
> (!CAP_SYS_ADMIN) the no_new_privs bit will be set on the task. =A0Thi=
s
> ensures that unprivileged tasks cannot attach filters that affect
> privileged tasks (e.g., setuid binary).
>
> There are a number of benefits to this approach. A few of which are
> as follows:
> - BPF has been exposed to userland for a long time
> - BPF optimization (and JIT'ing) are well understood
> - Userland already knows its ABI: system call numbers and desired
> =A0arguments
> - No time-of-check-time-of-use vulnerable data accesses are possible.
> - system call arguments are loaded on access only to minimize copying
> =A0required for system call policy decisions.
>
> Mode 2 support is restricted to architectures that enable
> HAVE_ARCH_SECCOMP_FILTER. =A0In this patch, the primary dependency is=
 on
> syscall_get_arguments(). =A0The full desired scope of this feature wi=
ll
> add a few minor additional requirements expressed later in this serie=
s.
> Based on discussion, SECCOMP_RET_ERRNO and SECCOMP_RET_TRACE seem to =
be
> the desired additional functionality.
>
> No architectures are enabled in this patch.
>
> Signed-off-by: Will Drewry <wad@chromium.org>
> Acked-by: Serge Hallyn <serge.hallyn@canonical.com>
> Reviewed-by: Indan Zupancic <indan@nul.nu>
> Acked-by: Eric Paris <eparis@redhat.com>

Acked-by: Kees Cook <keescook@chromium.org>

--=20
Kees Cook
ChromeOS Security
--
To unsubscribe from this list: send the line "unsubscribe linux-securit=
y-module" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
