From: Kees Cook <keescook@chromium.org>
Subject: Re: [PATCH v11 07/12] seccomp: add SECCOMP_RET_ERRNO
Date: Mon, 27 Feb 2012 10:09:38 -0800
Message-ID: <CAGXu5jJQhfSSwTU5fSGR_Q57LAQBFW25A_FtR2GFsxyT_ibnzQ@mail.gmail.com>
References: <1330140111-17201-1-git-send-email-wad@chromium.org>
	<1330140111-17201-7-git-send-email-wad@chromium.org>
	<20120227171132.GB10608@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
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
To: Oleg Nesterov <oleg@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:39895 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754280Ab2B0SJj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Feb 2012 13:09:39 -0500
Received: by yhmm54 with SMTP id m54so626611yhm.19
        for <netdev@vger.kernel.org>; Mon, 27 Feb 2012 10:09:39 -0800 (PST)
In-Reply-To: <20120227171132.GB10608@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 27, 2012 at 9:11 AM, Oleg Nesterov <oleg@redhat.com> wrote:
> On 02/24, Will Drewry wrote:
>>
>> =A0static u32 seccomp_run_filters(int syscall)
>> =A0{
>> =A0 =A0 =A0 struct seccomp_filter *f;
>> - =A0 =A0 u32 ret =3D SECCOMP_RET_KILL;
>> =A0 =A0 =A0 static const struct bpf_load_fn fns =3D {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 bpf_load,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 sizeof(struct seccomp_data),
>> =A0 =A0 =A0 };
>> + =A0 =A0 u32 ret =3D SECCOMP_RET_ALLOW;
>> =A0 =A0 =A0 const void *sc_ptr =3D (const void *)(uintptr_t)syscall;
>>
>> + =A0 =A0 /* Ensure unexpected behavior doesn't result in failing op=
en. */
>> + =A0 =A0 if (unlikely(current->seccomp.filter =3D=3D NULL))
>> + =A0 =A0 =A0 =A0 =A0 =A0 ret =3D SECCOMP_RET_KILL;
>
> Is "seccomp.filter =3D=3D NULL" really possible?

It should not be, but I'm much more comfortable with this failing
closed. I think it's important to be as defensive as possible with
this code given its intended use.

-Kees

--=20
Kees Cook
ChromeOS Security
