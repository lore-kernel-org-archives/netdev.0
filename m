From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH 2/5] ethtool: move cmdline_coalesce out of do_scoalesce
Date: Sun, 26 Jun 2016 17:05:32 +0200
Message-ID: <1466953532.2551.5.camel@decadent.org.uk>
References: <1463296476-32493-1-git-send-email-kan.liang@intel.com>
	 <1463296476-32493-2-git-send-email-kan.liang@intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-CxFR+l8mMel6bhKHhss1"
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	nicolas.dichtel@6wind.com, jesse.brandeburg@intel.com,
	andi@firstfloor.org
To: kan.liang@intel.com, bwh@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:57564 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752054AbcFZPFo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Jun 2016 11:05:44 -0400
In-Reply-To: <1463296476-32493-2-git-send-email-kan.liang@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-CxFR+l8mMel6bhKHhss1
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2016-05-15 at 00:14 -0700, kan.liang@intel.com wrote:
> From: Kan Liang <kan.liang@intel.com>
>=20
> Moving cmdline_coalesce out of do_scoalesce, so it can be shared with
> other functions.
> No behavior change.

I spent some time getting rid of static variables, and I think the only
ones left are (at least logically) constant. =C2=A0I won't accept a change
that reverses this. =C2=A0There's really no need to pass information around
this way.

Ben.

