From: Josh Cartwright <joshc@ni.com>
Subject: Re: [PATCH v2 1/1] Added additional callback to ptp_clock_info:
Date: Mon, 6 Jul 2015 15:44:58 -0500
Message-ID: <20150706204458.GE25028@jcartwri.amer.corp.natinst.com>
References: <1435886088-13890-1-git-send-email-christopher.s.hall@intel.com>
 <1435886088-13890-2-git-send-email-christopher.s.hall@intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="ZARJHfwaSJQLOEUz"
Cc: richardcochran@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, john.ronciak@intel.com,
	john.stultz@linaro.org, tglx@linutronix.de
To: Christopher Hall <christopher.s.hall@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from skprod2.natinst.com ([130.164.80.23]:54875 "EHLO ni.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754486AbbGFUpM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Jul 2015 16:45:12 -0400
In-Reply-To: <1435886088-13890-2-git-send-email-christopher.s.hall@intel.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--ZARJHfwaSJQLOEUz
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Jul 02, 2015 at 06:14:48PM -0700, Christopher Hall wrote:
> * getsynctime64()

Hello Christopher-

A couple comments below.

>=20
> This takes 2 arguments referring to system and device time
>=20
> With this callback drivers may provide both system time and device time
> to ensure precise correlation
>=20
> Modified PTP_SYS_OFFSET ioctl in PTP clock driver to use the above
> callback if it's available
>=20
> Added capability (PTP_CLOCK_GETCAPS) for checking whether driver supports
> precise timestamping
>=20
> Signed-off-by: Christopher Hall <christopher.s.hall@intel.com>
> ---
[..]
> @@ -196,19 +197,31 @@ long ptp_ioctl(struct posix_clock *pc, unsigned int=
 cmd, unsigned long arg)
>  			break;
>  		}
>  		pct =3D &sysoff->ts[0];
> -		for (i =3D 0; i < sysoff->n_samples; i++) {
> -			getnstimeofday64(&ts);
> +		if (ptp->info->getsynctime64 && sysoff->n_samples =3D=3D 1) {
> +			ptp->info->getsynctime64(ptp->info, &ts, &systs);
> +			pct->sec =3D systs.tv_sec;
> +			pct->nsec =3D systs.tv_nsec;

It's difficult to make too many judgements without seeing how a driver
might implement this; is there another patchset that shows how a driver
implements this?

[..]
> diff --git a/include/uapi/linux/ptp_clock.h b/include/uapi/linux/ptp_cloc=
k.h
> index f0b7bfe..421b637 100644
> --- a/include/uapi/linux/ptp_clock.h
> +++ b/include/uapi/linux/ptp_clock.h
> @@ -51,7 +51,9 @@ struct ptp_clock_caps {
>  	int n_per_out; /* Number of programmable periodic signals. */
>  	int pps;       /* Whether the clock supports a PPS callback. */
>  	int n_pins;    /* Number of input/output pins. */
> -	int rsv[14];   /* Reserved for future use. */
> +	/* Whether the clock supports precise system-device cross timestamps */
> +	int precise_timestamping;

Perhaps now is a good time to add an unsigned int 'flags' member instead,
and start allocating bits.

  Josh

--ZARJHfwaSJQLOEUz
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJVmujGAAoJEKp7ZBKwQFAr7PMH/0Wob50tjihB7pTk0Y2pU60N
Kbs+U6z6Xk4biq9IJTD6Mf3aaPSMRcIfXlJtP0/gJuPs3wwkSFjMyXDd9+5raGHE
kGekJDAiHWOWIxO9z7060SCqI0QdcG18tEsfxXFcB7sa1+RNfgyOTFwt2Q3tZnRK
EWeO95AmyOx8guyBLHknheC1fKFGPep0rTXKSJ9zwu2VFeTKhyr0RkdPwlnyvHKN
XJ8fBYZm9QowxSy3prj4JBhh4lpV16WWGBa+80VF5FMp6sdJp/eaz1TprZr+opLU
rZrbdyO67PBokAGm/z4Sra1gwL67EuxNTYruZj8kuH1e+Jzy0CCxrt/snYkkNKA=
=ocwM
-----END PGP SIGNATURE-----

--ZARJHfwaSJQLOEUz--
