From: Bert Wesarg <bert.wesarg@googlemail.com>
Subject: Re: [PATCH 1/1] posix clocks: introduce syscall for clock tuning.
Date: Mon, 23 Aug 2010 10:25:35 +0200
Message-ID: <AANLkTi=Fa38ufwR8PDc+HBHmLT53eWRA0ofrobm0n9-w@mail.gmail.com>
References: <cover.1282550649.git.richard.cochran@omicron.at>
	<e253843e07ce5d15c2c8d11ce786bf979ed85ca5.1282550649.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <e253843e07ce5d15c2c8d11ce786bf979ed85ca5.1282550649.git.richard.cochran@omicron.at>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 23, 2010 at 10:16, Richard Cochran <richardcochran@gmail.co=
m> wrote:
> diff --git a/kernel/compat.c b/kernel/compat.c
> index 5adab05..df1e469 100644
> --- a/kernel/compat.c
> +++ b/kernel/compat.c
> @@ -628,6 +628,26 @@ long compat_sys_clock_gettime(clockid_t which_cl=
ock,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return err;
> =C2=A0}
>
> +long compat_sys_clock_adjtime(clockid_t which_clock, int ppb,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct compat_time=
spec __user *tp)
> +{
> + =C2=A0 =C2=A0 =C2=A0 long err;
> + =C2=A0 =C2=A0 =C2=A0 mm_segment_t oldfs;
> + =C2=A0 =C2=A0 =C2=A0 struct timespec ts, *ptr =3D NULL;

Shouldn't ptr be initialized with tp?

> +
> + =C2=A0 =C2=A0 =C2=A0 if (tp) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (get_compat_tim=
espec(&ts, tp))
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 return -EFAULT;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ptr =3D &ts;
> + =C2=A0 =C2=A0 =C2=A0 }
> + =C2=A0 =C2=A0 =C2=A0 oldfs =3D get_fs();
> + =C2=A0 =C2=A0 =C2=A0 set_fs(KERNEL_DS);
> + =C2=A0 =C2=A0 =C2=A0 err =3D sys_clock_adjtime(which_clock, ppb,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 (struct timespec __user *) ptr);
> + =C2=A0 =C2=A0 =C2=A0 set_fs(oldfs);
> + =C2=A0 =C2=A0 =C2=A0 return err;
> +}
> +
> =C2=A0long compat_sys_clock_getres(clockid_t which_clock,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0struct compat_=
timespec __user *tp)
> =C2=A0{
