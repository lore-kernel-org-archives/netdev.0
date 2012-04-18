From: Will Drewry <wad@chromium.org>
Subject: Re: [PATCH v18 15/15] Documentation: prctl/seccomp_filter
Date: Tue, 17 Apr 2012 21:53:17 -0500
Message-ID: <CABqD9hb3Ti+aWfupyOXMbyxxM5rJbrVHFwzhwvq8HXSn02O8rw@mail.gmail.com>
References: <1334267284-19166-1-git-send-email-wad@chromium.org>
	<1334267284-19166-15-git-send-email-wad@chromium.org>
	<CAP=VYLqKOOV41yXuD7jqEUfkxC4ROzZmhA-UP5pkNAKPFiddRw@mail.gmail.com>
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
	markus@chromium.org, coreyb@linux.vnet.ibm.com,
	keescook@chromium.org, jmorris@namei.org
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <CAP=VYLqKOOV41yXuD7jqEUfkxC4ROzZmhA-UP5pkNAKPFiddRw@mail.gmail.com>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 17, 2012 at 9:28 PM, Paul Gortmaker
<paul.gortmaker@windriver.com> wrote:
> On Thu, Apr 12, 2012 at 5:48 PM, Will Drewry <wad@chromium.org> wrote=
:
>> Documents how system call filtering using Berkeley Packet
>> Filter programs works and how it may be used.
>> Includes an example for x86 and a semi-generic
>> example using a macro-based code generator.
>
> Hi guys, that is quite the To/CC list. =A0I didn't have the heart to =
add
> yet another address (linux-next) to it...
>
> Can you have a look at this link? =A0 It appears to be breaking
> the i386 allmodconfig builds in linux-next.
>
> http://kisskb.ellerman.id.au/kisskb/buildresult/6123842/
>
> =A0 =A0"samples/seccomp/bpf-direct.c:47:2: error: #error Unsupported =
platform"

Ouch. It's checking the __i386__ and __x86_64__ macros. I'll reproduce
it and see what needs to change.  I suspect it'll be something dumb,
but the worst case is that I drop that bit of fanciness.

Thanks and sorry!
will

>>
>> Acked-by: Eric Paris <eparis@redhat.com>
>> Signed-off-by: Will Drewry <wad@chromium.org>
>>
>> v18: - added acked by
>> =A0 =A0 - update no new privs numbers
>> v17: - remove @compat note and add Pitfalls section for arch checkin=
g
>> =A0 =A0 =A0 (keescook@chromium.org)
>> v16: -
>> v15: -
>> v14: - rebase/nochanges
>> v13: - rebase on to 88ebdda6159ffc15699f204c33feb3e431bf9bdc
>> v12: - comment on the ptrace_event use
>> =A0 =A0 - update arch support comment
>> =A0 =A0 - note the behavior of SECCOMP_RET_DATA when there are multi=
ple filters
>> =A0 =A0 =A0 (keescook@chromium.org)
>> =A0 =A0 - lots of samples/ clean up incl 64-bit bpf-direct support
>> =A0 =A0 =A0 (markus@chromium.org)
>> =A0 =A0 - rebase to linux-next
>> v11: - overhaul return value language, updates (keescook@chromium.or=
g)
>> =A0 =A0 - comment on do_exit(SIGSYS)
>> v10: - update for SIGSYS
>> =A0 =A0 - update for new seccomp_data layout
>> =A0 =A0 - update for ptrace option use
>> v9: - updated bpf-direct.c for SIGILL
>> v8: - add PR_SET_NO_NEW_PRIVS to the samples.
>> v7: - updated for all the new stuff in v7: TRAP, TRACE
>> =A0 =A0- only talk about PR_SET_SECCOMP now
>> =A0 =A0- fixed bad JLE32 check (coreyb@linux.vnet.ibm.com)
>> =A0 =A0- adds dropper.c: a simple system call disabler
>> v6: - tweak the language to note the requirement of
>> =A0 =A0 =A0PR_SET_NO_NEW_PRIVS being called prior to use. (luto@mit.=
edu)
>> v5: - update sample to use system call arguments
>> =A0 =A0- adds a "fancy" example using a macro-based generator
>> =A0 =A0- cleaned up bpf in the sample
>> =A0 =A0- update docs to mention arguments
>> =A0 =A0- fix prctl value (eparis@redhat.com)
>> =A0 =A0- language cleanup (rdunlap@xenotime.net)
>> v4: - update for no_new_privs use
>> =A0 =A0- minor tweaks
>> v3: - call out BPF <-> Berkeley Packet Filter (rdunlap@xenotime.net)
>> =A0 =A0- document use of tentative always-unprivileged
>> =A0 =A0- guard sample compilation for i386 and x86_64
>> v2: - move code to samples (corbet@lwn.net)
>> ---
>> =A0Documentation/prctl/seccomp_filter.txt | =A0163 +++++++++++++++++=
+++++
>> =A0samples/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0=
 =A02 +-
>> =A0samples/seccomp/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 38 +++=
++
>> =A0samples/seccomp/bpf-direct.c =A0 =A0 =A0 =A0 =A0 | =A0176 +++++++=
++++++++++++++++
>> =A0samples/seccomp/bpf-fancy.c =A0 =A0 =A0 =A0 =A0 =A0| =A0102 +++++=
+++++++++
>> =A0samples/seccomp/bpf-helper.c =A0 =A0 =A0 =A0 =A0 | =A0 89 +++++++=
+++++
>> =A0samples/seccomp/bpf-helper.h =A0 =A0 =A0 =A0 =A0 | =A0238 +++++++=
+++++++++++++++++++++++++
>> =A0samples/seccomp/dropper.c =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 68 +++=
++++++
>> =A08 files changed, 875 insertions(+), 1 deletions(-)
>> =A0create mode 100644 Documentation/prctl/seccomp_filter.txt
>> =A0create mode 100644 samples/seccomp/Makefile
>> =A0create mode 100644 samples/seccomp/bpf-direct.c
>> =A0create mode 100644 samples/seccomp/bpf-fancy.c
>> =A0create mode 100644 samples/seccomp/bpf-helper.c
>> =A0create mode 100644 samples/seccomp/bpf-helper.h
>> =A0create mode 100644 samples/seccomp/dropper.c
>>
>> diff --git a/Documentation/prctl/seccomp_filter.txt b/Documentation/=
prctl/seccomp_filter.txt
>> new file mode 100644
>> index 0000000..597c3c5
>> --- /dev/null
>> +++ b/Documentation/prctl/seccomp_filter.txt
>> @@ -0,0 +1,163 @@
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 SECure COMPuting with filters
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>> +
>> +Introduction
>> +------------
>> +
>> +A large number of system calls are exposed to every userland proces=
s
>> +with many of them going unused for the entire lifetime of the proce=
ss.
>> +As system calls change and mature, bugs are found and eradicated. =A0=
A
>> +certain subset of userland applications benefit by having a reduced=
 set
