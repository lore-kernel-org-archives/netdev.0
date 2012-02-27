From: Will Drewry <wad@chromium.org>
Subject: Re: [PATCH v11 07/12] seccomp: add SECCOMP_RET_ERRNO
Date: Mon, 27 Feb 2012 13:54:40 -0600
Message-ID: <CABqD9hZQ7T4zPjKY3403yKDLXpVLBWHeKVxTKvQXnWAzmiksfQ@mail.gmail.com>
References: <1330140111-17201-1-git-send-email-wad@chromium.org>
	<1330140111-17201-7-git-send-email-wad@chromium.org>
	<20120227171132.GB10608@redhat.com>
	<CAGXu5jJQhfSSwTU5fSGR_Q57LAQBFW25A_FtR2GFsxyT_ibnzQ@mail.gmail.com>
	<20120227181434.GA13903@redhat.com>
	<CAObL_7GZVrHpQ0yR9LihQ=UrjAR=BOLRT1F0m4JGGRbEeh=-fQ@mail.gmail.com>
	<CAGXu5jJGiLSRSgQ1nssLSMY1V+9X3y4Uh-kMgQG7moa6PPj3bw@mail.gmail.com>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: Andrew Lutomirski <luto@mit.edu>, Oleg Nesterov <oleg@redhat.com>, linux-kernel@vger.kernel.org,
	linux-arch@vger.kernel.org, linux-doc@vger.kernel.org,
	kernel-hardening@lists.openwall.com, netdev@vger.kernel.org, x86@kernel.org,
	arnd@arndb.de, davem@davemloft.net, hpa@zytor.com, mingo@redhat.com,
	peterz@infradead.org, rdunlap@xenotime.net, mcgrathr@chromium.org,
	tglx@linutronix.de, eparis@redhat.com, serge.hallyn@canonical.com,
	djm@mindrot.org, scarybeasts@gmail.com, indan@nul.nu, pmoore@redhat.com,
	akpm@linux-foundation.org, corbet@lwn.net, eric.dumazet@gmail.com,
	markus@chromium.org, coreyb@linux.vnet.ibm.com
To: Kees Cook <keescook@chromium.org>
Return-path: <kernel-hardening-return-984-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <CAGXu5jJGiLSRSgQ1nssLSMY1V+9X3y4Uh-kMgQG7moa6PPj3bw@mail.gmail.com>
List-Id: netdev.vger.kernel.org

On Mon, Feb 27, 2012 at 1:14 PM, Kees Cook <keescook@chromium.org> wrote:
> On Mon, Feb 27, 2012 at 10:35 AM, Andrew Lutomirski <luto@mit.edu> wrote:
>> On Mon, Feb 27, 2012 at 10:14 AM, Oleg Nesterov <oleg@redhat.com> wrote:
>>> On 02/27, Kees Cook wrote:
>>>>
>>>> On Mon, Feb 27, 2012 at 9:11 AM, Oleg Nesterov <oleg@redhat.com> wrote=
:
>>>> > On 02/24, Will Drewry wrote:
>>>> >>
>>>> >> =A0static u32 seccomp_run_filters(int syscall)
>>>> >> =A0{
>>>> >> =A0 =A0 =A0 struct seccomp_filter *f;
>>>> >> - =A0 =A0 u32 ret =3D SECCOMP_RET_KILL;
>>>> >> =A0 =A0 =A0 static const struct bpf_load_fn fns =3D {
>>>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 bpf_load,
>>>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 sizeof(struct seccomp_data),
>>>> >> =A0 =A0 =A0 };
>>>> >> + =A0 =A0 u32 ret =3D SECCOMP_RET_ALLOW;
>>>> >> =A0 =A0 =A0 const void *sc_ptr =3D (const void *)(uintptr_t)syscall=
;
>>>> >>
>>>> >> + =A0 =A0 /* Ensure unexpected behavior doesn't result in failing o=
pen. */
>>>> >> + =A0 =A0 if (unlikely(current->seccomp.filter =3D=3D NULL))
>>>> >> + =A0 =A0 =A0 =A0 =A0 =A0 ret =3D SECCOMP_RET_KILL;
>>>> >
>>>> > Is "seccomp.filter =3D=3D NULL" really possible?
>>>>
>>>> It should not be, but I'm much more comfortable with this failing
>>>> closed. I think it's important to be as defensive as possible with
>>>> this code given its intended use.
>>>
>>> Can't resists... Sorry, I know I am troll but personally I think
>>> in this case the most defensive code is BUG_ON(->filter =3D=3D NULL)
>>> or at least WARN_ON().
>>
>> Linus will probably object because he objected (correctly) to a very
>> similar problem in my old vsyscall emulation series. =A0A userspace
>> security feature shouldn't have a failure mode in which it confuses
>> the kernel and results in an oops, unless the situation is really
>> unrecoverable. =A0So WARN_ON plus do_exit would be okay but BUG_ON would
>> not.
>
> Yeah, actually, add WARN_ON would be preferred here because it should
> be an impossible situation. It should still fail closed, though:
>
> =A0=A0 =A0 /* Ensure unexpected behavior doesn't result in failing open. =
*/
> =A0=A0 =A0 if (WARN_ON(current->seccomp.filter =3D=3D NULL))
> =A0=A0 =A0 =A0 =A0 =A0 =A0 return SECCOMP_RET_KILL;

I'll do that - thanks!
