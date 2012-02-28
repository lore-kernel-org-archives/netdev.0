From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/2] ipv4: fix mss comparison
Date: Tue, 28 Feb 2012 02:01:18 -0800
Message-ID: <1330423278.2610.17.camel@edumazet-laptop>
References: <1330417697-2637-1-git-send-email-roy.qing.li@gmail.com>
	 <1330417697-2637-2-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:55513 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932119Ab2B1KBU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Feb 2012 05:01:20 -0500
Received: by daed14 with SMTP id d14so2168929dae.19
        for <netdev@vger.kernel.org>; Tue, 28 Feb 2012 02:01:20 -0800 (PST)
In-Reply-To: <1330417697-2637-2-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 28 f=C3=A9vrier 2012 =C3=A0 16:28 +0800, roy.qing.li@gmail.com=
 a =C3=A9crit :
> From: RongQing.Li <roy.qing.li@gmail.com>
>=20
> mss should compare with 65535 - sizeof(struct tcphdr), =20
> the largest mss is 65535 - sizeof(struct tcphdr). =20
> 40 is sum of sizeof(struct tcphdr) and sizeof(struct iphdr)
>=20
> Signed-off-by: RongQing.Li <roy.qing.li@gmail.com>
> ---
>  net/ipv4/route.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
>=20
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index 0489ced..c72f765 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -1914,8 +1914,8 @@ static unsigned int ipv4_default_advmss(const s=
truct dst_entry *dst)
>  	if (advmss =3D=3D 0) {
>  		advmss =3D max_t(unsigned int, dst->dev->mtu - 40,
>  			       ip_rt_min_advmss);
> -		if (advmss > 65535 - 40)
> -			advmss =3D 65535 - 40;
> +		if (advmss > 65535 - sizeof(struct tcphdr))
> +			advmss =3D 65535 - sizeof(struct tcphdr);
>  	}
>  	return advmss;
>  }

Hmm... I am puzzled.

1) If you touch this code, please use min_t() macro to be consistent
with prior line ? Please note I dont advocate a general use of these
min/max macros, just some consistency in the same page of code.

2) Prior line still has the magic 40 value.
    (I personally like 40 more than sizeof(struct tcphdr) +
sizeof(struct iphdr)), its not like 40 is going to change one day :)

3) What is the maximum datagram size in ipv4.
      (Say you name this IPV4_MAXPLEN)

4) What would be the meaning of having TCP MSS bigger than
    IPV4_MAXPLEN - 40 ?