>> +of available system calls. =A0The resulting set reduces the total k=
ernel
>> +surface exposed to the application. =A0System call filtering is mea=
nt for
>> +use with those applications.
>> +
>> +Seccomp filtering provides a means for a process to specify a filte=
r for
>> +incoming system calls. =A0The filter is expressed as a Berkeley Pac=
ket
>> +Filter (BPF) program, as with socket filters, except that the data
>> +operated on is related to the system call being made: system call
>> +number and the system call arguments. =A0This allows for expressive
>> +filtering of system calls using a filter program language with a lo=
ng
>> +history of being exposed to userland and a straightforward data set=
=2E
>> +
>> +Additionally, BPF makes it impossible for users of seccomp to fall =
prey
>> +to time-of-check-time-of-use (TOCTOU) attacks that are common in sy=
stem
>> +call interposition frameworks. =A0BPF programs may not dereference
>> +pointers which constrains all filters to solely evaluating the syst=
em
>> +call arguments directly.
>> +
>> +What it isn't
>> +-------------
>> +
>> +System call filtering isn't a sandbox. =A0It provides a clearly def=
ined
>> +mechanism for minimizing the exposed kernel surface. =A0It is meant=
 to be
>> +a tool for sandbox developers to use. =A0Beyond that, policy for lo=
gical
>> +behavior and information flow should be managed with a combination =
of
>> +other system hardening techniques and, potentially, an LSM of your
>> +choosing. =A0Expressive, dynamic filters provide further options do=
wn this
>> +path (avoiding pathological sizes or selecting which of the multipl=
exed
>> +system calls in socketcall() is allowed, for instance) which could =
be
>> +construed, incorrectly, as a more complete sandboxing solution.
>> +
>> +Usage
>> +-----
>> +
>> +An additional seccomp mode is added and is enabled using the same
>> +prctl(2) call as the strict seccomp. =A0If the architecture has
>> +CONFIG_HAVE_ARCH_SECCOMP_FILTER, then filters may be added as below=
:
>> +
>> +PR_SET_SECCOMP:
>> + =A0 =A0 =A0 Now takes an additional argument which specifies a new=
 filter
>> + =A0 =A0 =A0 using a BPF program.
>> + =A0 =A0 =A0 The BPF program will be executed over struct seccomp_d=
ata
>> + =A0 =A0 =A0 reflecting the system call number, arguments, and othe=
r
>> + =A0 =A0 =A0 metadata. =A0The BPF program must then return one of t=
he
>> + =A0 =A0 =A0 acceptable values to inform the kernel which action sh=
ould be
>> + =A0 =A0 =A0 taken.
>> +
>> + =A0 =A0 =A0 Usage:
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 prctl(PR_SET_SECCOMP, SECCOMP_MODE_FIL=
TER, prog);
>> +
>> + =A0 =A0 =A0 The 'prog' argument is a pointer to a struct sock_fpro=
g which
>> + =A0 =A0 =A0 will contain the filter program. =A0If the program is =
invalid, the
>> + =A0 =A0 =A0 call will return -1 and set errno to EINVAL.
>> +
>> + =A0 =A0 =A0 If fork/clone and execve are allowed by @prog, any chi=
ld
>> + =A0 =A0 =A0 processes will be constrained to the same filters and =
system
>> + =A0 =A0 =A0 call ABI as the parent.
>> +
>> + =A0 =A0 =A0 Prior to use, the task must call prctl(PR_SET_NO_NEW_P=
RIVS, 1) or
>> + =A0 =A0 =A0 run with CAP_SYS_ADMIN privileges in its namespace. =A0=
If these are not
>> + =A0 =A0 =A0 true, -EACCES will be returned. =A0This requirement en=
sures that filter
>> + =A0 =A0 =A0 programs cannot be applied to child processes with gre=
ater privileges
>> + =A0 =A0 =A0 than the task that installed them.
>> +
>> + =A0 =A0 =A0 Additionally, if prctl(2) is allowed by the attached f=
ilter,
>> + =A0 =A0 =A0 additional filters may be layered on which will increa=
se evaluation
>> + =A0 =A0 =A0 time, but allow for further decreasing the attack surf=
ace during
>> + =A0 =A0 =A0 execution of a process.
>> +
>> +The above call returns 0 on success and non-zero on error.
>> +
>> +Return values
>> +-------------
>> +A seccomp filter may return any of the following values. If multipl=
e
>> +filters exist, the return value for the evaluation of a given syste=
m
>> +call will always use the highest precedent value. (For example,
>> +SECCOMP_RET_KILL will always take precedence.)
>> +
>> +In precedence order, they are:
>> +
>> +SECCOMP_RET_KILL:
>> + =A0 =A0 =A0 Results in the task exiting immediately without execut=
ing the
>> + =A0 =A0 =A0 system call. =A0The exit status of the task (status & =
0x7f) will
>> + =A0 =A0 =A0 be SIGSYS, not SIGKILL.
>> +
>> +SECCOMP_RET_TRAP:
>> + =A0 =A0 =A0 Results in the kernel sending a SIGSYS signal to the t=
riggering
>> + =A0 =A0 =A0 task without executing the system call. =A0The kernel =
will
>> + =A0 =A0 =A0 rollback the register state to just before the system =
call
>> + =A0 =A0 =A0 entry such that a signal handler in the task will be a=
ble to
>> + =A0 =A0 =A0 inspect the ucontext_t->uc_mcontext registers and emul=
ate
>> + =A0 =A0 =A0 system call success or failure upon return from the si=
gnal
>> + =A0 =A0 =A0 handler.
>> +
>> + =A0 =A0 =A0 The SECCOMP_RET_DATA portion of the return value will =
be passed
>> + =A0 =A0 =A0 as si_errno.
>> +
>> + =A0 =A0 =A0 SIGSYS triggered by seccomp will have a si_code of SYS=
_SECCOMP.
>> +
>> +SECCOMP_RET_ERRNO:
>> + =A0 =A0 =A0 Results in the lower 16-bits of the return value being=
 passed
>> + =A0 =A0 =A0 to userland as the errno without executing the system =
call.
>> +
>> +SECCOMP_RET_TRACE:
>> + =A0 =A0 =A0 When returned, this value will cause the kernel to att=
empt to
>> + =A0 =A0 =A0 notify a ptrace()-based tracer prior to executing the =
system
>> + =A0 =A0 =A0 call. =A0If there is no tracer present, -ENOSYS is ret=
urned to
>> + =A0 =A0 =A0 userland and the system call is not executed.
>> +
>> + =A0 =A0 =A0 A tracer will be notified if it requests PTRACE_O_TRAC=
ESECCOMP
>> + =A0 =A0 =A0 using ptrace(PTRACE_SETOPTIONS). =A0The tracer will be=
 notified
>> + =A0 =A0 =A0 of a PTRACE_EVENT_SECCOMP and the SECCOMP_RET_DATA por=
tion of
>> + =A0 =A0 =A0 the BPF program return value will be available to the =
tracer
>> + =A0 =A0 =A0 via PTRACE_GETEVENTMSG.
>> +
>> +SECCOMP_RET_ALLOW:
>> + =A0 =A0 =A0 Results in the system call being executed.
>> +
>> +If multiple filters exist, the return value for the evaluation of a
>> +given system call will always use the highest precedent value.
>> +
>> +Precedence is only determined using the SECCOMP_RET_ACTION mask. =A0=
When
>> +multiple filters return values of the same precedence, only the
>> +SECCOMP_RET_DATA from the most recently installed filter will be
>> +returned.
>> +
>> +Pitfalls
>> +--------
>> +
>> +The biggest pitfall to avoid during use is filtering on system call
>> +number without checking the architecture value. =A0Why? =A0On any
>> +architecture that supports multiple system call invocation conventi=
ons,
>> +the system call numbers may vary based on the specific invocation. =
=A0If
>> +the numbers in the different calling conventions overlap, then chec=
ks in
>> +the filters may be abused. =A0Always check the arch value!
>> +
>> +Example
>> +-------
>> +
>> +The samples/seccomp/ directory contains both an x86-specific exampl=
e
>> +and a more generic example of a higher level macro interface for BP=
=46
>> +program generation.
>> +
>> +
>> +
>> +Adding architecture support
>> +-----------------------
>> +
>> +See arch/Kconfig for the authoritative requirements. =A0In general,=
 if an
