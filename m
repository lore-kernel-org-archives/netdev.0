From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 1/1] posix clocks: introduce syscall for clock tuning.
Date: Mon, 23 Aug 2010 10:55:26 +0200
Message-ID: <20100823085526.GB18510@riccoc20.at.omicron.at>
References: <cover.1282550649.git.richard.cochran@omicron.at>
 <e253843e07ce5d15c2c8d11ce786bf979ed85ca5.1282550649.git.richard.cochran@omicron.at>
 <AANLkTi=Fa38ufwR8PDc+HBHmLT53eWRA0ofrobm0n9-w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Bert Wesarg <bert.wesarg@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:51226 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752667Ab0HWIzN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Aug 2010 04:55:13 -0400
Content-Disposition: inline
In-Reply-To: <AANLkTi=Fa38ufwR8PDc+HBHmLT53eWRA0ofrobm0n9-w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 23, 2010 at 10:25:35AM +0200, Bert Wesarg wrote:
> On Mon, Aug 23, 2010 at 10:16, Richard Cochran <richardcochran@gmail.=
com> wrote:
> > diff --git a/kernel/compat.c b/kernel/compat.c
> > index 5adab05..df1e469 100644
> > --- a/kernel/compat.c
> > +++ b/kernel/compat.c
> > @@ -628,6 +628,26 @@ long compat_sys_clock_gettime(clockid_t which_=
clock,
> > =A0 =A0 =A0 =A0return err;
> > =A0}
> >
> > +long compat_sys_clock_adjtime(clockid_t which_clock, int ppb,
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct compat_timespec __user *tp)
> > +{
> > + =A0 =A0 =A0 long err;
> > + =A0 =A0 =A0 mm_segment_t oldfs;
> > + =A0 =A0 =A0 struct timespec ts, *ptr =3D NULL;
>=20
> Shouldn't ptr be initialized with tp?

It could be, but the logic turns out the same either way. The
semantics of the call is, if 'tp' is NULL, then adjust the frequency
by 'ppb', otherwise adjust clock time by 'tp'.

>=20
> > +
> > + =A0 =A0 =A0 if (tp) {
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (get_compat_timespec(&ts, tp))
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EFAULT;
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ptr =3D &ts;
> > + =A0 =A0 =A0 }
> > + =A0 =A0 =A0 oldfs =3D get_fs();
> > + =A0 =A0 =A0 set_fs(KERNEL_DS);
> > + =A0 =A0 =A0 err =3D sys_clock_adjtime(which_clock, ppb,
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (stru=
ct timespec __user *) ptr);
> > + =A0 =A0 =A0 set_fs(oldfs);
> > + =A0 =A0 =A0 return err;
> > +}
> > +
> > =A0long compat_sys_clock_getres(clockid_t which_clock,
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct compat_timespec __user *tp)
> > =A0{
