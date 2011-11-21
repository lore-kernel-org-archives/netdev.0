From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch] fix error handle in ip_mc_add_src()
Date: Mon, 21 Nov 2011 16:24:26 +0100
Message-ID: <1321889066.10470.10.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1321887946.14281.27.camel@barry.pixelworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Jun Zhao <mypopydev@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:38772 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751574Ab1KUPYb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2011 10:24:31 -0500
Received: by bke11 with SMTP id 11so6686906bke.19
        for <netdev@vger.kernel.org>; Mon, 21 Nov 2011 07:24:30 -0800 (PST)
In-Reply-To: <1321887946.14281.27.camel@barry.pixelworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 21 novembre 2011 =C3=A0 23:05 +0800, Jun Zhao a =C3=A9crit :
> When add sources to interface failure, need to roll back the sfcount[=
MODE]=20
> to before state. We need to match it corresponding.=20
>=20

Missing "---" separator

> diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
> index c7472ef..276719a 100644
> --- a/net/ipv4/igmp.c
> +++ b/net/ipv4/igmp.c
> @@ -1716,7 +1716,8 @@ static int ip_mc_add_src(struct in_device *in_d=
ev, __be32 *pmca, int sfmode,
>  	if (err) {
>  		int j;
> =20
> -		pmc->sfcount[sfmode]--;
> +		if(!delta)

Missing space, should be  : if (!delta)

> +			pmc->sfcount[sfmode]--;
>  		for (j=3D0; j<i; j++)
>  			(void) ip_mc_del1_src(pmc, sfmode, &psfsrc[j]);
>  	} else if (isexclude !=3D (pmc->sfcount[MCAST_EXCLUDE] !=3D 0)) {
>=20
> Signed-off-by: Jun Zhao <mypopydev@gmail.com>
>=20

Your "Signed-off-by:" should come before actual patch

Please read Documentation/SubmittingPatches

Thanks