>> +architecture supports both ptrace_event and seccomp, it will be abl=
e to
>> +support seccomp filter with minor fixup: SIGSYS support and seccomp=
 return
>> +value checking. =A0Then it must just add CONFIG_HAVE_ARCH_SECCOMP_F=
ILTER
>> +to its arch-specific Kconfig.
>> diff --git a/samples/Makefile b/samples/Makefile
>> index 2f75851..5ef08bb 100644
>> --- a/samples/Makefile
>> +++ b/samples/Makefile
>> @@ -1,4 +1,4 @@
>> =A0# Makefile for Linux samples code
>>
>> =A0obj-$(CONFIG_SAMPLES) =A0+=3D kobject/ kprobes/ tracepoints/ trac=
e_events/ \
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0hw_breakpoint/ =
kfifo/ kdb/ hidraw/ rpmsg/
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0hw_breakpoint/ =
kfifo/ kdb/ hidraw/ rpmsg/ seccomp/
>> diff --git a/samples/seccomp/Makefile b/samples/seccomp/Makefile
>> new file mode 100644
>> index 0000000..e8fe0f5
>> --- /dev/null
>> +++ b/samples/seccomp/Makefile
>> @@ -0,0 +1,38 @@
>> +# kbuild trick to avoid linker error. Can be omitted if a module is=
 built.
