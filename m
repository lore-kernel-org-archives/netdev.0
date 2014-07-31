From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [RFC][PATCH] wireless: ath9k: Convert from timespecs to ktime_t
Date: Thu, 31 Jul 2014 10:27:50 +1000
Message-ID: <20140731102750.4a4c1315@canb.auug.org.au>
References: <1406764865-26860-1-git-send-email-john.stultz@linaro.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/T8/6ZYX0pF7eB=Ym6s4ZggQ"; protocol="application/pgp-signature"
Cc: linux-kernel@vger.kernel.org, Ingo Molnar <mingo@elte.hu>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Peter Zijlstra <peterz@infradead.org>,
	David Miller <davem@davemloft.net>,
	"John W. Linville" <linville@tuxdriver.com>,
	Felix Fietkau <nbd@openwrt.org>,
	Rajkumar Manoharan <rmanohar@qti.qualcomm.com>,
	<netdev@vger.kernel.org>,
	QCA ath9k Development <ath9k-devel@qca.qualcomm.com>,
	linux-next@vger.kernel.org
To: John Stultz <john.stultz@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1406764865-26860-1-git-send-email-john.stultz@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/T8/6ZYX0pF7eB=Ym6s4ZggQ
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi John,

One obvious thing ...

On Wed, 30 Jul 2014 17:01:05 -0700 John Stultz <john.stultz@linaro.org> wro=
te:
>
> diff --git a/drivers/net/wireless/ath/ath9k/hw.c b/drivers/net/wireless/a=
th/ath9k/hw.c
> index fd0158f..d15f48e 100644
> --- a/drivers/net/wireless/ath/ath9k/hw.c
> +++ b/drivers/net/wireless/ath/ath9k/hw.c
> @@ -1731,19 +1731,14 @@ fail:
>  	return -EINVAL;
>  }
> =20
> -u32 ath9k_hw_get_tsf_offset(struct timespec *last, struct timespec *cur)
> +u32 ath9k_hw_get_tsf_offset(ktime_t *last, ktime_t *cur)
>  {
> -	struct timespec ts;
>  	s64 usec;
> =20
> -	if (!cur) {
> -		getrawmonotonic(&ts);
> -		cur =3D &ts;
> -	}
> -
> -	usec =3D cur->tv_sec * 1000000ULL + cur->tv_nsec / 1000;
> -	usec -=3D last->tv_sec * 1000000ULL + last->tv_nsec / 1000;
> +	if (!cur)
> +		*cur =3D ktime_get_raw();

You are assigning through a NULL pointer here ...

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Sig_/T8/6ZYX0pF7eB=Ym6s4ZggQ
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJT2Y2KAAoJEMDTa8Ir7ZwVGI0P/AxRKaCBh4gUUEO/c9eN9Vjv
32yYcKIF4HLBQ02dCVsqiRJbfhj4v4ON+ptA2rxW7XH8KsP74cdymmX99NBC79nr
pA5J54AE0mhXtIFOl1pavsxcSgDdGSyphfm4rE2WrL+Ipw10omPbc3Hn7xBYe+LD
EsHz/IO6qF8CaigwAMPM7BJ3paztDlaX0G3RkHb1wexqkZApvC1r07xFekku2dtR
NNouzAZzAK3L9WYPzZUNzAvAwHIYZyPjXOkK5rH3KuDAgSJ/TpEzeVNrCpKfaAkJ
l5+R+rEqmUMxbi3k+P4PAM1+miF1/h1qgQd3S8ViDLB2//ld6K9AD4+fgehGlmrL
kuVpNLR5RAoTmU4ZKgQjUjaluKGsRnko15HjjUdw6/CnCRNiYJc5fr75zkPUdApJ
z4vXD5xmlmwoiT7d0s/UYVFYbQL+qld5kwnXRTgSh70jQODUfO8oExr73oabdh7t
YBA/z7XjD61sVp5xNv8Dds3LSVIC5YqvkqbLYfYFf9CKn/WxeMp9cZ1NBna3SRP5
sew0sYsk0rjvnb5mQGnGiWMPiADvOcdCQFt/Xf8K1a9P1359EDcxkZxoLrUsNqAJ
uCVv5dvUXCmWRagMhaAAgFjgJ6BnWRqqapGxHzRK4zFyYrVDj+VUwbSI4pH0tpw0
1vtlP6r0nDWUNnRWgAQI
=hB7F
-----END PGP SIGNATURE-----

--Sig_/T8/6ZYX0pF7eB=Ym6s4ZggQ--
