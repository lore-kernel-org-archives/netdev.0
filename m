From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: 2.6.24-rc4-mm1
Date: Tue, 11 Dec 2007 12:37:05 -0800
Message-ID: <20071211123705.844aac24.akpm@linux-foundation.org>
References: <20071204211701.994dfce6.akpm@linux-foundation.org>
	<33307c790712110813h23def95dvd068b7226e9fcd36@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, "Andy Whitcroft" <apw@shadowen.org>,
	netdev@vger.kernel.org, Auke Kok <auke-jan.h.kok@intel.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@elte.hu>
To: "Martin Bligh" <mbligh@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:48803 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753148AbXLKUiQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2007 15:38:16 -0500
In-Reply-To: <33307c790712110813h23def95dvd068b7226e9fcd36@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 11 Dec 2007 08:13:52 -0800 "Martin Bligh" <mbligh@google.com> w=
rote:

> >
> >
> > - Lots of device IDs have been removed from the e1000 driver and mo=
ved
> > over
> >  to e1000e.  So if your e1000 stops working, you forgot to set
> > CONFIG_E1000E.
> >
> >
> Wouldn't it make sense to just default this to on if E1000 was on, ra=
ther
> than screwing
> everybody for no good reason (plus breaking all the automated testing=
, etc
> etc)?
> Much though I love random refactoring, it is fairly painful to just k=
eep
> changing the
> names of things.

(cc netdev and Auke)

Yes, that would be very sensible.  CONFIG_E1000E should default to what=
ever
CONFIG_E1000 was set to.

>=20
> I can't see this compile failure posted anywhere:
> http://test.kernel.org/results/IBM/126049/build/debug/stderr
>=20
> arch/x86/vdso/vdso32/sigreturn.S: Assembler messages:
> arch/x86/vdso/vdso32/sigreturn.S:23: Error: suffix or operands invali=
d for `pop'
> arch/x86/vdso/vdso32/syscall.S:25: Error: suffix or operands invalid =
for `pop'
> make[1]: *** [arch/x86/vdso/vdso32/syscall.o] Error 1
> make: *** [arch/x86/vdso] Error 2

(cc Ingo and Thomas)

>=20
> Nor this one:
> http://test.kernel.org/results/IBM/126096/build/debug/stderr
>=20
> drivers/char/hvcs.c: In function =C3=A2=E2=82=AC=CB=9Chvcs_open=C3=A2=
=E2=82=AC=E2=84=A2:
> drivers/char/hvcs.c:1180: error: wrong type argument to unary exclama=
tion mark
>=20

(cc Greg)

Caused by gregkh-driver-kobject-convert-hvcs-to-use-kref-not-kobject.pa=
tch.
