From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] ethtool: Pause frame reporting fixes
Date: Wed, 01 Jun 2011 21:17:23 +0100
Message-ID: <1306959443.2758.13.camel@bwh-desktop>
References: <42186456B4D1324A9EB53C74DBCBB1BB0657DE@HKI-EXC-1.stonesoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Esa-Pekka =?ISO-8859-1?Q?Py=F6kkimies?=
	<esa-pekka.pyokkimies@stonesoft.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:42090 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752607Ab1FAUR0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2011 16:17:26 -0400
In-Reply-To: <42186456B4D1324A9EB53C74DBCBB1BB0657DE@HKI-EXC-1.stonesoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-05-24 at 10:58 +0000, Esa-Pekka Py=C3=B6kkimies wrote:
> Hello. Our software needs to modify pause parameters dynamically.
> For this to work reliably the SUPPORTED_Pause and SUPPORTED_Asym_Paus=
e
> flags need to be set correctly by the driver. As it turns out, some d=
rivers
> leave them at zero even though they implement pause frames.
> This patch adds reporting for these flags to ethtool.
> For some reason the current code reports ADVERTISED_Pause
> but not SUPPORTED_Pause.

Yes, that seems to be a bug.

Note that some drivers do change pause advertising flags in response to
the ETHTOOL_SPAUSEPARAM command (ethtool -A) if the command enables
autoneg.

> Also there was a small bug
> in the reporting for ADVERTISED_Pause.

No, it matches table 28B-2 in IEEE 802.3 (though with different
terminology).

> Esa-Pekka Pyokkimies, Software Specialist, Stonesoft

Any patches for ethtool need to include a Developer's Certificate of
Origin, as for the kernel - see
<http://www.kernel.org/doc/Documentation/SubmittingPatches>.

Please resubmit with the 'supported' flags decoded in conformance with
IEEE 802.3.

Ben.

>  ethtool.c |   19 ++++++++++++++++---
>  1 files changed, 16 insertions(+), 3 deletions(-)
>=20
> diff --git a/ethtool.c b/ethtool.c
> index 34fe107..cf6c4b2 100644
> --- a/ethtool.c
> +++ b/ethtool.c
> @@ -1193,6 +1193,19 @@ static void dump_supported(struct ethtool_cmd =
*ep)
>  		did1++; fprintf(stdout, "10000baseT/Full ");
>  	}
>  	fprintf(stdout, "\n");
> +       =20
> +	fprintf(stdout, "	Supported pause frame use: ");
> +	if (mask & SUPPORTED_Pause) {
> +		if (mask & SUPPORTED_Asym_Pause)
> +			fprintf(stdout, "Receive-only\n");
> +		else
> +			fprintf(stdout, "Symmetric\n");
> +	} else {
> +		if (mask & SUPPORTED_Asym_Pause)
> +			fprintf(stdout, "Transmit-only\n");
> +		else
> +			fprintf(stdout, "No\n");
> +        }
> =20
>  	fprintf(stdout, "	Supports auto-negotiation: ");
>  	if (mask & SUPPORTED_Autoneg)
> @@ -1255,10 +1268,10 @@ static void dump_advertised(struct ethtool_cm=
d *ep,
> =20
>  	fprintf(stdout, "	%s pause frame use: ", prefix);
>  	if (mask & ADVERTISED_Pause) {
> -		fprintf(stdout, "Symmetric");
>  		if (mask & ADVERTISED_Asym_Pause)
> -			fprintf(stdout, " Receive-only");
> -		fprintf(stdout, "\n");
> +			fprintf(stdout, "Receive-only\n");
> +                else
> +			fprintf(stdout, "Symmetric\n");
>  	} else {
>  		if (mask & ADVERTISED_Asym_Pause)
>  			fprintf(stdout, "Transmit-only\n");

--=20
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

