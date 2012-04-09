From: Will Drewry <wad@chromium.org>
Subject: Re: [PATCH v17 07/15] asm/syscall.h: add syscall_get_arch
Date: Mon, 9 Apr 2012 14:24:00 -0500
Message-ID: <CABqD9hYKSGk4BiwcDstd8xVmGmTRPdBE-LMUq0oP_1ydcv3-VQ@mail.gmail.com>
References: <1333051320-30872-1-git-send-email-wad@chromium.org>
	<1333051320-30872-8-git-send-email-wad@chromium.org>
	<20120406130544.3d317192.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org,
	linux-security-module@vger.kernel.org, linux-arch@vger.kernel.org,
	linux-doc@vger.kernel.org, kernel-hardening@lists.openwall.com,
	netdev@vger.kernel.org, x86@kernel.org, arnd@arndb.de,
	davem@davemloft.net, hpa@zytor.com, mingo@redhat.com,
	oleg@redhat.com, peterz@infradead.org, rdunlap@xenotime.net,
	mcgrathr@chromium.org, tglx@linutronix.de, luto@mit.edu,
	eparis@redhat.com, serge.hallyn@canonical.com, djm@mindrot.org,
	scarybeasts@gmail.com, indan@nul.nu, pmoore@redhat.com,
	corbet@lwn.net, eric.dumazet@gmail.com, markus@chromium.org,
	coreyb@linux.vnet.ibm.com, keescook@chromium.org, jmorris@namei.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <20120406130544.3d317192.akpm@linux-foundation.org>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 6, 2012 at 3:05 PM, Andrew Morton <akpm@linux-foundation.or=
g> wrote:
> On Thu, 29 Mar 2012 15:01:52 -0500
> Will Drewry <wad@chromium.org> wrote:
>
>> Adds a stub for a function that will return the AUDIT_ARCH_*
>> value appropriate to the supplied task based on the system
>> call convention.
>>
>> For audit's use, the value can generally be hard-coded at the
>> audit-site. =A0However, for other functionality not inlined into
>> syscall entry/exit, this makes that information available.
>> seccomp_filter is the first planned consumer and, as such,
>> the comment indicates a tie to HAVE_ARCH_SECCOMP_FILTER. =A0That
>
> Should be "CONFIG_HAVE_ARCH_SECCOMP_FILTER", I hope.

yes!

>
>> is probably an unneeded detail.
>>
>> ...
>>
>> --- a/include/asm-generic/syscall.h
>> +++ b/include/asm-generic/syscall.h
>> @@ -142,4 +142,18 @@ void syscall_set_arguments(struct task_struct *=
task, struct pt_regs *regs,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned int i, u=
nsigned int n,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0const unsigned lo=
ng *args);
>>
>> +/**
>> + * syscall_get_arch - return the AUDIT_ARCH for the current system =
call
>> + * @task: =A0 =A0task of interest, must be in system call entry tra=
cing
>> + * @regs: =A0 =A0task_pt_regs() of @task
>> + *
>> + * Returns the AUDIT_ARCH_* based on the system call convention in =
use.
>> + *
>> + * It's only valid to call this when @task is stopped on entry to a=
 system
>> + * call, due to %TIF_SYSCALL_TRACE, %TIF_SYSCALL_AUDIT, or %TIF_SEC=
COMP.
>> + *
>> + * Note, at present this function is only required with
>> + * CONFIG_HAVE_ARCH_SECCOMP_FILTER.
>> + */
>> +int syscall_get_arch(struct task_struct *task, struct pt_regs *regs=
);
>> =A0#endif =A0 =A0 =A0 /* _ASM_SYSCALL_H */
>
> So architectures which permit CONFIG_HAVE_ARCH_SECCOMP_FILTER must
> provide an implementation of this.

Much better wording.

In practice, many of the existing places that audit arch is needed
already know the calling convention because they happen in asm or have
hardcoded values.  It may be that other consumers may want this
information later, like ftrace, but I'm not sure of any that will
immediately benefit from it right now.
