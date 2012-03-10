From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] iproute: fix tc -iec display of Mibit rates
Date: Sat, 10 Mar 2012 09:14:25 -0800
Message-ID: <20120310091425.40004881@nehalam.linuxnetplumber.net>
References: <20120309160919.GA22767@amd64.fatal.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Thomas =?ISO-8859-1?B?TfxobGdyYWJuZXI=?= <muehltom@cable.vol.at>
To: Andreas Henriksson <andreas@fatal.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:52321 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750900Ab2CJRO2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Mar 2012 12:14:28 -0500
In-Reply-To: <20120309160919.GA22767@amd64.fatal.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 9 Mar 2012 17:09:19 +0100
Andreas Henriksson <andreas@fatal.se> wrote:

> As reported by Thomas M=FChlgrabner <muehltom@cable.vol.at>
> in http://bugs.debian.org/662979 :
>=20
>  When showing htb class configuration with "tc -iec class show",
>  the output for Mibit is actually the value for bit.
>  Example: configure a class with a ceil of 1000Mibit.
>  Output states 1048576000 Mibit.
>=20
> The cause is missing parenteses in the display code of tc....
>=20
> (Please also note that a lower value of 100Mibit will be displayed
> as 102400 Kibit, which I think is kind of ugly.)
>=20
> Reported-by: Thomas M=FChlgrabner <muehltom@cable.vol.at>
> Signed-off-by: Andreas Henriksson <andreas@fatal.se>
>=20
> diff --git a/tc/tc_util.c b/tc/tc_util.c
> index 5829d61..36e3c7d 100644
> --- a/tc/tc_util.c
> +++ b/tc/tc_util.c
> @@ -203,7 +203,7 @@ void print_rate(char *buf, int len, __u32 rate)
> =20
>  	if (use_iec) {
>  		if (tmp >=3D 1000.0*1024.0*1024.0)
> -			snprintf(buf, len, "%.0fMibit", tmp/1024.0*1024.0);
> +			snprintf(buf, len, "%.0fMibit", tmp/(1024.0*1024.0));
>  		else if (tmp >=3D 1000.0*1024)
>  			snprintf(buf, len, "%.0fKibit", tmp/1024);
>  		else

Applied
