From: Eric Paris <eparis@redhat.com>
Subject: Re: Re: [PATCH v17 09/15] seccomp: remove
 duplicated failure logging
Date: Mon, 09 Apr 2012 15:33:08 -0400
Message-ID: <1333999988.14260.9.camel@localhost>
References: <1333051320-30872-1-git-send-email-wad@chromium.org>
	 <1333051320-30872-10-git-send-email-wad@chromium.org>
	 <20120406141415.93f46bc6.akpm@linux-foundation.org>
	 <CABqD9hZVZQXA5cyufwWirWVUYZwSkjRxHR2CBKW5V62qD-DGtA@mail.gmail.com>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
        Kees Cook
 <keescook@chromium.org>, linux-kernel@vger.kernel.org,
        linux-security-module@vger.kernel.org, linux-arch@vger.kernel.org,
        linux-doc@vger.kernel.org, netdev@vger.kernel.org, x86@kernel.org,
        arnd@arndb.de, davem@davemloft.net, hpa@zytor.com, mingo@redhat.com,
        oleg@redhat.com, peterz@infradead.org, rdunlap@xenotime.net,
        mcgrathr@chromium.org, tglx@linutronix.de, luto@mit.edu,
        serge.hallyn@canonical.com, djm@mindrot.org, scarybeasts@gmail.com,
        indan@nul.nu, pmoore@redhat.com, corbet@lwn.net,
        eric.dumazet@gmail.com, markus@chromium.org, coreyb@linux.vnet.ibm.com,
        jmorris@namei.org
To: kernel-hardening@lists.openwall.com
Return-path: <kernel-hardening-return-1223-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <CABqD9hZVZQXA5cyufwWirWVUYZwSkjRxHR2CBKW5V62qD-DGtA@mail.gmail.com>
List-Id: netdev.vger.kernel.org

On Mon, 2012-04-09 at 14:26 -0500, Will Drewry wrote:
> On Fri, Apr 6, 2012 at 4:14 PM, Andrew Morton <akpm@linux-foundation.org> wrote:
> > On Thu, 29 Mar 2012 15:01:54 -0500
> > Will Drewry <wad@chromium.org> wrote:

> >> -void __audit_seccomp(unsigned long syscall)
> >> +void __audit_seccomp(unsigned long syscall, long signr, int code)
> >>  {
> >>       struct audit_buffer *ab;
> >>
> >>       ab = audit_log_start(NULL, GFP_KERNEL, AUDIT_ANOM_ABEND);
> >> -     audit_log_abend(ab, "seccomp", SIGKILL);
> >> +     audit_log_abend(ab, "seccomp", signr);
> >>       audit_log_format(ab, " syscall=%ld", syscall);
> >> +#ifdef CONFIG_COMPAT
> >> +     audit_log_format(ab, " compat=%d", is_compat_task());
> >> +#endif
> >
> > We don't need the ifdef for compilation reasons now.
> >
> > The question is: should we emit the compat= record on
> > non-compat-capable architectures?  Doing so would be safer - making it
> > conditional invites people to write x86-only usersapce.
> 
> I'd certainly prefer it always being there for exactly that reason.
> 
> Kees, Eric, any preferences?  Unless I hear one, I'll just drop the
> ifdefs in the next revision.

I'd just leave it in unconditionally.  The audit parse libraries would
handle it just fine, but that doesn't mean everyone uses that tool to
parse the text.

-Eric
