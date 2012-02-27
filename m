From: Will Drewry <wad@chromium.org>
Subject: Re: [PATCH v11 08/12] signal, x86: add SIGSYS info and make it synchronous.
Date: Mon, 27 Feb 2012 14:24:04 -0600
Message-ID: <CABqD9hbBj_c1qxD7N0ed3LMy_DXn-163LuNc1E7mSZbGO7oqyw@mail.gmail.com>
References: <1330140111-17201-1-git-send-email-wad@chromium.org>
	<1330140111-17201-8-git-send-email-wad@chromium.org>
	<20120227172208.GC10608@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
	linux-doc@vger.kernel.org, kernel-hardening@lists.openwall.com,
	netdev@vger.kernel.org, x86@kernel.org, arnd@arndb.de,
	davem@davemloft.net, hpa@zytor.com, mingo@redhat.com,
	peterz@infradead.org, rdunlap@xenotime.net, mcgrathr@chromium.org,
	tglx@linutronix.de, luto@mit.edu, eparis@redhat.com,
	serge.hallyn@canonical.com, djm@mindrot.org, scarybeasts@gmail.com,
	indan@nul.nu, pmoore@redhat.com, akpm@linux-foundation.org,
	corbet@lwn.net, eric.dumazet@gmail.com, markus@chromium.org,
	coreyb@linux.vnet.ibm.com, keescook@chromium.org
To: Oleg Nesterov <oleg@redhat.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <20120227172208.GC10608@redhat.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 27, 2012 at 11:22 AM, Oleg Nesterov <oleg@redhat.com> wrote=
:
> On 02/24, Will Drewry wrote:
>>
>> To ensure that SIGSYS delivery occurs on return from the triggering
>> system call, SIGSYS is added to the SYNCHRONOUS_MASK macro.
>
> Hmm. Can't understand... please help.
>
>> =A0#define SYNCHRONOUS_MASK \
>> =A0 =A0 =A0 (sigmask(SIGSEGV) | sigmask(SIGBUS) | sigmask(SIGILL) | =
\
>> - =A0 =A0 =A0sigmask(SIGTRAP) | sigmask(SIGFPE))
>> + =A0 =A0 =A0sigmask(SIGTRAP) | sigmask(SIGFPE) | sigmask(SIGSYS))
>
> Why?
>
> SYNCHRONOUS_MASK just tells dequeue_signal() "pick them first".
> This is needed to make sure that the handler for, say SIGSEGV,
> can use ucontext->ip as a faulting addr.

I think that Roland covered this.  (Since the syscall_rollback was
called it's nice to let our handler get first go.)

> But seccomp adds info->si_call_addr, this looks unneeded.

True enough.  I can drop it.  It'd only be useful if the SIGSYS wasn't
being forced and the signal was being handled without ucontext_t
access.

thanks!
