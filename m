From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: [PATCH v8 3/8] seccomp: add system call filtering using BPF
Date: Thu, 16 Feb 2012 20:12:12 -0800
Message-ID: <4F3DD39C.9090905@zytor.com>
References: <1329422549-16407-1-git-send-email-wad@chromium.org> <1329422549-16407-3-git-send-email-wad@chromium.org> <4F3D61CB.2000301@zytor.com> <CABqD9hb3WxKxLZ2GuUrbDM--koW+a3ser5TU8y6+e0sAhOT9dw@mail.gmail.com> <4F3D7250.6040504@zytor.com> <CAE6n16kweRehdozft0tKOB1P5LtGFJDCLQP=2EXfm8P0enyH=A@mail.gmail.com> <4F3D766E.7040205@zytor.com> <CABqD9haWxRLac1w3m9rSmyDvcg8jxYcxdmAAsgB7pEEBMHr=2g@mail.gmail.com> <4F3D7DD4.6070103@zytor.com> <CABqD9hZd41AWZub+wxGWwxJtGWfk+pVWQhn7DM_0q0tS9r_wDA@mail.gmail.com> <1329439809.2337.32.camel@localhost> <CABqD9hY06gaA7T8f0Te9PFpip6ix7CcbRShWcXutxbivEZJ2og@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Eric Paris <eparis@redhat.com>,
	Markus Gutschke <markus@chromium.org>,
	linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
	linux-doc@vger.kernel.org, kernel-hardening@lists.openwall.com,
	netdev@vger.kernel.org, x86@kernel.org, arnd@arndb.de,
	davem@davemloft.net, mingo@redhat.com, oleg@redhat.com,
	peterz@infradead.org, rdunlap@xenotime.net, mcgrathr@chromium.org,
	tglx@linutronix.de, luto@mit.edu, serge.hallyn@canonical.com,
	djm@mindrot.org, scarybeasts@gmail.com, indan@nul.nu,
	pmoore@redhat.com, akpm@linux-foundation.org, corbet@lwn.net,
	eric.dumazet@gmail.com, keescook@chromium.org
To: Will Drewry <wad@chromium.org>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <CABqD9hY06gaA7T8f0Te9PFpip6ix7CcbRShWcXutxbivEZJ2og@mail.gmail.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/16/2012 07:53 PM, Will Drewry wrote:
> 
> An earlier change Roland had prodded me toward was adding a
> syscall_get_arch() call to asm/syscall.h which returned the
> appropriate audit arch value for the current calling convention.  I
> hate to suggest this, but should I go ahead and wire that up for x86
> now, make it a dependency for HAVE_ARCH_SECCOMP_FILTER (and officially
> part of asm/syscall.h) then let it trickle into existence?  Maybe
> something like:
> 

... and we have been talking about making a regset and export it to
ptrace and core dumps, too.

> static inline int syscall_get_arch(struct task_struct *task, struct
> pt_regs *regs)
> {
> #ifdef CONFIG_IA32_EMULATION
>   if (task_thread_info(task)->status & TS_COMPAT)
>     return AUDIT_ARCH_I386;
> #endif
> #ifdef CONFIG_64BIT
>   return AUDIT_ARCH_X86_64;
> #else
>   return AUDIT_ARCH_I386;
> #endif
> }
> 

In this case it could be is_compat_task().

> There would be no other callers, though, because everywhere AUDIT_ARCH
> is used it is hardcoded as appropriate.  Then when x32 comes along, it
> can figure out where it belongs using tif status and/or regs.

For x32 you have the option of introducing a new value or relying on bit
30 in eax (and AUDIT_ARCH_X86_64).  The latter is more natural, probably.

	-hpa

-- 
H. Peter Anvin, Intel Open Source Technology Center
I work for Intel.  I don't speak on their behalf.

