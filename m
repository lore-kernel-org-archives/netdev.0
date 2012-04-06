From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v17 07/15] asm/syscall.h: add syscall_get_arch
Date: Fri, 6 Apr 2012 13:05:44 -0700
Message-ID: <20120406130544.3d317192.akpm@linux-foundation.org>
References: <1333051320-30872-1-git-send-email-wad@chromium.org>
	<1333051320-30872-8-git-send-email-wad@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
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
To: Will Drewry <wad@chromium.org>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <1333051320-30872-8-git-send-email-wad@chromium.org>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 29 Mar 2012 15:01:52 -0500
Will Drewry <wad@chromium.org> wrote:

> Adds a stub for a function that will return the AUDIT_ARCH_*
> value appropriate to the supplied task based on the system
> call convention.
> 
> For audit's use, the value can generally be hard-coded at the
> audit-site.  However, for other functionality not inlined into
> syscall entry/exit, this makes that information available.
> seccomp_filter is the first planned consumer and, as such,
> the comment indicates a tie to HAVE_ARCH_SECCOMP_FILTER.  That

Should be "CONFIG_HAVE_ARCH_SECCOMP_FILTER", I hope.

> is probably an unneeded detail.
> 
> ...
>
> --- a/include/asm-generic/syscall.h
> +++ b/include/asm-generic/syscall.h
> @@ -142,4 +142,18 @@ void syscall_set_arguments(struct task_struct *task, struct pt_regs *regs,
>  			   unsigned int i, unsigned int n,
>  			   const unsigned long *args);
>  
> +/**
> + * syscall_get_arch - return the AUDIT_ARCH for the current system call
> + * @task:	task of interest, must be in system call entry tracing
> + * @regs:	task_pt_regs() of @task
> + *
> + * Returns the AUDIT_ARCH_* based on the system call convention in use.
> + *
> + * It's only valid to call this when @task is stopped on entry to a system
> + * call, due to %TIF_SYSCALL_TRACE, %TIF_SYSCALL_AUDIT, or %TIF_SECCOMP.
> + *
> + * Note, at present this function is only required with
> + * CONFIG_HAVE_ARCH_SECCOMP_FILTER.
> + */
> +int syscall_get_arch(struct task_struct *task, struct pt_regs *regs);
>  #endif	/* _ASM_SYSCALL_H */

So architectures which permit CONFIG_HAVE_ARCH_SECCOMP_FILTER must
provide an implementation of this.
