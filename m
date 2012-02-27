From: Andrew Lutomirski <luto@mit.edu>
Subject: Re: [PATCH v11 07/12] seccomp: add SECCOMP_RET_ERRNO
Date: Mon, 27 Feb 2012 10:35:55 -0800
Message-ID: <CAObL_7GZVrHpQ0yR9LihQ=UrjAR=BOLRT1F0m4JGGRbEeh=-fQ@mail.gmail.com>
References: <1330140111-17201-1-git-send-email-wad@chromium.org>
 <1330140111-17201-7-git-send-email-wad@chromium.org> <20120227171132.GB10608@redhat.com>
 <CAGXu5jJQhfSSwTU5fSGR_Q57LAQBFW25A_FtR2GFsxyT_ibnzQ@mail.gmail.com> <20120227181434.GA13903@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Kees Cook <keescook@chromium.org>, Will Drewry <wad@chromium.org>,
	linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
	linux-doc@vger.kernel.org, kernel-hardening@lists.openwall.com,
	netdev@vger.kernel.org, x86@kernel.org, arnd@arndb.de,
	davem@davemloft.net, hpa@zytor.com, mingo@redhat.com,
	peterz@infradead.org, rdunlap@xenotime.net, mcgrathr@chromium.org,
	tglx@linutronix.de, eparis@redhat.com, serge.hallyn@canonical.com,
	djm@mindrot.org, scarybeasts@gmail.com, indan@nul.nu,
	pmoore@redhat.com, akpm@linux-foundation.org, corbet@lwn.net,
	eric.dumazet@gmail.com, markus@chromium.org,
	coreyb@linux.vnet.ibm.com
To: Oleg Nesterov <oleg@redhat.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <20120227181434.GA13903@redhat.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 27, 2012 at 10:14 AM, Oleg Nesterov <oleg@redhat.com> wrote=
:
> On 02/27, Kees Cook wrote:
>>
>> On Mon, Feb 27, 2012 at 9:11 AM, Oleg Nesterov <oleg@redhat.com> wro=
te:
>> > On 02/24, Will Drewry wrote:
>> >>
>> >> =A0static u32 seccomp_run_filters(int syscall)
>> >> =A0{
>> >> =A0 =A0 =A0 struct seccomp_filter *f;
>> >> - =A0 =A0 u32 ret =3D SECCOMP_RET_KILL;
>> >> =A0 =A0 =A0 static const struct bpf_load_fn fns =3D {
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 bpf_load,
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 sizeof(struct seccomp_data),
>> >> =A0 =A0 =A0 };
>> >> + =A0 =A0 u32 ret =3D SECCOMP_RET_ALLOW;
>> >> =A0 =A0 =A0 const void *sc_ptr =3D (const void *)(uintptr_t)sysca=
ll;
>> >>
>> >> + =A0 =A0 /* Ensure unexpected behavior doesn't result in failing=
 open. */
>> >> + =A0 =A0 if (unlikely(current->seccomp.filter =3D=3D NULL))
>> >> + =A0 =A0 =A0 =A0 =A0 =A0 ret =3D SECCOMP_RET_KILL;
>> >
>> > Is "seccomp.filter =3D=3D NULL" really possible?
>>
>> It should not be, but I'm much more comfortable with this failing
>> closed. I think it's important to be as defensive as possible with
>> this code given its intended use.
>
> Can't resists... Sorry, I know I am troll but personally I think
> in this case the most defensive code is BUG_ON(->filter =3D=3D NULL)
> or at least WARN_ON().

Linus will probably object because he objected (correctly) to a very
similar problem in my old vsyscall emulation series.  A userspace
security feature shouldn't have a failure mode in which it confuses
the kernel and results in an oops, unless the situation is really
unrecoverable.  So WARN_ON plus do_exit would be okay but BUG_ON would
not.

--Andy
