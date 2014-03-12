From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [tcp] The ssthresh reduce during 3WHS
Date: Wed, 12 Mar 2014 07:26:30 -0700
Message-ID: <1394634390.21721.46.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAH4NVoT4ofCNKAmcnO1AgEbs+ywbXom=E28k2VU4dB+yK79S_A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Jerry Chu <hkchu@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: Yong Zhang <fell198904@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:45554 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754221AbaCLO0c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Mar 2014 10:26:32 -0400
Received: by mail-pd0-f182.google.com with SMTP id y10so483180pdj.13
        for <netdev@vger.kernel.org>; Wed, 12 Mar 2014 07:26:31 -0700 (PDT)
In-Reply-To: <CAH4NVoT4ofCNKAmcnO1AgEbs+ywbXom=E28k2VU4dB+yK79S_A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-03-12 at 21:46 +0800, Yong Zhang wrote:
> hi=EF=BC=8C
>=20
> I am trying to to apply patch 9ad7c049f0f79c418e293b1b68cf10d68f54fcd=
b
> to my old version kernel, but I am not understanding the following
> changes.
>=20
> The comments int the patch say ssthresh may reduce unnecessarily
> druing 3WHS,  but i can not find the reduce operation of ssthresh
> during 3WHS.
>=20
> Can you please explain when dose this may hanppen?
>=20

You might CC patch author when asking such questions...


>=20
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index bef9f04..ea0d218 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -880,6 +880,11 @@ static void tcp_init_metrics(struct sock *sk)
>=20
>         tp->snd_ssthresh =3D dst_metric(dst, RTAX_SSTHRESH);
>                  if (tp->snd_ssthresh > tp->snd_cwnd_clamp)
>                          tp->snd_ssthresh =3D tp->snd_cwnd_clamp;
> +       } else {
> +                /* ssthresh may have been reduced unnecessarily duri=
ng.
> +                * 3WHS. Restore it back to its initial default.
> +                */
> +                tp->snd_ssthresh =3D TCP_INFINITE_SSTHRESH;
>          }
>=20
>=20
> Thanks,
> Fel
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
