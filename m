From: Kees Cook <keescook@chromium.org>
Subject: Re: [kernel-hardening] Re: [PATCH v17 09/15] seccomp: remove
 duplicated failure logging
Date: Mon, 9 Apr 2012 12:39:46 -0700
Message-ID: <CAGXu5jKdxiDD40TfhgMk_dAAL9ApX+JfrfKDgRhfRCCWvpiTpg@mail.gmail.com>
References: <1333051320-30872-1-git-send-email-wad@chromium.org>
	<1333051320-30872-10-git-send-email-wad@chromium.org>
	<20120406141415.93f46bc6.akpm@linux-foundation.org>
	<CABqD9hZVZQXA5cyufwWirWVUYZwSkjRxHR2CBKW5V62qD-DGtA@mail.gmail.com>
	<1333999988.14260.9.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: kernel-hardening@lists.openwall.com,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org,
	linux-security-module@vger.kernel.org, linux-arch@vger.kernel.org,
	linux-doc@vger.kernel.org, netdev@vger.kernel.org, x86@kernel.org,
	arnd@arndb.de, davem@davemloft.net, hpa@zytor.com,
	mingo@redhat.com, oleg@redhat.com, peterz@infradead.org,
	rdunlap@xenotime.net, mcgrathr@chromium.org, tglx@linutronix.de,
	luto@mit.edu, serge.hallyn@canonical.com, djm@mindrot.org,
	scarybeasts@gmail.com, indan@nul.nu, pmoore@redhat.com,
	corbet@lwn.net, eric.dumazet@gmail.com, markus@chromium.org,
	coreyb@linux.vnet.ibm.com, jmorris@namei.org
To: Eric Paris <eparis@redhat.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <1333999988.14260.9.camel@localhost>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 9, 2012 at 12:33 PM, Eric Paris <eparis@redhat.com> wrote:
> On Mon, 2012-04-09 at 14:26 -0500, Will Drewry wrote:
>> On Fri, Apr 6, 2012 at 4:14 PM, Andrew Morton <akpm@linux-foundation=
=2Eorg> wrote:
>> > On Thu, 29 Mar 2012 15:01:54 -0500
>> > Will Drewry <wad@chromium.org> wrote:
>
>> >> -void __audit_seccomp(unsigned long syscall)
>> >> +void __audit_seccomp(unsigned long syscall, long signr, int code=
)
>> >> =A0{
>> >> =A0 =A0 =A0 struct audit_buffer *ab;
>> >>
>> >> =A0 =A0 =A0 ab =3D audit_log_start(NULL, GFP_KERNEL, AUDIT_ANOM_A=
BEND);
>> >> - =A0 =A0 audit_log_abend(ab, "seccomp", SIGKILL);
>> >> + =A0 =A0 audit_log_abend(ab, "seccomp", signr);
>> >> =A0 =A0 =A0 audit_log_format(ab, " syscall=3D%ld", syscall);
>> >> +#ifdef CONFIG_COMPAT
>> >> + =A0 =A0 audit_log_format(ab, " compat=3D%d", is_compat_task());
>> >> +#endif
>> >
>> > We don't need the ifdef for compilation reasons now.
>> >
>> > The question is: should we emit the compat=3D record on
>> > non-compat-capable architectures? =A0Doing so would be safer - mak=
ing it
>> > conditional invites people to write x86-only usersapce.
>>
>> I'd certainly prefer it always being there for exactly that reason.
>>
>> Kees, Eric, any preferences? =A0Unless I hear one, I'll just drop th=
e
>> ifdefs in the next revision.
>
> I'd just leave it in unconditionally. =A0The audit parse libraries wo=
uld
> handle it just fine, but that doesn't mean everyone uses that tool to
> parse the text.

Related to this, can we get this patch into a tree as well?
https://lkml.org/lkml/2012/3/23/332

Thanks,

-Kees

--=20
Kees Cook
ChromeOS Security
--
To unsubscribe from this list: send the line "unsubscribe linux-securit=
y-module" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
