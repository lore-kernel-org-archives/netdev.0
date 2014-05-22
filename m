From: =?utf-8?B?566h6Zuq5rab?= <gxt@pku.edu.cn>
Subject: =?utf-8?Q?=E5=9B=9E=E5=A4=8D=EF=BC=9A_Re:_[PATCH_linux-nex?=
 =?utf-8?Q?t]_net/dccp/timer.c:_use_?=
 =?utf-8?Q?'u64'_instead_of_'s64'_to_avoid_compiler's_warning?=
Date: Fri, 23 May 2014 07:58:11 +0800 (CST)
Message-ID: <263613432.57393.1400803091663.JavaMail.root@bj-mail03.pku.edu.cn>
References: <20140522.153313.958087444510569794.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: gang chen 5i5j <gang.chen.5i5j@gmail.com>, gerrit@erg.abdn.ac.uk,
	gxt@mprc.pku.edu.cn, dccp@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140522.153313.958087444510569794.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


----- David Miller <davem@davemloft.net> =E5=86=99=E9=81=93=EF=BC=9A
> From: Chen Gang <gang.chen.5i5j@gmail.com>
> Date: Wed, 21 May 2014 08:19:34 +0800
>=20
> > 'dccp_timestamp_seed' is initialized once by ktime_get_real() in
> > dccp_timestamping_init(). It is always less than ktime_get_real()
> > in dccp_timestamp().
> >=20
> > Then, ktime_us_delta() in dccp_timestamp() will always return posit=
ive
> > number. So can use manual type cast to let compiler and do_div() kn=
ow
> > about it to avoid warning.
> >=20
> > The related warning (with allmodconfig under unicore32):
> >=20
> >     CC [M]  net/dccp/timer.o
> >   net/dccp/timer.c: In function =E2=80=98dccp_timestamp=E2=80=99:
> >   net/dccp/timer.c:285: warning: comparison of distinct pointer typ=
es lacks a cast
> >=20
> >=20
> > Signed-off-by: Chen Gang <gang.chen.5i5j@gmail.com>
>=20
> Applied to net-next, thanks.
>=20
> But that type check in include/asm-generic/div64.h is bogus, it shoul=
d
> be checking sizeof(X) =3D=3D 8 rather than the type thing, it just wa=
nts to
> make sure that the value is 64-bit regardless of it's signedness.
>=20
> The arch local implementations do not do this, and that's why very fe=
w
> other people notice this warning.

Arch-dependent codes implement it with unsigned long long type.
And, every warning should not be ignored.