>> +obj- :=3D dummy.o
>> +
>> +hostprogs-$(CONFIG_SECCOMP) :=3D bpf-fancy dropper
>> +bpf-fancy-objs :=3D bpf-fancy.o bpf-helper.o
>> +
>> +HOSTCFLAGS_bpf-fancy.o +=3D -I$(objtree)/usr/include
>> +HOSTCFLAGS_bpf-fancy.o +=3D -idirafter $(objtree)/include
>> +HOSTCFLAGS_bpf-helper.o +=3D -I$(objtree)/usr/include
>> +HOSTCFLAGS_bpf-helper.o +=3D -idirafter $(objtree)/include
>> +
>> +HOSTCFLAGS_dropper.o +=3D -I$(objtree)/usr/include
>> +HOSTCFLAGS_dropper.o +=3D -idirafter $(objtree)/include
>> +dropper-objs :=3D dropper.o
>> +
>> +# bpf-direct.c is x86-only.
>> +ifeq ($(SRCARCH),x86)
>> +# List of programs to build
>> +hostprogs-$(CONFIG_SECCOMP) +=3D bpf-direct
>> +bpf-direct-objs :=3D bpf-direct.o
>> +endif
>> +
>> +HOSTCFLAGS_bpf-direct.o +=3D -I$(objtree)/usr/include
>> +HOSTCFLAGS_bpf-direct.o +=3D -idirafter $(objtree)/include
>> +
>> +# Try to match the kernel target.
>> +ifeq ($(CONFIG_64BIT),)
>> +HOSTCFLAGS_bpf-direct.o +=3D -m32
>> +HOSTCFLAGS_dropper.o +=3D -m32
>> +HOSTCFLAGS_bpf-helper.o +=3D -m32
>> +HOSTCFLAGS_bpf-fancy.o +=3D -m32
>> +HOSTLOADLIBES_bpf-direct +=3D -m32
>> +HOSTLOADLIBES_bpf-fancy +=3D -m32
>> +HOSTLOADLIBES_dropper +=3D -m32
>> +endif
>> +
>> +# Tell kbuild to always build the programs
>> +always :=3D $(hostprogs-y)
>> diff --git a/samples/seccomp/bpf-direct.c b/samples/seccomp/bpf-dire=
ct.c
>> new file mode 100644
>> index 0000000..26f523e
>> --- /dev/null
>> +++ b/samples/seccomp/bpf-direct.c
>> @@ -0,0 +1,176 @@
>> +/*
>> + * Seccomp filter example for x86 (32-bit and 64-bit) with BPF macr=
os
>> + *
>> + * Copyright (c) 2012 The Chromium OS Authors <chromium-os-dev@chro=
mium.org>
>> + * Author: Will Drewry <wad@chromium.org>
>> + *
>> + * The code may be used by anyone for any purpose,
>> + * and can serve as a starting point for developing
>> + * applications using prctl(PR_SET_SECCOMP, 2, ...).
>> + */
>> +#define __USE_GNU 1
>> +#define _GNU_SOURCE 1
>> +
>> +#include <linux/types.h>
>> +#include <linux/filter.h>
>> +#include <linux/seccomp.h>
>> +#include <linux/unistd.h>
>> +#include <signal.h>
>> +#include <stdio.h>
>> +#include <stddef.h>
>> +#include <string.h>
>> +#include <sys/prctl.h>
>> +#include <unistd.h>
>> +
>> +#define syscall_arg(_n) (offsetof(struct seccomp_data, args[_n]))
>> +#define syscall_nr (offsetof(struct seccomp_data, nr))
>> +
>> +#if defined(__i386__)
>> +#define REG_RESULT =A0 =A0 REG_EAX
>> +#define REG_SYSCALL =A0 =A0REG_EAX
>> +#define REG_ARG0 =A0 =A0 =A0 REG_EBX
>> +#define REG_ARG1 =A0 =A0 =A0 REG_ECX
>> +#define REG_ARG2 =A0 =A0 =A0 REG_EDX
>> +#define REG_ARG3 =A0 =A0 =A0 REG_ESI
>> +#define REG_ARG4 =A0 =A0 =A0 REG_EDI
>> +#define REG_ARG5 =A0 =A0 =A0 REG_EBP
>> +#elif defined(__x86_64__)
>> +#define REG_RESULT =A0 =A0 REG_RAX
>> +#define REG_SYSCALL =A0 =A0REG_RAX
>> +#define REG_ARG0 =A0 =A0 =A0 REG_RDI
>> +#define REG_ARG1 =A0 =A0 =A0 REG_RSI
>> +#define REG_ARG2 =A0 =A0 =A0 REG_RDX
>> +#define REG_ARG3 =A0 =A0 =A0 REG_R10
>> +#define REG_ARG4 =A0 =A0 =A0 REG_R8
>> +#define REG_ARG5 =A0 =A0 =A0 REG_R9
>> +#else
>> +#error Unsupported platform
>> +#endif
>> +
>> +#ifndef PR_SET_NO_NEW_PRIVS
>> +#define PR_SET_NO_NEW_PRIVS 38
>> +#endif
>> +
>> +#ifndef SYS_SECCOMP
>> +#define SYS_SECCOMP 1
>> +#endif
>> +
>> +static void emulator(int nr, siginfo_t *info, void *void_context)
>> +{
>> + =A0 =A0 =A0 ucontext_t *ctx =3D (ucontext_t *)(void_context);
>> + =A0 =A0 =A0 int syscall;
>> + =A0 =A0 =A0 char *buf;
>> + =A0 =A0 =A0 ssize_t bytes;
>> + =A0 =A0 =A0 size_t len;
>> + =A0 =A0 =A0 if (info->si_code !=3D SYS_SECCOMP)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
>> + =A0 =A0 =A0 if (!ctx)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
>> + =A0 =A0 =A0 syscall =3D ctx->uc_mcontext.gregs[REG_SYSCALL];
>> + =A0 =A0 =A0 buf =3D (char *) ctx->uc_mcontext.gregs[REG_ARG1];
>> + =A0 =A0 =A0 len =3D (size_t) ctx->uc_mcontext.gregs[REG_ARG2];
>> +
>> + =A0 =A0 =A0 if (syscall !=3D __NR_write)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
>> + =A0 =A0 =A0 if (ctx->uc_mcontext.gregs[REG_ARG0] !=3D STDERR_FILEN=
O)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
>> + =A0 =A0 =A0 /* Redirect stderr messages to stdout. Doesn't handle =
EINTR, etc */
>> + =A0 =A0 =A0 ctx->uc_mcontext.gregs[REG_RESULT] =3D -1;
>> + =A0 =A0 =A0 if (write(STDOUT_FILENO, "[ERR] ", 6) > 0) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 bytes =3D write(STDOUT_FILENO, buf, le=
n);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ctx->uc_mcontext.gregs[REG_RESULT] =3D=
 bytes;
>> + =A0 =A0 =A0 }
>> + =A0 =A0 =A0 return;
>> +}
>> +
>> +static int install_emulator(void)
>> +{
>> + =A0 =A0 =A0 struct sigaction act;
>> + =A0 =A0 =A0 sigset_t mask;
>> + =A0 =A0 =A0 memset(&act, 0, sizeof(act));
>> + =A0 =A0 =A0 sigemptyset(&mask);
>> + =A0 =A0 =A0 sigaddset(&mask, SIGSYS);
>> +
>> + =A0 =A0 =A0 act.sa_sigaction =3D &emulator;
>> + =A0 =A0 =A0 act.sa_flags =3D SA_SIGINFO;
>> + =A0 =A0 =A0 if (sigaction(SIGSYS, &act, NULL) < 0) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 perror("sigaction");
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -1;
>> + =A0 =A0 =A0 }
>> + =A0 =A0 =A0 if (sigprocmask(SIG_UNBLOCK, &mask, NULL)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 perror("sigprocmask");
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -1;
>> + =A0 =A0 =A0 }
>> + =A0 =A0 =A0 return 0;
>> +}
>> +
>> +static int install_filter(void)
>> +{
>> + =A0 =A0 =A0 struct sock_filter filter[] =3D {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Grab the system call number */
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 BPF_STMT(BPF_LD+BPF_W+BPF_ABS, syscall=
_nr),
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Jump table for the allowed syscalls=
 */
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 BPF_JUMP(BPF_JMP+BPF_JEQ+BPF_K, __NR_r=
t_sigreturn, 0, 1),
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 BPF_STMT(BPF_RET+BPF_K, SECCOMP_RET_AL=
LOW),
>> +#ifdef __NR_sigreturn
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 BPF_JUMP(BPF_JMP+BPF_JEQ+BPF_K, __NR_s=
igreturn, 0, 1),
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 BPF_STMT(BPF_RET+BPF_K, SECCOMP_RET_AL=
LOW),
>> +#endif
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 BPF_JUMP(BPF_JMP+BPF_JEQ+BPF_K, __NR_e=
xit_group, 0, 1),
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 BPF_STMT(BPF_RET+BPF_K, SECCOMP_RET_AL=
LOW),
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 BPF_JUMP(BPF_JMP+BPF_JEQ+BPF_K, __NR_e=
xit, 0, 1),
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 BPF_STMT(BPF_RET+BPF_K, SECCOMP_RET_AL=
LOW),
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 BPF_JUMP(BPF_JMP+BPF_JEQ+BPF_K, __NR_r=
ead, 1, 0),
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 BPF_JUMP(BPF_JMP+BPF_JEQ+BPF_K, __NR_w=
rite, 3, 2),
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Check that read is only using stdin=
=2E */
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 BPF_STMT(BPF_LD+BPF_W+BPF_ABS, syscall=
_arg(0)),
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 BPF_JUMP(BPF_JMP+BPF_JEQ+BPF_K, STDIN_=
=46ILENO, 4, 0),
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 BPF_STMT(BPF_RET+BPF_K, SECCOMP_RET_KI=
LL),
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Check that write is only using stdo=
ut */
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 BPF_STMT(BPF_LD+BPF_W+BPF_ABS, syscall=
_arg(0)),
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 BPF_JUMP(BPF_JMP+BPF_JEQ+BPF_K, STDOUT=
_FILENO, 1, 0),
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Trap attempts to write to stderr */
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 BPF_JUMP(BPF_JMP+BPF_JEQ+BPF_K, STDERR=
_FILENO, 1, 2),
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 BPF_STMT(BPF_RET+BPF_K, SECCOMP_RET_AL=
LOW),
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 BPF_STMT(BPF_RET+BPF_K, SECCOMP_RET_TR=
AP),
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 BPF_STMT(BPF_RET+BPF_K, SECCOMP_RET_KI=
LL),
>> + =A0 =A0 =A0 };
>> + =A0 =A0 =A0 struct sock_fprog prog =3D {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .len =3D (unsigned short)(sizeof(filte=
r)/sizeof(filter[0])),
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .filter =3D filter,
>> + =A0 =A0 =A0 };
>> +
>> + =A0 =A0 =A0 if (prctl(PR_SET_NO_NEW_PRIVS, 1, 0, 0, 0)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 perror("prctl(NO_NEW_PRIVS)");
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 1;
>> + =A0 =A0 =A0 }
>> +
>> +
>> + =A0 =A0 =A0 if (prctl(PR_SET_SECCOMP, SECCOMP_MODE_FILTER, &prog))=
 {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 perror("prctl");
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 1;
>> + =A0 =A0 =A0 }
>> + =A0 =A0 =A0 return 0;
>> +}
>> +
>> +#define payload(_c) (_c), sizeof((_c))
>> +int main(int argc, char **argv)
>> +{
>> + =A0 =A0 =A0 char buf[4096];
>> + =A0 =A0 =A0 ssize_t bytes =3D 0;
>> + =A0 =A0 =A0 if (install_emulator())
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 1;
>> + =A0 =A0 =A0 if (install_filter())
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 1;
>> + =A0 =A0 =A0 syscall(__NR_write, STDOUT_FILENO,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 payload("OHAI! WHAT IS YOUR NAME? "));
>> + =A0 =A0 =A0 bytes =3D syscall(__NR_read, STDIN_FILENO, buf, sizeof=
(buf));
>> + =A0 =A0 =A0 syscall(__NR_write, STDOUT_FILENO, payload("HELLO, "))=
;
>> + =A0 =A0 =A0 syscall(__NR_write, STDOUT_FILENO, buf, bytes);
>> + =A0 =A0 =A0 syscall(__NR_write, STDERR_FILENO,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 payload("Error message going to STDERR=
\n"));
>> + =A0 =A0 =A0 return 0;
>> +}
>> diff --git a/samples/seccomp/bpf-fancy.c b/samples/seccomp/bpf-fancy=
=2Ec
>> new file mode 100644
>> index 0000000..8eb483a
>> --- /dev/null
>> +++ b/samples/seccomp/bpf-fancy.c
>> @@ -0,0 +1,102 @@
>> +/*
>> + * Seccomp BPF example using a macro-based generator.
>> + *
>> + * Copyright (c) 2012 The Chromium OS Authors <chromium-os-dev@chro=
mium.org>
>> + * Author: Will Drewry <wad@chromium.org>
>> + *
>> + * The code may be used by anyone for any purpose,
>> + * and can serve as a starting point for developing
>> + * applications using prctl(PR_ATTACH_SECCOMP_FILTER).
>> + */
>> +
>> +#include <linux/filter.h>
>> +#include <linux/seccomp.h>
>> +#include <linux/unistd.h>
>> +#include <stdio.h>
>> +#include <string.h>
>> +#include <sys/prctl.h>
>> +#include <unistd.h>
>> +
>> +#include "bpf-helper.h"
>> +
>> +#ifndef PR_SET_NO_NEW_PRIVS
>> +#define PR_SET_NO_NEW_PRIVS 38
>> +#endif
>> +
>> +int main(int argc, char **argv)
>> +{
>> + =A0 =A0 =A0 struct bpf_labels l;
>> + =A0 =A0 =A0 static const char msg1[] =3D "Please type something: "=
;
>> + =A0 =A0 =A0 static const char msg2[] =3D "You typed: ";
>> + =A0 =A0 =A0 char buf[256];
>> + =A0 =A0 =A0 struct sock_filter filter[] =3D {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* TODO: LOAD_SYSCALL_NR(arch) and enf=
orce an arch */
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 LOAD_SYSCALL_NR,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 SYSCALL(__NR_exit, ALLOW),
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 SYSCALL(__NR_exit_group, ALLOW),
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 SYSCALL(__NR_write, JUMP(&l, write_fd)=
),
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 SYSCALL(__NR_read, JUMP(&l, read)),
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 DENY, =A0/* Don't passthrough into a l=
abel */
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 LABEL(&l, read),
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ARG(0),
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 JNE(STDIN_FILENO, DENY),
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ARG(1),
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 JNE((unsigned long)buf, DENY),
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ARG(2),
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 JGE(sizeof(buf), DENY),
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ALLOW,
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 LABEL(&l, write_fd),
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ARG(0),
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 JEQ(STDOUT_FILENO, JUMP(&l, write_buf)=
),
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 JEQ(STDERR_FILENO, JUMP(&l, write_buf)=
),
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 DENY,
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 LABEL(&l, write_buf),
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ARG(1),
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 JEQ((unsigned long)msg1, JUMP(&l, msg1=
_len)),
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 JEQ((unsigned long)msg2, JUMP(&l, msg2=
_len)),
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 JEQ((unsigned long)buf, JUMP(&l, buf_l=
en)),
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 DENY,
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 LABEL(&l, msg1_len),
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ARG(2),
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 JLT(sizeof(msg1), ALLOW),
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 DENY,
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 LABEL(&l, msg2_len),
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ARG(2),
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 JLT(sizeof(msg2), ALLOW),
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 DENY,
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 LABEL(&l, buf_len),
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ARG(2),
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 JLT(sizeof(buf), ALLOW),
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 DENY,
>> + =A0 =A0 =A0 };
>> + =A0 =A0 =A0 struct sock_fprog prog =3D {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .filter =3D filter,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .len =3D (unsigned short)(sizeof(filte=
r)/sizeof(filter[0])),
>> + =A0 =A0 =A0 };
>> + =A0 =A0 =A0 ssize_t bytes;
>> + =A0 =A0 =A0 bpf_resolve_jumps(&l, filter, sizeof(filter)/sizeof(*f=
ilter));
>> +
>> + =A0 =A0 =A0 if (prctl(PR_SET_NO_NEW_PRIVS, 1, 0, 0, 0)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 perror("prctl(NO_NEW_PRIVS)");
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 1;
>> + =A0 =A0 =A0 }
>> +
>> + =A0 =A0 =A0 if (prctl(PR_SET_SECCOMP, SECCOMP_MODE_FILTER, &prog))=
 {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 perror("prctl(SECCOMP)");
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 1;
>> + =A0 =A0 =A0 }
>> + =A0 =A0 =A0 syscall(__NR_write, STDOUT_FILENO, msg1, strlen(msg1))=
;
>> + =A0 =A0 =A0 bytes =3D syscall(__NR_read, STDIN_FILENO, buf, sizeof=
(buf)-1);
>> + =A0 =A0 =A0 bytes =3D (bytes > 0 ? bytes : 0);
>> + =A0 =A0 =A0 syscall(__NR_write, STDERR_FILENO, msg2, strlen(msg2))=
;
>> + =A0 =A0 =A0 syscall(__NR_write, STDERR_FILENO, buf, bytes);
>> + =A0 =A0 =A0 /* Now get killed */
>> + =A0 =A0 =A0 syscall(__NR_write, STDERR_FILENO, msg2, strlen(msg2)+=
2);
>> + =A0 =A0 =A0 return 0;
>> +}
>> diff --git a/samples/seccomp/bpf-helper.c b/samples/seccomp/bpf-help=
er.c
>> new file mode 100644
>> index 0000000..579cfe3
>> --- /dev/null
>> +++ b/samples/seccomp/bpf-helper.c
>> @@ -0,0 +1,89 @@
>> +/*
>> + * Seccomp BPF helper functions
>> + *
>> + * Copyright (c) 2012 The Chromium OS Authors <chromium-os-dev@chro=
mium.org>
>> + * Author: Will Drewry <wad@chromium.org>
>> + *
>> + * The code may be used by anyone for any purpose,
>> + * and can serve as a starting point for developing
>> + * applications using prctl(PR_ATTACH_SECCOMP_FILTER).
>> + */
>> +
>> +#include <stdio.h>
>> +#include <string.h>
>> +
>> +#include "bpf-helper.h"
>> +
>> +int bpf_resolve_jumps(struct bpf_labels *labels,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct sock_filter *filter=
, size_t count)
>> +{
>> + =A0 =A0 =A0 struct sock_filter *begin =3D filter;
>> + =A0 =A0 =A0 __u8 insn =3D count - 1;
>> +
>> + =A0 =A0 =A0 if (count < 1)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -1;
>> + =A0 =A0 =A0 /*
>> + =A0 =A0 =A0 * Walk it once, backwards, to build the label table an=
d do fixups.
>> + =A0 =A0 =A0 * Since backward jumps are disallowed by BPF, this is =
easy.
>> + =A0 =A0 =A0 */
>> + =A0 =A0 =A0 filter +=3D insn;
>> + =A0 =A0 =A0 for (; filter >=3D begin; --insn, --filter) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (filter->code !=3D (BPF_JMP+BPF_JA)=
)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 switch ((filter->jt<<8)|filter->jf) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case (JUMP_JT<<8)|JUMP_JF:
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (labels->labels[fil=
ter->k].location =3D=3D 0xffffffff) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 fprint=
f(stderr, "Unresolved label: '%s'\n",
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 labels->labels[filter->k].label);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return=
 1;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 filter->k =3D labels->=
labels[filter->k].location -
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 (insn + 1);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 filter->jt =3D 0;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 filter->jf =3D 0;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case (LABEL_JT<<8)|LABEL_JF:
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (labels->labels[fil=
ter->k].location !=3D 0xffffffff) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 fprint=
f(stderr, "Duplicate label use: '%s'\n",
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 labels->labels[filter->k].label);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return=
 1;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 labels->labels[filter-=
>k].location =3D insn;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 filter->k =3D 0; /* fa=
ll through */
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 filter->jt =3D 0;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 filter->jf =3D 0;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> + =A0 =A0 =A0 }
>> + =A0 =A0 =A0 return 0;
>> +}
>> +
>> +/* Simple lookup table for labels. */
>> +__u32 seccomp_bpf_label(struct bpf_labels *labels, const char *labe=
l)
>> +{
>> + =A0 =A0 =A0 struct __bpf_label *begin =3D labels->labels, *end;
>> + =A0 =A0 =A0 int id;
>> + =A0 =A0 =A0 if (labels->count =3D=3D 0) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 begin->label =3D label;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 begin->location =3D 0xffffffff;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 labels->count++;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
>> + =A0 =A0 =A0 }
>> + =A0 =A0 =A0 end =3D begin + labels->count;
>> + =A0 =A0 =A0 for (id =3D 0; begin < end; ++begin, ++id) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!strcmp(label, begin->label))
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return id;
>> + =A0 =A0 =A0 }
>> + =A0 =A0 =A0 begin->label =3D label;
>> + =A0 =A0 =A0 begin->location =3D 0xffffffff;
>> + =A0 =A0 =A0 labels->count++;
>> + =A0 =A0 =A0 return id;
>> +}
>> +
>> +void seccomp_bpf_print(struct sock_filter *filter, size_t count)
>> +{
>> + =A0 =A0 =A0 struct sock_filter *end =3D filter + count;
>> + =A0 =A0 =A0 for ( ; filter < end; ++filter)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 printf("{ code=3D%u,jt=3D%u,jf=3D%u,k=3D=
%u },\n",
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 filter->code, filter->=
jt, filter->jf, filter->k);
>> +}
>> diff --git a/samples/seccomp/bpf-helper.h b/samples/seccomp/bpf-help=
er.h
>> new file mode 100644
>> index 0000000..643279d
>> --- /dev/null
>> +++ b/samples/seccomp/bpf-helper.h
>> @@ -0,0 +1,238 @@
>> +/*
>> + * Example wrapper around BPF macros.
>> + *
>> + * Copyright (c) 2012 The Chromium OS Authors <chromium-os-dev@chro=
mium.org>
>> + * Author: Will Drewry <wad@chromium.org>
>> + *
>> + * The code may be used by anyone for any purpose,
>> + * and can serve as a starting point for developing
>> + * applications using prctl(PR_SET_SECCOMP, 2, ...).
>> + *
>> + * No guarantees are provided with respect to the correctness
>> + * or functionality of this code.
>> + */
>> +#ifndef __BPF_HELPER_H__
>> +#define __BPF_HELPER_H__
>> +
>> +#include <asm/bitsperlong.h> =A0 /* for __BITS_PER_LONG */
>> +#include <endian.h>
>> +#include <linux/filter.h>
>> +#include <linux/seccomp.h> =A0 =A0 /* for seccomp_data */
>> +#include <linux/types.h>
>> +#include <linux/unistd.h>
>> +#include <stddef.h>
>> +
>> +#define BPF_LABELS_MAX 256
>> +struct bpf_labels {
>> + =A0 =A0 =A0 int count;
>> + =A0 =A0 =A0 struct __bpf_label {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 const char *label;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __u32 location;
>> + =A0 =A0 =A0 } labels[BPF_LABELS_MAX];
>> +};
>> +
>> +int bpf_resolve_jumps(struct bpf_labels *labels,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct sock_filter *filter=
, size_t count);
>> +__u32 seccomp_bpf_label(struct bpf_labels *labels, const char *labe=
l);
>> +void seccomp_bpf_print(struct sock_filter *filter, size_t count);
>> +
>> +#define JUMP_JT 0xff
>> +#define JUMP_JF 0xff
>> +#define LABEL_JT 0xfe
>> +#define LABEL_JF 0xfe
>> +
>> +#define ALLOW \
>> + =A0 =A0 =A0 BPF_STMT(BPF_RET+BPF_K, SECCOMP_RET_ALLOW)
>> +#define DENY \
>> + =A0 =A0 =A0 BPF_STMT(BPF_RET+BPF_K, SECCOMP_RET_KILL)
>> +#define JUMP(labels, label) \
>> + =A0 =A0 =A0 BPF_JUMP(BPF_JMP+BPF_JA, FIND_LABEL((labels), (label))=
, \
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0JUMP_JT, JUMP_JF)
>> +#define LABEL(labels, label) \
>> + =A0 =A0 =A0 BPF_JUMP(BPF_JMP+BPF_JA, FIND_LABEL((labels), (label))=
, \
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0LABEL_JT, LABEL_JF)
>> +#define SYSCALL(nr, jt) \
>> + =A0 =A0 =A0 BPF_JUMP(BPF_JMP+BPF_JEQ+BPF_K, (nr), 0, 1), \
>> + =A0 =A0 =A0 jt
>> +
>> +/* Lame, but just an example */
>> +#define FIND_LABEL(labels, label) seccomp_bpf_label((labels), #labe=
l)
>> +
>> +#define EXPAND(...) __VA_ARGS__
>> +/* Map all width-sensitive operations */
>> +#if __BITS_PER_LONG =3D=3D 32
>> +
>> +#define JEQ(x, jt) JEQ32(x, EXPAND(jt))
>> +#define JNE(x, jt) JNE32(x, EXPAND(jt))
>> +#define JGT(x, jt) JGT32(x, EXPAND(jt))
>> +#define JLT(x, jt) JLT32(x, EXPAND(jt))
>> +#define JGE(x, jt) JGE32(x, EXPAND(jt))
>> +#define JLE(x, jt) JLE32(x, EXPAND(jt))
>> +#define JA(x, jt) JA32(x, EXPAND(jt))
>> +#define ARG(i) ARG_32(i)
>> +#define LO_ARG(idx) offsetof(struct seccomp_data, args[(idx)])
>> +
>> +#elif __BITS_PER_LONG =3D=3D 64
>> +
>> +/* Ensure that we load the logically correct offset. */
>> +#if __BYTE_ORDER =3D=3D __LITTLE_ENDIAN
>> +#define ENDIAN(_lo, _hi) _lo, _hi
>> +#define LO_ARG(idx) offsetof(struct seccomp_data, args[(idx)])
>> +#define HI_ARG(idx) offsetof(struct seccomp_data, args[(idx)]) + si=
zeof(__u32)
>> +#elif __BYTE_ORDER =3D=3D __BIG_ENDIAN
>> +#define ENDIAN(_lo, _hi) _hi, _lo
>> +#define LO_ARG(idx) offsetof(struct seccomp_data, args[(idx)]) + si=
zeof(__u32)
>> +#define HI_ARG(idx) offsetof(struct seccomp_data, args[(idx)])
>> +#else
>> +#error "Unknown endianness"
>> +#endif
>> +
>> +union arg64 {
>> + =A0 =A0 =A0 struct {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __u32 ENDIAN(lo32, hi32);
>> + =A0 =A0 =A0 };
>> + =A0 =A0 =A0 __u64 u64;
>> +};
>> +
>> +#define JEQ(x, jt) \
>> + =A0 =A0 =A0 JEQ64(((union arg64){.u64 =3D (x)}).lo32, \
>> + =A0 =A0 =A0 =A0 =A0 =A0 ((union arg64){.u64 =3D (x)}).hi32, \
>> + =A0 =A0 =A0 =A0 =A0 =A0 EXPAND(jt))
>> +#define JGT(x, jt) \
>> + =A0 =A0 =A0 JGT64(((union arg64){.u64 =3D (x)}).lo32, \
>> + =A0 =A0 =A0 =A0 =A0 =A0 ((union arg64){.u64 =3D (x)}).hi32, \
>> + =A0 =A0 =A0 =A0 =A0 =A0 EXPAND(jt))
>> +#define JGE(x, jt) \
>> + =A0 =A0 =A0 JGE64(((union arg64){.u64 =3D (x)}).lo32, \
>> + =A0 =A0 =A0 =A0 =A0 =A0 ((union arg64){.u64 =3D (x)}).hi32, \
>> + =A0 =A0 =A0 =A0 =A0 =A0 EXPAND(jt))
>> +#define JNE(x, jt) \
>> + =A0 =A0 =A0 JNE64(((union arg64){.u64 =3D (x)}).lo32, \
>> + =A0 =A0 =A0 =A0 =A0 =A0 ((union arg64){.u64 =3D (x)}).hi32, \
>> + =A0 =A0 =A0 =A0 =A0 =A0 EXPAND(jt))
>> +#define JLT(x, jt) \
>> + =A0 =A0 =A0 JLT64(((union arg64){.u64 =3D (x)}).lo32, \
>> + =A0 =A0 =A0 =A0 =A0 =A0 ((union arg64){.u64 =3D (x)}).hi32, \
>> + =A0 =A0 =A0 =A0 =A0 =A0 EXPAND(jt))
>> +#define JLE(x, jt) \
>> + =A0 =A0 =A0 JLE64(((union arg64){.u64 =3D (x)}).lo32, \
>> + =A0 =A0 =A0 =A0 =A0 =A0 ((union arg64){.u64 =3D (x)}).hi32, \
>> + =A0 =A0 =A0 =A0 =A0 =A0 EXPAND(jt))
>> +
>> +#define JA(x, jt) \
>> + =A0 =A0 =A0 JA64(((union arg64){.u64 =3D (x)}).lo32, \
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0((union arg64){.u64 =3D (x)}).hi32, \
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0EXPAND(jt))
>> +#define ARG(i) ARG_64(i)
>> +
>> +#else
>> +#error __BITS_PER_LONG value unusable.
>> +#endif
>> +
>> +/* Loads the arg into A */
>> +#define ARG_32(idx) \
>> + =A0 =A0 =A0 BPF_STMT(BPF_LD+BPF_W+BPF_ABS, LO_ARG(idx))
>> +
>> +/* Loads hi into A and lo in X */
>> +#define ARG_64(idx) \
>> + =A0 =A0 =A0 BPF_STMT(BPF_LD+BPF_W+BPF_ABS, LO_ARG(idx)), \
>> + =A0 =A0 =A0 BPF_STMT(BPF_ST, 0), /* lo -> M[0] */ \
>> + =A0 =A0 =A0 BPF_STMT(BPF_LD+BPF_W+BPF_ABS, HI_ARG(idx)), \
>> + =A0 =A0 =A0 BPF_STMT(BPF_ST, 1) /* hi -> M[1] */
>> +
>> +#define JEQ32(value, jt) \
>> + =A0 =A0 =A0 BPF_JUMP(BPF_JMP+BPF_JEQ+BPF_K, (value), 0, 1), \
>> + =A0 =A0 =A0 jt
>> +
>> +#define JNE32(value, jt) \
>> + =A0 =A0 =A0 BPF_JUMP(BPF_JMP+BPF_JEQ+BPF_K, (value), 1, 0), \
>> + =A0 =A0 =A0 jt
>> +
>> +/* Checks the lo, then swaps to check the hi. A=3Dlo,X=3Dhi */
>> +#define JEQ64(lo, hi, jt) \
>> + =A0 =A0 =A0 BPF_JUMP(BPF_JMP+BPF_JEQ+BPF_K, (hi), 0, 5), \
>> + =A0 =A0 =A0 BPF_STMT(BPF_LD+BPF_MEM, 0), /* swap in lo */ \
>> + =A0 =A0 =A0 BPF_JUMP(BPF_JMP+BPF_JEQ+BPF_K, (lo), 0, 2), \
>> + =A0 =A0 =A0 BPF_STMT(BPF_LD+BPF_MEM, 1), /* passed: swap hi back i=
n */ \
>> + =A0 =A0 =A0 jt, \
>> + =A0 =A0 =A0 BPF_STMT(BPF_LD+BPF_MEM, 1) /* failed: swap hi back in=
 */
