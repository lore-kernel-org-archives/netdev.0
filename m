From: Salvatore Mesoraca <s.mesoraca16@gmail.com>
Subject: Re: [PATCH] iputils ping: add (non-raw) ICMP socket support
Date: Wed, 08 Apr 2015 13:05:27 +0200
Message-ID: <5093199.DdecKAOFEl@msg-id>
References: <2142872.6QHf5ZAfZz@msg-id> <1749676.NUxJ1eyH1x@msg-id> <5524F2EB.4000908@miraclelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Vasiliy Kulikov <segooon@gmail.com>,
	Tyler Hicks <tyhicks@canonical.com>
To: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:38488 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752729AbbDHLFf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2015 07:05:35 -0400
Received: by wiun10 with SMTP id n10so53597759wiu.1
        for <netdev@vger.kernel.org>; Wed, 08 Apr 2015 04:05:34 -0700 (PDT)
In-Reply-To: <5524F2EB.4000908@miraclelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In data mercoled=EC 8 aprile 2015 18:20:43, YOSHIFUJI Hideaki ha scritt=
o:
> Salvatore Mesoraca wrote:
> > YOSHIFUJI Hideaki wrote:
> >> Hi,
> >=20
> > Hi,
> > thank you for thaking to the time to answer
> >=20
> >> Salvatore Mesoraca wrote:
> >>> From: Vasiliy Kulikov <segooon@gmail.com>
> >>>=20
> >>> This patch adds non-raw IPPROTO_ICMP socket kind support that was=
 added
> >>> to the Linux 3.0.  The patch is backward-compatible: if ICMP sock=
et kind
> >>> is not enabled in the kernel (either in case of an old kernel or
> >>> explicitly disabled via /proc/sys/net/ipv4/ping_group_range), pin=
g uses
> >>> old privileged raw sockets as a fallback.
> >>>=20
> >>> This patch is going to be included in Ubuntu 15.10 and it is alre=
ady
> >>> included in Gentoo stable tree (at the moment of the writing ping=
 has
> >>> CAP_NET_RAW still enabled by default) it is also included in Open=
Wall
> >>> since 2011.
> >>> This patch also tries to sneak in a fix for a missing colon in a =
printf.
> >>> I've tested it on Linux 3.17.7 and it worked without issues.
> >>=20
> >> Please do not mix changes in a single commit.
> >> Thanks.
> >=20
> > I had some doubt about that additional change (it is so small that =
I don't
> > think that anyone will ever make a separate patch for it), but it w=
as
> > present in the original patch and I decided to add it anyway and wa=
it for
> > feedback. I'll delete it.
> > Thank you again for you comment.
>=20
> What I meant was changes not for supporting non-raw icmp socket
> should be formed separately.  It seems that the patch try to
> change other things as well, in receive_error_msg() for example.
>=20
> --yoshfuji

Thank you for the clarification.
If I understood correctly you were referring to these lines:
> @@ -652,9 +687,18 @@ int receive_error_msg()
>             goto out;
>         }
>=20
> -       acknowledge(ntohs(icmph.un.echo.sequence));
> +       error_pkt =3D (e->ee_type !=3D ICMP_REDIRECT &&
> +                e->ee_type !=3D ICMP_SOURCE_QUENCH);
> +       if (error_pkt) {
> +           acknowledge(ntohs(icmph.un.echo.sequence));
> +           net_errors++;
> +           nerrors++;
> +       }
> +       else {
> +           saved_errno =3D 0;
> +       }


In my understanding these changes are required to support non-raw ICMP =
sockets=20
because they cannot use setsockopt(icmp_sock, SOL_RAW, ICMP_FILTER...) =
and=20
they need to get rid of ICMP_REDIRECT and ICMP_SOURCE_QUENCH in a diffe=
rent=20
way. IMHO this change alone does not make much sense.
Anyway if you think that this and other changes should be in different =
commits=20
I'll post a split PATCHv2.
Thank you again for your time.

Salvatore Mesoraca
