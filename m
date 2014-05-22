From: =?utf-8?B?566h6Zuq5rab?= <gxt@pku.edu.cn>
Subject: =?utf-8?Q?=E5=9B=9E=E5=A4=8D=EF=BC=9A_[PATCH_linux-next]_?=
 =?utf-8?Q?net/dccp/timer.c:_use_'u?=
 =?utf-8?Q?64'_instead_of_'s64'_to_avoid_compiler's_warning?=
Date: Thu, 22 May 2014 08:26:39 +0800 (CST)
Message-ID: <1546102096.46113.1400718399706.JavaMail.root@bj-mail03.pku.edu.cn>
References: <537BF116.9000900@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: gerrit@erg.abdn.ac.uk, Guan Xuetao <gxt@mprc.pku.edu.cn>,
	David Miller <davem@davemloft.net>, dccp@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Chen Gang <gang.chen.5i5j@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <537BF116.9000900@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


----- Chen Gang <gang.chen.5i5j@gmail.com> =E5=86=99=E9=81=93=EF=BC=9A
> 'dccp_timestamp_seed' is initialized once by ktime_get_real() in
> dccp_timestamping_init(). It is always less than ktime_get_real()
> in dccp_timestamp().
>=20
> Then, ktime_us_delta() in dccp_timestamp() will always return positiv=
e
> number. So can use manual type cast to let compiler and do_div() know
> about it to avoid warning.
>=20
> The related warning (with allmodconfig under unicore32):
>=20
>     CC [M]  net/dccp/timer.o
>   net/dccp/timer.c: In function =E2=80=98dccp_timestamp=E2=80=99:
>   net/dccp/timer.c:285: warning: comparison of distinct pointer types=
 lacks a cast
>=20
>=20
> Signed-off-by: Chen Gang <gang.chen.5i5j@gmail.com>
> ---
>  net/dccp/timer.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>=20
> diff --git a/net/dccp/timer.c b/net/dccp/timer.c
> index 16f0b22..1cd46a3 100644
> --- a/net/dccp/timer.c
> +++ b/net/dccp/timer.c
> @@ -280,7 +280,7 @@ static ktime_t dccp_timestamp_seed;
>   */
>  u32 dccp_timestamp(void)
>  {
> -	s64 delta =3D ktime_us_delta(ktime_get_real(), dccp_timestamp_seed)=
;
> +	u64 delta =3D (u64)ktime_us_delta(ktime_get_real(), dccp_timestamp_=
seed);

Do you assume that delta should be very small?
Otherwise, return value will be different if data type is changed.

> =20
>  	do_div(delta, 10);
>  	return delta;
> --=20
> 1.9.2.459.g68773ac