>> +
>> +#define JNE64(lo, hi, jt) \
>> + =A0 =A0 =A0 BPF_JUMP(BPF_JMP+BPF_JEQ+BPF_K, (hi), 5, 0), \
>> + =A0 =A0 =A0 BPF_STMT(BPF_LD+BPF_MEM, 0), /* swap in lo */ \
>> + =A0 =A0 =A0 BPF_JUMP(BPF_JMP+BPF_JEQ+BPF_K, (lo), 2, 0), \
>> + =A0 =A0 =A0 BPF_STMT(BPF_LD+BPF_MEM, 1), /* passed: swap hi back i=
n */ \
>> + =A0 =A0 =A0 jt, \
>> + =A0 =A0 =A0 BPF_STMT(BPF_LD+BPF_MEM, 1) /* failed: swap hi back in=
 */
>> +
>> +#define JA32(value, jt) \
>> + =A0 =A0 =A0 BPF_JUMP(BPF_JMP+BPF_JSET+BPF_K, (value), 0, 1), \
>> + =A0 =A0 =A0 jt
>> +
>> +#define JA64(lo, hi, jt) \
>> + =A0 =A0 =A0 BPF_JUMP(BPF_JMP+BPF_JSET+BPF_K, (hi), 3, 0), \
>> + =A0 =A0 =A0 BPF_STMT(BPF_LD+BPF_MEM, 0), /* swap in lo */ \
>> + =A0 =A0 =A0 BPF_JUMP(BPF_JMP+BPF_JSET+BPF_K, (lo), 0, 2), \
>> + =A0 =A0 =A0 BPF_STMT(BPF_LD+BPF_MEM, 1), /* passed: swap hi back i=
n */ \
>> + =A0 =A0 =A0 jt, \
>> + =A0 =A0 =A0 BPF_STMT(BPF_LD+BPF_MEM, 1) /* failed: swap hi back in=
 */
