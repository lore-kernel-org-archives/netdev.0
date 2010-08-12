From: Fabio Comolli <fabio.comolli@gmail.com>
Subject: Re: [PATCH] iproute2: dont filter cached routes on iproute_get
Date: Thu, 12 Aug 2010 11:12:12 +0200
Message-ID: <AANLkTikKbNPXv+F6SuR79Q9qcS1WD1DOYLGuOtuLkzuK@mail.gmail.com>
References: <20100808193304.GA15380@amd64.fatal.se>
	<AANLkTim4h7rTJuF7UWAE-p_4NGkrwksUjoK6m2x5BubG@mail.gmail.com>
	<1281297165.4116.19.camel@amd64.fatal.se>
	<20100812090519.GA13769@babylon>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andreas Henriksson <andreas@fatal.se>, shemminger@vyatta.com,
	netdev@vger.kernel.org
To: Ulrich Weber <uweber@astaro.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:59234 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933242Ab0HLJMO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Aug 2010 05:12:14 -0400
Received: by bwz3 with SMTP id 3so749486bwz.19
        for <netdev@vger.kernel.org>; Thu, 12 Aug 2010 02:12:12 -0700 (PDT)
In-Reply-To: <20100812090519.GA13769@babylon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.
Is this patch supposed to be applied on top of plain iproute2 v2.6.35
or on top of the previous Andreas' patch?



On Thu, Aug 12, 2010 at 11:05 AM, Ulrich Weber <uweber@astaro.com> wrot=
e:
> iproute_get will return cloned routes for IPv4
> and cloned as well non-cloned routes for IPv6.
>
> Therefore RTM_F_CLONED flag should not be checked
> for iproute_get routes. Check in print_route will
> always fail because valid values are 0 and 1.
>
> Signed-off-by: Ulrich Weber <uweber@astaro.com>
> ---
> =C2=A0ip/iproute.c | =C2=A0 =C2=A01 +
> =C2=A01 files changed, 1 insertions(+), 0 deletions(-)
>
> diff --git a/ip/iproute.c b/ip/iproute.c
> index 711576e..b43933c 100644
> --- a/ip/iproute.c
> +++ b/ip/iproute.c
> @@ -1286,6 +1286,7 @@ int iproute_get(int argc, char **argv)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0memset(&req, 0, sizeof(req));
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0iproute_reset_filter();
> + =C2=A0 =C2=A0 =C2=A0 filter.cloned =3D 2;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0req.n.nlmsg_len =3D NLMSG_LENGTH(sizeof(st=
ruct rtmsg));
> =C2=A0 =C2=A0 =C2=A0 =C2=A0req.n.nlmsg_flags =3D NLM_F_REQUEST;
> --
> 1.7.0.4
>
>
