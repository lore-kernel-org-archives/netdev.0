From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] iproute2: use IFLA_TXQLEN when it is available
Date: Thu, 12 May 2011 05:28:06 +0200
Message-ID: <1305170886.3232.13.camel@edumazet-laptop>
References: <1305168451-14491-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@vyatta.com, netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:37419 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751692Ab1ELD2L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 May 2011 23:28:11 -0400
Received: by wwa36 with SMTP id 36so1277876wwa.1
        for <netdev@vger.kernel.org>; Wed, 11 May 2011 20:28:10 -0700 (PDT)
In-Reply-To: <1305168451-14491-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 12 mai 2011 =C3=A0 10:47 +0800, Changli Gao a =C3=A9crit :
> Use IFLA_TXQLEN when it is available, to avoid additional system call=
s.
>=20
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
> ---
>  ip/ipaddress.c |   12 ++++++++++--
>  1 file changed, 10 insertions(+), 2 deletions(-)
> diff --git a/ip/ipaddress.c b/ip/ipaddress.c
> index a1f78b9..59afafd 100644
> --- a/ip/ipaddress.c
> +++ b/ip/ipaddress.c
> @@ -285,8 +285,16 @@ int print_linkinfo(const struct sockaddr_nl *who=
,
>  	if (tb[IFLA_OPERSTATE])
>  		print_operstate(fp, *(__u8 *)RTA_DATA(tb[IFLA_OPERSTATE]));
>  	=09
> -	if (filter.showqueue)
> -		print_queuelen(fp, (char*)RTA_DATA(tb[IFLA_IFNAME]));
> +	if (filter.showqueue) {
> +		if (tb[IFLA_TXQLEN]) {
> +			__u32 txqlen =3D *(__u32 *)RTA_DATA(tb[IFLA_TXQLEN]);
> +
> +			if (txqlen)
> +				fprintf(fp, "qlen %u", txqlen);
> +		} else {
> +			print_queuelen(fp, (char*)RTA_DATA(tb[IFLA_IFNAME]));
> +		}
> +	}
> =20
>  	if (!filter.family || filter.family =3D=3D AF_PACKET) {
>  		SPRINT_BUF(b1);

Hmm, what iproute2 version do you use ???

commit 62a5e0668e2920b7f09896abd884753255712a46
Author: Eric Dumazet <dada1@cosmosbay.com>
Date:   Fri Oct 23 06:25:53 2009 +0200

    ip: Support IFLA_TXQLEN in ip link show command
   =20
    We currently use an expensive ioctl() to get device txqueuelen, whi=
le
    rtnetlink gave it to us for free. This patch speeds up ip link oper=
ation
    when many devices are registered.



