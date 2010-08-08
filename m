From: Fabio Comolli <fabio.comolli@gmail.com>
Subject: Re: Latest iproute2 breaks "ip route get" command
Date: Sun, 8 Aug 2010 21:31:41 +0200
Message-ID: <AANLkTim4h7rTJuF7UWAE-p_4NGkrwksUjoK6m2x5BubG@mail.gmail.com>
References: <20100808193304.GA15380@amd64.fatal.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ulrich Weber <uweber@astaro.com>, netdev@vger.kernel.org
To: Andreas Henriksson <andreas@fatal.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:50882 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754823Ab0HHTbn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Aug 2010 15:31:43 -0400
Received: by bwz3 with SMTP id 3so805361bwz.19
        for <netdev@vger.kernel.org>; Sun, 08 Aug 2010 12:31:42 -0700 (PDT)
In-Reply-To: <20100808193304.GA15380@amd64.fatal.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yup, that seems to fix it.
You can add my Tested-By in case you need it.

Regards,
=46abio




On Sun, Aug 8, 2010 at 9:33 PM, Andreas Henriksson <andreas@fatal.se> w=
rote:
>> The following logs should explain the problem. In short, the "ip rou=
te
>> get" command with iproute2 v. 2.6.35 does not output anything (and
>> exits with a 0). This breaks (for example) vpnc.
>
> Seems to be caused by:
>
> http://git.kernel.org/?p=3Dlinux/kernel/git/shemminger/iproute2.git;a=
=3Dcommitdiff;h=3D447928279c88b6581ae4cdc1b5ac0a9e755aff64
>
> Have no idea if this is the correct fix, but it seemed like a likely =
typo
> based on the changes in the above commit and that this brings the out=
put back:
>
>
> diff --git a/ip/iproute.c b/ip/iproute.c
> index 711576e..86c7ab7 100644
> --- a/ip/iproute.c
> +++ b/ip/iproute.c
> @@ -160,7 +160,7 @@ int print_route(const struct sockaddr_nl *who, st=
ruct nlmsghdr *n, void *arg)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (r->rtm_family =3D=3D AF_INET6 && table=
 !=3D RT_TABLE_MAIN)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0ip6_multiple_t=
ables =3D 1;
>
> - =C2=A0 =C2=A0 =C2=A0 if (filter.cloned =3D=3D !(r->rtm_flags&RTM_F_=
CLONED))
> + =C2=A0 =C2=A0 =C2=A0 if (filter.cloned && !(r->rtm_flags&RTM_F_CLON=
ED))
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return 0;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (r->rtm_family =3D=3D AF_INET6 && !ip6_=
multiple_tables) {
>
>
>
> (PS. Sorry for not properly replying in thread, but todays mailing li=
st
> archives seems to be extremely afraid of exposing any real mail heade=
rs
> making it hard to reply properly without having received the original=
 mail.)
>
> --
> Andreas Henriksson
>