> Signed-off-by: Kan Liang <kan.liang@intel.com>
> ---
> =C2=A0ethtool.c | 147 +++++++++++++++++++++++++++++++--------------------=
-----------
> =C2=A01 file changed, 74 insertions(+), 73 deletions(-)
>=20
> diff --git a/ethtool.c b/ethtool.c
> index bd0583c..86724a2 100644
> --- a/ethtool.c
> +++ b/ethtool.c
> @@ -1883,85 +1883,86 @@ static int do_gcoalesce(struct cmd_context *ctx)
> =C2=A0	return 0;
> =C2=A0}
> =C2=A0
> +static struct ethtool_coalesce s_ecoal;
> +static s32 coal_stats_wanted =3D -1;
> +static int coal_adaptive_rx_wanted =3D -1;
> +static int coal_adaptive_tx_wanted =3D -1;
> +static s32 coal_sample_rate_wanted =3D -1;
> +static s32 coal_pkt_rate_low_wanted =3D -1;
> +static s32 coal_pkt_rate_high_wanted =3D -1;
> +static s32 coal_rx_usec_wanted =3D -1;
> +static s32 coal_rx_frames_wanted =3D -1;
> +static s32 coal_rx_usec_irq_wanted =3D -1;
> +static s32 coal_rx_frames_irq_wanted =3D -1;
> +static s32 coal_tx_usec_wanted =3D -1;
> +static s32 coal_tx_frames_wanted =3D -1;
> +static s32 coal_tx_usec_irq_wanted =3D -1;
> +static s32 coal_tx_frames_irq_wanted =3D -1;
> +static s32 coal_rx_usec_low_wanted =3D -1;
> +static s32 coal_rx_frames_low_wanted =3D -1;
> +static s32 coal_tx_usec_low_wanted =3D -1;
> +static s32 coal_tx_frames_low_wanted =3D -1;
> +static s32 coal_rx_usec_high_wanted =3D -1;
> +static s32 coal_rx_frames_high_wanted =3D -1;
> +static s32 coal_tx_usec_high_wanted =3D -1;
> +static s32 coal_tx_frames_high_wanted =3D -1;
> +
> +static struct cmdline_info cmdline_coalesce[] =3D {
> +	{ "adaptive-rx", CMDL_BOOL, &coal_adaptive_rx_wanted,
> +	=C2=A0=C2=A0&s_ecoal.use_adaptive_rx_coalesce },
> +	{ "adaptive-tx", CMDL_BOOL, &coal_adaptive_tx_wanted,
> +	=C2=A0=C2=A0&s_ecoal.use_adaptive_tx_coalesce },
> +	{ "sample-interval", CMDL_S32, &coal_sample_rate_wanted,
> +	=C2=A0=C2=A0&s_ecoal.rate_sample_interval },
> +	{ "stats-block-usecs", CMDL_S32, &coal_stats_wanted,
> +	=C2=A0=C2=A0&s_ecoal.stats_block_coalesce_usecs },
> +	{ "pkt-rate-low", CMDL_S32, &coal_pkt_rate_low_wanted,
> +	=C2=A0=C2=A0&s_ecoal.pkt_rate_low },
> +	{ "pkt-rate-high", CMDL_S32, &coal_pkt_rate_high_wanted,
> +	=C2=A0=C2=A0&s_ecoal.pkt_rate_high },
> +	{ "rx-usecs", CMDL_S32, &coal_rx_usec_wanted,
> +	=C2=A0=C2=A0&s_ecoal.rx_coalesce_usecs },
> +	{ "rx-frames", CMDL_S32, &coal_rx_frames_wanted,
> +	=C2=A0=C2=A0&s_ecoal.rx_max_coalesced_frames },
> +	{ "rx-usecs-irq", CMDL_S32, &coal_rx_usec_irq_wanted,
> +	=C2=A0=C2=A0&s_ecoal.rx_coalesce_usecs_irq },
> +	{ "rx-frames-irq", CMDL_S32, &coal_rx_frames_irq_wanted,
> +	=C2=A0=C2=A0&s_ecoal.rx_max_coalesced_frames_irq },
> +	{ "tx-usecs", CMDL_S32, &coal_tx_usec_wanted,
> +	=C2=A0=C2=A0&s_ecoal.tx_coalesce_usecs },
> +	{ "tx-frames", CMDL_S32, &coal_tx_frames_wanted,
> +	=C2=A0=C2=A0&s_ecoal.tx_max_coalesced_frames },
> +	{ "tx-usecs-irq", CMDL_S32, &coal_tx_usec_irq_wanted,
> +	=C2=A0=C2=A0&s_ecoal.tx_coalesce_usecs_irq },
> +	{ "tx-frames-irq", CMDL_S32, &coal_tx_frames_irq_wanted,
> +	=C2=A0=C2=A0&s_ecoal.tx_max_coalesced_frames_irq },
> +	{ "rx-usecs-low", CMDL_S32, &coal_rx_usec_low_wanted,
> +	=C2=A0=C2=A0&s_ecoal.rx_coalesce_usecs_low },
> +	{ "rx-frames-low", CMDL_S32, &coal_rx_frames_low_wanted,
> +	=C2=A0=C2=A0&s_ecoal.rx_max_coalesced_frames_low },
> +	{ "tx-usecs-low", CMDL_S32, &coal_tx_usec_low_wanted,
> +	=C2=A0=C2=A0&s_ecoal.tx_coalesce_usecs_low },
> +	{ "tx-frames-low", CMDL_S32, &coal_tx_frames_low_wanted,
> +	=C2=A0=C2=A0&s_ecoal.tx_max_coalesced_frames_low },
> +	{ "rx-usecs-high", CMDL_S32, &coal_rx_usec_high_wanted,
> +	=C2=A0=C2=A0&s_ecoal.rx_coalesce_usecs_high },
> +	{ "rx-frames-high", CMDL_S32, &coal_rx_frames_high_wanted,
> +	=C2=A0=C2=A0&s_ecoal.rx_max_coalesced_frames_high },
> +	{ "tx-usecs-high", CMDL_S32, &coal_tx_usec_high_wanted,
> +	=C2=A0=C2=A0&s_ecoal.tx_coalesce_usecs_high },
> +	{ "tx-frames-high", CMDL_S32, &coal_tx_frames_high_wanted,
> +	=C2=A0=C2=A0&s_ecoal.tx_max_coalesced_frames_high },
> +};
> =C2=A0static int do_scoalesce(struct cmd_context *ctx)
> =C2=A0{
> -	struct ethtool_coalesce ecoal;
> =C2=A0	int gcoalesce_changed =3D 0;
> -	s32 coal_stats_wanted =3D -1;
> -	int coal_adaptive_rx_wanted =3D -1;
> -	int coal_adaptive_tx_wanted =3D -1;
> -	s32 coal_sample_rate_wanted =3D -1;
> -	s32 coal_pkt_rate_low_wanted =3D -1;
> -	s32 coal_pkt_rate_high_wanted =3D -1;
> -	s32 coal_rx_usec_wanted =3D -1;
> -	s32 coal_rx_frames_wanted =3D -1;
> -	s32 coal_rx_usec_irq_wanted =3D -1;
> -	s32 coal_rx_frames_irq_wanted =3D -1;
> -	s32 coal_tx_usec_wanted =3D -1;
> -	s32 coal_tx_frames_wanted =3D -1;
> -	s32 coal_tx_usec_irq_wanted =3D -1;
> -	s32 coal_tx_frames_irq_wanted =3D -1;
> -	s32 coal_rx_usec_low_wanted =3D -1;
> -	s32 coal_rx_frames_low_wanted =3D -1;
> -	s32 coal_tx_usec_low_wanted =3D -1;
> -	s32 coal_tx_frames_low_wanted =3D -1;
> -	s32 coal_rx_usec_high_wanted =3D -1;
> -	s32 coal_rx_frames_high_wanted =3D -1;
> -	s32 coal_tx_usec_high_wanted =3D -1;
> -	s32 coal_tx_frames_high_wanted =3D -1;
> -	struct cmdline_info cmdline_coalesce[] =3D {
> -		{ "adaptive-rx", CMDL_BOOL, &coal_adaptive_rx_wanted,
> -		=C2=A0=C2=A0&ecoal.use_adaptive_rx_coalesce },
> -		{ "adaptive-tx", CMDL_BOOL, &coal_adaptive_tx_wanted,
> -		=C2=A0=C2=A0&ecoal.use_adaptive_tx_coalesce },
> -		{ "sample-interval", CMDL_S32, &coal_sample_rate_wanted,
> -		=C2=A0=C2=A0&ecoal.rate_sample_interval },
> -		{ "stats-block-usecs", CMDL_S32, &coal_stats_wanted,
> -		=C2=A0=C2=A0&ecoal.stats_block_coalesce_usecs },
> -		{ "pkt-rate-low", CMDL_S32, &coal_pkt_rate_low_wanted,
> -		=C2=A0=C2=A0&ecoal.pkt_rate_low },
> -		{ "pkt-rate-high", CMDL_S32, &coal_pkt_rate_high_wanted,
> -		=C2=A0=C2=A0&ecoal.pkt_rate_high },
> -		{ "rx-usecs", CMDL_S32, &coal_rx_usec_wanted,
> -		=C2=A0=C2=A0&ecoal.rx_coalesce_usecs },
> -		{ "rx-frames", CMDL_S32, &coal_rx_frames_wanted,
> -		=C2=A0=C2=A0&ecoal.rx_max_coalesced_frames },
> -		{ "rx-usecs-irq", CMDL_S32, &coal_rx_usec_irq_wanted,
> -		=C2=A0=C2=A0&ecoal.rx_coalesce_usecs_irq },
> -		{ "rx-frames-irq", CMDL_S32, &coal_rx_frames_irq_wanted,
> -		=C2=A0=C2=A0&ecoal.rx_max_coalesced_frames_irq },
> -		{ "tx-usecs", CMDL_S32, &coal_tx_usec_wanted,
> -		=C2=A0=C2=A0&ecoal.tx_coalesce_usecs },
> -		{ "tx-frames", CMDL_S32, &coal_tx_frames_wanted,
> -		=C2=A0=C2=A0&ecoal.tx_max_coalesced_frames },
> -		{ "tx-usecs-irq", CMDL_S32, &coal_tx_usec_irq_wanted,
> -		=C2=A0=C2=A0&ecoal.tx_coalesce_usecs_irq },
> -		{ "tx-frames-irq", CMDL_S32, &coal_tx_frames_irq_wanted,
> -		=C2=A0=C2=A0&ecoal.tx_max_coalesced_frames_irq },
> -		{ "rx-usecs-low", CMDL_S32, &coal_rx_usec_low_wanted,
> -		=C2=A0=C2=A0&ecoal.rx_coalesce_usecs_low },
> -		{ "rx-frames-low", CMDL_S32, &coal_rx_frames_low_wanted,
> -		=C2=A0=C2=A0&ecoal.rx_max_coalesced_frames_low },
> -		{ "tx-usecs-low", CMDL_S32, &coal_tx_usec_low_wanted,
> -		=C2=A0=C2=A0&ecoal.tx_coalesce_usecs_low },
> -		{ "tx-frames-low", CMDL_S32, &coal_tx_frames_low_wanted,
> -		=C2=A0=C2=A0&ecoal.tx_max_coalesced_frames_low },
> -		{ "rx-usecs-high", CMDL_S32, &coal_rx_usec_high_wanted,
> -		=C2=A0=C2=A0&ecoal.rx_coalesce_usecs_high },
> -		{ "rx-frames-high", CMDL_S32, &coal_rx_frames_high_wanted,
> -		=C2=A0=C2=A0&ecoal.rx_max_coalesced_frames_high },
> -		{ "tx-usecs-high", CMDL_S32, &coal_tx_usec_high_wanted,
> -		=C2=A0=C2=A0&ecoal.tx_coalesce_usecs_high },
> -		{ "tx-frames-high", CMDL_S32, &coal_tx_frames_high_wanted,
> -		=C2=A0=C2=A0&ecoal.tx_max_coalesced_frames_high },
> -	};
> =C2=A0	int err, changed =3D 0;
> =C2=A0
> =C2=A0	parse_generic_cmdline(ctx, &gcoalesce_changed,
> =C2=A0			=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0cmdline_coalesce, ARRAY_SIZE=
(cmdline_coalesce));
> =C2=A0
> -	ecoal.cmd =3D ETHTOOL_GCOALESCE;
> -	err =3D send_ioctl(ctx, &ecoal);
> +	s_ecoal.cmd =3D ETHTOOL_GCOALESCE;
> +	err =3D send_ioctl(ctx, &s_ecoal);
> =C2=A0	if (err) {
> =C2=A0		perror("Cannot get device coalesce settings");
> =C2=A0		return 76;
> @@ -1975,8 +1976,8 @@ static int do_scoalesce(struct cmd_context *ctx)
> =C2=A0		return 80;
> =C2=A0	}
> =C2=A0
> -	ecoal.cmd =3D ETHTOOL_SCOALESCE;
> -	err =3D send_ioctl(ctx, &ecoal);
> +	s_ecoal.cmd =3D ETHTOOL_SCOALESCE;
> +	err =3D send_ioctl(ctx, &s_ecoal);
> =C2=A0	if (err) {
> =C2=A0		perror("Cannot set device coalesce parameters");
> =C2=A0		return 81;
--=20

Ben Hutchings
compatible: Gracefully accepts erroneous data from any source

--=-CxFR+l8mMel6bhKHhss1
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJXb+88AAoJEOe/yOyVhhEJaG4P/R9lVesxd2FnE6Kg6EWU+HjN
T2KH1Tq/g7PPm1mCgT+b7bjCLMAtlAiJPCeDfd4VOpOtFD4YRGu8Qsa5ABX3mZ9J
n7zLKHYHgDiIz1JsrchhvksCN10FEhpALuclPK9wpg9Dm5GhhTMHCjkin4wcwCOb
X5y29xTokLDng4FuqUbLFxxFNEuB10wq543rlhWlg9GjMlNKFhCv7BXuDk0o2zJn
KXzHdy1xrBsBZ1QCnr1qk50PT6UR8GnuKRWrj+dXwMfJS87EiJ7YbCjQ4tsBVo4d
NSd2VUSDGUX8kNAweG8MJY8HTxWsbbVOZYlWWl1gnnxrpJvIabQdPMnDDgHiGjbd
kDm4uY38wgHjBlAKt31G4DQZhRT0SiGZVcfkXaXsikmqRMtiQdHHE/EZCQKZSjct
jG/oZ+GRXqnNgovbu3zam507Puvi1rzkpDdal6yoZ/8HRVNKxTjv9nHmTvwqgXyo
58lGBgOM5GcgZgoC4LaKRcDQzubbqAWyCElmIOK3CRm4ZiHACmrD616KHJ2IugUy
rhtAnQdCOUp3be+gt3lfJVarf0GBqzvgUDLkeSi4xm2+iRDNRhIOnhS3/tv1kQL0
IRl6gyl55Kyez+iU6U1iL0NHF3jGdX9TlqPHopHVT2/XOZ2WtFv4/62sGlMlZp5U
lWwrhI6OKzrZ437bSPjg
=UZ4B
-----END PGP SIGNATURE-----

--=-CxFR+l8mMel6bhKHhss1--
