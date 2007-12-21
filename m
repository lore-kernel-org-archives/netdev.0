From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] [IPROUTE]: A workaround to make larger rto_min printed
 correctly
Date: Fri, 21 Dec 2007 09:14:33 -0800
Message-ID: <20071221091433.424c52db@deepthought>
References: <d72b7ace0712201824k3754962cse377256cb5452b8a@mail.gmail.com>
	<20071221.175352.77874691.yoshfuji@linux-ipv6.org>
	<d72b7ace0712210549u51043bf8k585fd70e1ded7d8a@mail.gmail.com>
	<20071221.225804.129665785.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: satoru.satoh@gmail.com, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: YOSHIFUJI Hideaki / =?UTF-8?B?5ZCJ6Jek6Iux5piO?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:40769 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750763AbXLURPO convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Dec 2007 12:15:14 -0500
In-Reply-To: <20071221.225804.129665785.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 21 Dec 2007 22:58:04 +0900 (JST)
YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E <yoshfuji@linu=
x-ipv6.org> wrote:

> In article <d72b7ace0712210549u51043bf8k585fd70e1ded7d8a@mail.gmail.c=
om> (at Fri, 21 Dec 2007 22:49:59 +0900), "Satoru SATOH" <satoru.satoh@=
gmail.com> says:
>=20
> > I agree.
> >=20
> > I mistakenly thought hz in that context must be larger than 1000..
> > As it's uncertain, your's looks much simpler and better.
> >=20
> > (btw, the lines "else .... div =3D 1" is not needed, is it?)
>=20
> Simplest fix is as follows:
>=20
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> --
> diff --git a/ip/iproute.c b/ip/iproute.c
> index f4200ae..7a885b0 100644
> --- a/ip/iproute.c
> +++ b/ip/iproute.c
> @@ -509,7 +509,7 @@ int print_route(const struct sockaddr_nl *who, st=
ruct nlmsghdr *n, void *arg)
>  			    i !=3D RTAX_RTO_MIN)
>  				fprintf(fp, " %u", *(unsigned*)RTA_DATA(mxrta[i]));
>  			else {
> -				unsigned val =3D *(unsigned*)RTA_DATA(mxrta[i]);
> +				unsigned long long val =3D *(unsigned*)RTA_DATA(mxrta[i]);
> =20
>  				val *=3D 1000;
>  				if (i =3D=3D RTAX_RTT)
> @@ -517,7 +517,7 @@ int print_route(const struct sockaddr_nl *who, st=
ruct nlmsghdr *n, void *arg)
>  				else if (i =3D=3D RTAX_RTTVAR)
>  					val /=3D 4;
>  				if (val >=3D hz)
> -					fprintf(fp, " %ums", val/hz);
> +					fprintf(fp, " %llums", val/hz);
>  				else
>  					fprintf(fp, " %.2fms", (float)val/hz);
>  			}
>=20

applied thanks.

--=20
Stephen Hemminger <stephen.hemminger@vyatta.com>
