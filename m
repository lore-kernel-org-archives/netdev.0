From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH v11 08/12] signal, x86: add SIGSYS info and make it
	synchronous.
Date: Mon, 27 Feb 2012 18:22:08 +0100
Message-ID: <20120227172208.GC10608@redhat.com>
References: <1330140111-17201-1-git-send-email-wad@chromium.org> <1330140111-17201-8-git-send-email-wad@chromium.org>
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
        coreyb@linux.vnet.ibm.com, keescook@chromium.org
To: Will Drewry <wad@chromium.org>
Return-path: <kernel-hardening-return-972-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
Content-Disposition: inline
In-Reply-To: <1330140111-17201-8-git-send-email-wad@chromium.org>
List-Id: netdev.vger.kernel.org

On 02/24, Will Drewry wrote:
>
> To ensure that SIGSYS delivery occurs on return from the triggering
> system call, SIGSYS is added to the SYNCHRONOUS_MASK macro.

Hmm. Can't understand... please help.

>  #define SYNCHRONOUS_MASK \
>  	(sigmask(SIGSEGV) | sigmask(SIGBUS) | sigmask(SIGILL) | \
> -	 sigmask(SIGTRAP) | sigmask(SIGFPE))
> +	 sigmask(SIGTRAP) | sigmask(SIGFPE) | sigmask(SIGSYS))

Why?

SYNCHRONOUS_MASK just tells dequeue_signal() "pick them first".
This is needed to make sure that the handler for, say SIGSEGV,
can use ucontext->ip as a faulting addr.

But seccomp adds info->si_call_addr, this looks unneeded.

Oleg.
