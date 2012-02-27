From: Eric Paris <eparis@redhat.com>
Subject: Re: [PATCH v11 06/12] seccomp: add system call filtering using BPF
Date: Mon, 27 Feb 2012 14:25:33 -0500
Message-ID: <1330370733.2542.18.camel@localhost>
References: <1330140111-17201-1-git-send-email-wad@chromium.org>
	 <1330140111-17201-6-git-send-email-wad@chromium.org>
	 <20120226202828.GE3990@outflux.net>
	 <CABqD9hbKU=EVagCfo25AZsNoq=hmzkeOxK6mE=q8m=Be-ZFb9w@mail.gmail.com>
	 <1330361396.2542.11.camel@localhost>
	 <CAGXu5jKJ7pYeULM=CvifpQ8jUoyH6Ska2Znx9tGjhz0tn5kZmQ@mail.gmail.com>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Will Drewry <wad@chromium.org>, Kees Cook <kees@ubuntu.com>,
        linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
        linux-doc@vger.kernel.org, kernel-hardening@lists.openwall.com,
        netdev@vger.kernel.org, x86@kernel.org, arnd@arndb.de,
        davem@davemloft.net, hpa@zytor.com, mingo@redhat.com, oleg@redhat.com,
        peterz@infradead.org, rdunlap@xenotime.net, mcgrathr@chromium.org,
        tglx@linutronix.de, luto@mit.edu, serge.hallyn@canonical.com,
        djm@mindrot.org, scarybeasts@gmail.com, indan@nul.nu,
        pmoore@redhat.com, akpm@linux-foundation.org, corbet@lwn.net,
        eric.dumazet@gmail.com, markus@chromium.org, coreyb@linux.vnet.ibm.com
To: Kees Cook <keescook@chromium.org>
Return-path: <kernel-hardening-return-981-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <CAGXu5jKJ7pYeULM=CvifpQ8jUoyH6Ska2Znx9tGjhz0tn5kZmQ@mail.gmail.com>
List-Id: netdev.vger.kernel.org

On Mon, 2012-02-27 at 10:55 -0800, Kees Cook wrote:
> On Mon, Feb 27, 2012 at 8:49 AM, Eric Paris <eparis@redhat.com> wrote:

> You mean as used in audit_log_exit() ? It looks like that depends on a
> lot of state cached in __audit_syscall_entry() and finally triggered
> in __audit_syscall_exit() (and ..._free()). I don't think this is
> really want seccomp wants to be involved in.
> 
> By CONFIG_AUDITSC, you mean CONFIG_AUDITSYSCALL? Without that set,
> audit_seccomp is a no-op.
> 
> The reason compat needs to be reported (or rather, arch) is because
> just reporting syscall is ambiguous. It either needs arch or compat to
> distinguish it.

Yes, that is what I mean and you are right.  You shouldn't push the
syscall in this record either.  If !audit_dummy_context() you are
already going to get arch, syscall, and a0-a4 in the associated audit
record.  Please do not duplicate that info.

It might make sense to have a separate audit_seccomp() path when
audit_dummy_context() which includes arch, syscall, and a0-a4.

It is my fault (85e7bac3) that we have syscall at all, but I'm on a new
crusade to remove audit record duplication.  So I'd happily see a patch
in this series that removes that instead of adds to it.

-Eric
