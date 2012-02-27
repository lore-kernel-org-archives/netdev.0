From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH v11 07/12] seccomp: add SECCOMP_RET_ERRNO
Date: Mon, 27 Feb 2012 19:14:34 +0100
Message-ID: <20120227181434.GA13903@redhat.com>
References: <1330140111-17201-1-git-send-email-wad@chromium.org> <1330140111-17201-7-git-send-email-wad@chromium.org> <20120227171132.GB10608@redhat.com> <CAGXu5jJQhfSSwTU5fSGR_Q57LAQBFW25A_FtR2GFsxyT_ibnzQ@mail.gmail.com>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: Will Drewry <wad@chromium.org>, linux-kernel@vger.kernel.org,
        linux-arch@vger.kernel.org, linux-doc@vger.kernel.org,
        kernel-hardening@lists.openwall.com, netdev@vger.kernel.org,
        x86@kernel.org, arnd@arndb.de, davem@davemloft.net, hpa@zytor.com,
        mingo@redhat.com, peterz@infradead.org, rdunlap@xenotime.net,
        mcgrathr@chromium.org, tglx@linutronix.de, luto@mit.edu,
        eparis@redhat.com, serge.hallyn@canonical.com, djm@mindrot.org,
        scarybeasts@gmail.com, indan@nul.nu, pmoore@redhat.com,
        akpm@linux-foundation.org, corbet@lwn.net, eric.dumazet@gmail.com,
        markus@chromium.org, coreyb@linux.vnet.ibm.com
To: Kees Cook <keescook@chromium.org>
Return-path: <kernel-hardening-return-977-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
Content-Disposition: inline
In-Reply-To: <CAGXu5jJQhfSSwTU5fSGR_Q57LAQBFW25A_FtR2GFsxyT_ibnzQ@mail.gmail.com>
List-Id: netdev.vger.kernel.org

On 02/27, Kees Cook wrote:
>
> On Mon, Feb 27, 2012 at 9:11 AM, Oleg Nesterov <oleg@redhat.com> wrote:
> > On 02/24, Will Drewry wrote:
> >>
> >>  static u32 seccomp_run_filters(int syscall)
> >>  {
> >>       struct seccomp_filter *f;
> >> -     u32 ret = SECCOMP_RET_KILL;
> >>       static const struct bpf_load_fn fns = {
> >>               bpf_load,
> >>               sizeof(struct seccomp_data),
> >>       };
> >> +     u32 ret = SECCOMP_RET_ALLOW;
> >>       const void *sc_ptr = (const void *)(uintptr_t)syscall;
> >>
> >> +     /* Ensure unexpected behavior doesn't result in failing open. */
> >> +     if (unlikely(current->seccomp.filter == NULL))
> >> +             ret = SECCOMP_RET_KILL;
> >
> > Is "seccomp.filter == NULL" really possible?
>
> It should not be, but I'm much more comfortable with this failing
> closed. I think it's important to be as defensive as possible with
> this code given its intended use.

Can't resists... Sorry, I know I am troll but personally I think
in this case the most defensive code is BUG_ON(->filter == NULL)
or at least WARN_ON().

Nevermind, I won't pretend I really understand the intended use,
please ignore.

Oleg.
