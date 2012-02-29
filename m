From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH v11 10/12] ptrace,seccomp: Add PTRACE_SECCOMP support
Date: Wed, 29 Feb 2012 17:14:37 +0100
Message-ID: <20120229161437.GA3078@redhat.com>
References: <1330140111-17201-1-git-send-email-wad@chromium.org> <1330140111-17201-10-git-send-email-wad@chromium.org> <20120227175407.GD10608@redhat.com> <CABqD9hY1P7LfmBwQwSG7jDZmw6d_pZH4q2cZq_4ssjQUKRA32w@mail.gmail.com> <20120228164335.GC3664@redhat.com> <CABqD9hY7=DpxWzf3+WNsK=LuLrabf=oHxyy+CQgu0JLxZ80zPQ@mail.gmail.com> <CABqD9hZ3apFGi+BmX5UNgz=NJUbTigj6acDKG=wu9rrL0wN1Ww@mail.gmail.com>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
        linux-doc@vger.kernel.org, kernel-hardening@lists.openwall.com,
        netdev@vger.kernel.org, x86@kernel.org, arnd@arndb.de,
        davem@davemloft.net, hpa@zytor.com, mingo@redhat.com,
        peterz@infradead.org, rdunlap@xenotime.net, mcgrathr@chromium.org,
        tglx@linutronix.de, luto@mit.edu, eparis@redhat.com,
        serge.hallyn@canonical.com, djm@mindrot.org, scarybeasts@gmail.com,
        indan@nul.nu, pmoore@redhat.com, akpm@linux-foundation.org,
        corbet@lwn.net, eric.dumazet@gmail.com, markus@chromium.org,
        coreyb@linux.vnet.ibm.com, keescook@chromium.org,
        Denys Vlasenko <dvlasenk@redhat.com>
To: Will Drewry <wad@chromium.org>
Return-path: <kernel-hardening-return-1001-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
Content-Disposition: inline
In-Reply-To: <CABqD9hZ3apFGi+BmX5UNgz=NJUbTigj6acDKG=wu9rrL0wN1Ww@mail.gmail.com>
List-Id: netdev.vger.kernel.org

On 02/28, Will Drewry wrote:
>
> On Tue, Feb 28, 2012 at 11:04 AM, Will Drewry <wad@chromium.org> wrote:
> > On Tue, Feb 28, 2012 at 10:43 AM, Oleg Nesterov <oleg@redhat.com> wrote:
> >>
> >> Great. In this case this patch becomes really trivial. Just 2 defines
> >> in ptrace.h and the unconditional ptrace_event() under SECCOMP_RET_TRACE.
>
> hrm the only snag is that I can't then rely on TIF_SYSCALL_TRACE to
> ensure seccomp is in the slow-path.  Right now, on x86, seccomp is
> slow-path, but it doesn't have to be to have the syscall and args.
> However, for ptrace to behavior properly, I believed it did need to be
> in the slow path.  If SECCOMP_RET_TRACE doesn't rely on
> PTRACE_SYSCALL, then it introduces a need for seccomp to always be in
> the slow path or to flag (somehow) when it needs slow path.

My understanding of this magic is very limited, and I'm afraid
I misunderstood... So please correct me.

But what is the problem? system_call checks _TIF_WORK_SYSCALL_ENTRY
which includes _TIF_SECCOMP | _TIF_SYSCALL_TRACE, and jumps to
tracesys which does SAVE_REST.

Anyway. secure_computing() is called by syscall_trace_enter() which
also calls tracehook_report_syscall_entry(). If SECCOMP_RET_TRACE
can't do ptrace_event() then why tracehook_report_syscall_entry() is
fine?

Oleg.