>> +
>> +#define JGE32(value, jt) \
>> + =A0 =A0 =A0 BPF_JUMP(BPF_JMP+BPF_JGE+BPF_K, (value), 0, 1), \
>> + =A0 =A0 =A0 jt
>> +
>> +#define JLT32(value, jt) \
>> + =A0 =A0 =A0 BPF_JUMP(BPF_JMP+BPF_JGE+BPF_K, (value), 1, 0), \
>> + =A0 =A0 =A0 jt
>> +
>> +/* Shortcut checking if hi > arg.hi. */
>> +#define JGE64(lo, hi, jt) \
>> + =A0 =A0 =A0 BPF_JUMP(BPF_JMP+BPF_JGT+BPF_K, (hi), 4, 0), \
>> + =A0 =A0 =A0 BPF_JUMP(BPF_JMP+BPF_JEQ+BPF_K, (hi), 0, 5), \
>> + =A0 =A0 =A0 BPF_STMT(BPF_LD+BPF_MEM, 0), /* swap in lo */ \
>> + =A0 =A0 =A0 BPF_JUMP(BPF_JMP+BPF_JGE+BPF_K, (lo), 0, 2), \
>> + =A0 =A0 =A0 BPF_STMT(BPF_LD+BPF_MEM, 1), /* passed: swap hi back i=
n */ \
>> + =A0 =A0 =A0 jt, \
>> + =A0 =A0 =A0 BPF_STMT(BPF_LD+BPF_MEM, 1) /* failed: swap hi back in=
 */
