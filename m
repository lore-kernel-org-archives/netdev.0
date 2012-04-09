From: Kees Cook <keescook@chromium.org>
Subject: Re: [PATCH v17 09/15] seccomp: remove duplicated failure logging
Date: Mon, 9 Apr 2012 12:32:05 -0700
Message-ID: <CAGXu5jLSE72eX+rxnfyXdp=VvUi+gqy1apT9QcdA4ADM-H0awA@mail.gmail.com>
References: <1333051320-30872-1-git-send-email-wad@chromium.org>
	<1333051320-30872-10-git-send-email-wad@chromium.org>
	<20120406141415.93f46bc6.akpm@linux-foundation.org>
	<CABqD9hZVZQXA5cyufwWirWVUYZwSkjRxHR2CBKW5V62qD-DGtA@mail.gmail.com>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: Andrew Morton <akpm@linux-foundation.org>, Eric Paris <eparis@redhat.com>,
	linux-kernel@vger.kernel.org, linux-security-module@vger.kernel.org,
	linux-arch@vger.kernel.org, linux-doc@vger.kernel.org,
	kernel-hardening@lists.openwall.com, netdev@vger.kernel.org, x86@kernel.org,
	arnd@arndb.de, davem@davemloft.net, hpa@zytor.com, mingo@redhat.com,
	oleg@redhat.com, peterz@infradead.org, rdunlap@xenotime.net,
	mcgrathr@chromium.org, tglx@linutronix.de, luto@mit.edu,
	serge.hallyn@canonical.com, djm@mindrot.org, scarybeasts@gmail.com,
	indan@nul.nu, pmoore@redhat.com, corbet@lwn.net, eric.dumazet@gmail.com,
	markus@chromium.org, coreyb@linux.vnet.ibm.com, jmorris@namei.org
To: Will Drewry <wad@chromium.org>
Return-path: <kernel-hardening-return-1222-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
Sender: keescook@google.com
In-Reply-To: <CABqD9hZVZQXA5cyufwWirWVUYZwSkjRxHR2CBKW5V62qD-DGtA@mail.gmail.com>
List-Id: netdev.vger.kernel.org

On Mon, Apr 9, 2012 at 12:26 PM, Will Drewry <wad@chromium.org> wrote:
> On Fri, Apr 6, 2012 at 4:14 PM, Andrew Morton <akpm@linux-foundation.org>=
 wrote:
>> On Thu, 29 Mar 2012 15:01:54 -0500
>> Will Drewry <wad@chromium.org> wrote:
>>
>>> From: Kees Cook <keescook@chromium.org>
>>>
>>> This consolidates the seccomp filter error logging path and adds more
>>> details to the audit log.
>>>
>>> ...
>>>
>>> -void __audit_seccomp(unsigned long syscall)
>>> +void __audit_seccomp(unsigned long syscall, long signr, int code)
>>> =A0{
>>> =A0 =A0 =A0 struct audit_buffer *ab;
>>>
>>> =A0 =A0 =A0 ab =3D audit_log_start(NULL, GFP_KERNEL, AUDIT_ANOM_ABEND);
>>> - =A0 =A0 audit_log_abend(ab, "seccomp", SIGKILL);
>>> + =A0 =A0 audit_log_abend(ab, "seccomp", signr);
>>> =A0 =A0 =A0 audit_log_format(ab, " syscall=3D%ld", syscall);
>>> +#ifdef CONFIG_COMPAT
>>> + =A0 =A0 audit_log_format(ab, " compat=3D%d", is_compat_task());
>>> +#endif
>>
>> We don't need the ifdef for compilation reasons now.
>>
>> The question is: should we emit the compat=3D record on
>> non-compat-capable architectures? =A0Doing so would be safer - making it
>> conditional invites people to write x86-only usersapce.
>
> I'd certainly prefer it always being there for exactly that reason.
>
> Kees, Eric, any preferences? =A0Unless I hear one, I'll just drop the
> ifdefs in the next revision.

Yeah, I'd prefer the ifdefs dropped too.

-Kees

--=20
Kees Cook
ChromeOS Security