>> +
>> +#define JLT64(lo, hi, jt) \
>> + =A0 =A0 =A0 BPF_JUMP(BPF_JMP+BPF_JGE+BPF_K, (hi), 0, 4), \
>> + =A0 =A0 =A0 BPF_JUMP(BPF_JMP+BPF_JEQ+BPF_K, (hi), 0, 5), \
>> + =A0 =A0 =A0 BPF_STMT(BPF_LD+BPF_MEM, 0), /* swap in lo */ \
>> + =A0 =A0 =A0 BPF_JUMP(BPF_JMP+BPF_JGT+BPF_K, (lo), 2, 0), \
>> + =A0 =A0 =A0 BPF_STMT(BPF_LD+BPF_MEM, 1), /* passed: swap hi back i=
n */ \
>> + =A0 =A0 =A0 jt, \
>> + =A0 =A0 =A0 BPF_STMT(BPF_LD+BPF_MEM, 1) /* failed: swap hi back in=
 */
>> +
>> +#define JGT32(value, jt) \
>> + =A0 =A0 =A0 BPF_JUMP(BPF_JMP+BPF_JGT+BPF_K, (value), 0, 1), \
>> + =A0 =A0 =A0 jt
>> +
>> +#define JLE32(value, jt) \
>> + =A0 =A0 =A0 BPF_JUMP(BPF_JMP+BPF_JGT+BPF_K, (value), 1, 0), \
>> + =A0 =A0 =A0 jt
>> +
>> +/* Check hi > args.hi first, then do the GE checking */
>> +#define JGT64(lo, hi, jt) \
>> + =A0 =A0 =A0 BPF_JUMP(BPF_JMP+BPF_JGT+BPF_K, (hi), 4, 0), \
>> + =A0 =A0 =A0 BPF_JUMP(BPF_JMP+BPF_JEQ+BPF_K, (hi), 0, 5), \
>> + =A0 =A0 =A0 BPF_STMT(BPF_LD+BPF_MEM, 0), /* swap in lo */ \
>> + =A0 =A0 =A0 BPF_JUMP(BPF_JMP+BPF_JGT+BPF_K, (lo), 0, 2), \
>> + =A0 =A0 =A0 BPF_STMT(BPF_LD+BPF_MEM, 1), /* passed: swap hi back i=
n */ \
>> + =A0 =A0 =A0 jt, \
>> + =A0 =A0 =A0 BPF_STMT(BPF_LD+BPF_MEM, 1) /* failed: swap hi back in=
 */
>> +
>> +#define JLE64(lo, hi, jt) \
>> + =A0 =A0 =A0 BPF_JUMP(BPF_JMP+BPF_JGT+BPF_K, (hi), 6, 0), \
>> + =A0 =A0 =A0 BPF_JUMP(BPF_JMP+BPF_JEQ+BPF_K, (hi), 0, 3), \
>> + =A0 =A0 =A0 BPF_STMT(BPF_LD+BPF_MEM, 0), /* swap in lo */ \
>> + =A0 =A0 =A0 BPF_JUMP(BPF_JMP+BPF_JGT+BPF_K, (lo), 2, 0), \
>> + =A0 =A0 =A0 BPF_STMT(BPF_LD+BPF_MEM, 1), /* passed: swap hi back i=
n */ \
>> + =A0 =A0 =A0 jt, \
>> + =A0 =A0 =A0 BPF_STMT(BPF_LD+BPF_MEM, 1) /* failed: swap hi back in=
 */
>> +
>> +#define LOAD_SYSCALL_NR \
>> + =A0 =A0 =A0 BPF_STMT(BPF_LD+BPF_W+BPF_ABS, \
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0offsetof(struct seccomp_data, nr))
>> +
>> +#endif =A0/* __BPF_HELPER_H__ */
>> diff --git a/samples/seccomp/dropper.c b/samples/seccomp/dropper.c
>> new file mode 100644
>> index 0000000..c69c347
>> --- /dev/null
>> +++ b/samples/seccomp/dropper.c
>> @@ -0,0 +1,68 @@
>> +/*
>> + * Naive system call dropper built on seccomp_filter.
>> + *
>> + * Copyright (c) 2012 The Chromium OS Authors <chromium-os-dev@chro=
mium.org>
>> + * Author: Will Drewry <wad@chromium.org>
>> + *
>> + * The code may be used by anyone for any purpose,
>> + * and can serve as a starting point for developing
>> + * applications using prctl(PR_SET_SECCOMP, 2, ...).
>> + *
>> + * When run, returns the specified errno for the specified
>> + * system call number against the given architecture.
>> + *
>> + * Run this one as root as PR_SET_NO_NEW_PRIVS is not called.
>> + */
>> +
>> +#include <errno.h>
>> +#include <linux/audit.h>
>> +#include <linux/filter.h>
>> +#include <linux/seccomp.h>
>> +#include <linux/unistd.h>
>> +#include <stdio.h>
>> +#include <stddef.h>
>> +#include <stdlib.h>
>> +#include <sys/prctl.h>
>> +#include <unistd.h>
>> +
>> +static int install_filter(int nr, int arch, int error)
>> +{
>> + =A0 =A0 =A0 struct sock_filter filter[] =3D {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 BPF_STMT(BPF_LD+BPF_W+BPF_ABS,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(offsetof(struct se=
ccomp_data, arch))),
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 BPF_JUMP(BPF_JMP+BPF_JEQ+BPF_K, arch, =
0, 3),
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 BPF_STMT(BPF_LD+BPF_W+BPF_ABS,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(offsetof(struct se=
ccomp_data, nr))),
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 BPF_JUMP(BPF_JMP+BPF_JEQ+BPF_K, nr, 0,=
 1),
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 BPF_STMT(BPF_RET+BPF_K,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0SECCOMP_RET_ERRNO|(=
error & SECCOMP_RET_DATA)),
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 BPF_STMT(BPF_RET+BPF_K, SECCOMP_RET_AL=
LOW),
>> + =A0 =A0 =A0 };
>> + =A0 =A0 =A0 struct sock_fprog prog =3D {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .len =3D (unsigned short)(sizeof(filte=
r)/sizeof(filter[0])),
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .filter =3D filter,
>> + =A0 =A0 =A0 };
>> + =A0 =A0 =A0 if (prctl(PR_SET_SECCOMP, 2, &prog)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 perror("prctl");
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 1;
>> + =A0 =A0 =A0 }
>> + =A0 =A0 =A0 return 0;
>> +}
>> +
>> +int main(int argc, char **argv)
>> +{
>> + =A0 =A0 =A0 if (argc < 5) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 fprintf(stderr, "Usage:\n"
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "dropper <syscall_nr> =
<arch> <errno> <prog> [<args>]\n"
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "Hint: =A0AUDIT_ARCH_I=
386: 0x%X\n"
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 " =A0 =A0 =A0 AUDIT_AR=
CH_X86_64: 0x%X\n"
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "\n", AUDIT_ARCH_I386,=
 AUDIT_ARCH_X86_64);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 1;
>> + =A0 =A0 =A0 }
>> + =A0 =A0 =A0 if (install_filter(strtol(argv[1], NULL, 0), strtol(ar=
gv[2], NULL, 0),
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0strtol(argv[3],=
 NULL, 0)))
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 1;
>> + =A0 =A0 =A0 execv(argv[4], &argv[4]);
>> + =A0 =A0 =A0 printf("Failed to execv\n");
>> + =A0 =A0 =A0 return 255;
>> +}
>> --
>> 1.7.5.4
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
--
To unsubscribe from this list: send the line "unsubscribe linux-securit=
y-module" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
