From: Salvatore Mesoraca <s.mesoraca16@gmail.com>
Subject: Re: [PATCH] iputils ping: add (non-raw) ICMP socket support
Date: Wed, 08 Apr 2015 15:05:05 +0200
Message-ID: <5635504.5jEhSFiGfj@msg-id>
References: <2142872.6QHf5ZAfZz@msg-id> <5093199.DdecKAOFEl@msg-id> <5525198E.7030509@miraclelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Vasiliy Kulikov <segooon@gmail.com>,
	Tyler Hicks <tyhicks@canonical.com>
To: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:32791 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751717AbbDHNFQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2015 09:05:16 -0400
Received: by wiax7 with SMTP id x7so32681710wia.0
        for <netdev@vger.kernel.org>; Wed, 08 Apr 2015 06:05:14 -0700 (PDT)
In-Reply-To: <5525198E.7030509@miraclelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

YOSHIFUJI Hideaki wrote:
> Salvatore Mesoraca wrote:
> > In data mercoled=EC 8 aprile 2015 18:20:43, YOSHIFUJI Hideaki ha sc=
ritto:
> >> Salvatore Mesoraca wrote:
> >>> YOSHIFUJI Hideaki wrote:
> >>>> Hi,
> >>>=20
> >>> Hi,
> >>> thank you for thaking to the time to answer
> >>>=20
> >>>> Salvatore Mesoraca wrote:
> >>>>> From: Vasiliy Kulikov <segooon@gmail.com>
> >>>>>=20
> >>>>> This patch adds non-raw IPPROTO_ICMP socket kind support that w=
as
> >>>>> added
> >>>>> to the Linux 3.0.  The patch is backward-compatible: if ICMP so=
cket
> >>>>> kind
> >>>>> is not enabled in the kernel (either in case of an old kernel o=
r
> >>>>> explicitly disabled via /proc/sys/net/ipv4/ping_group_range), p=
ing
> >>>>> uses
> >>>>> old privileged raw sockets as a fallback.
> >>>>>=20
> >>>>> This patch is going to be included in Ubuntu 15.10 and it is al=
ready
> >>>>> included in Gentoo stable tree (at the moment of the writing pi=
ng has
> >>>>> CAP_NET_RAW still enabled by default) it is also included in Op=
enWall
> >>>>> since 2011.
> >>>>> This patch also tries to sneak in a fix for a missing colon in =
a
> >>>>> printf.
> >>>>> I've tested it on Linux 3.17.7 and it worked without issues.
> >>>>=20
> >>>> Please do not mix changes in a single commit.
> >>>> Thanks.
> >>>=20
> >>> I had some doubt about that additional change (it is so small tha=
t I
> >>> don't
> >>> think that anyone will ever make a separate patch for it), but it=
 was
> >>> present in the original patch and I decided to add it anyway and =
wait
> >>> for
> >>> feedback. I'll delete it.
> >>> Thank you again for you comment.
> >>=20
> >> What I meant was changes not for supporting non-raw icmp socket
> >> should be formed separately.  It seems that the patch try to
> >> change other things as well, in receive_error_msg() for example.
> >>=20
> >> --yoshfuji
> >=20
> > Thank you for the clarification.
> >=20
> > If I understood correctly you were referring to these lines:
> >> @@ -652,9 +687,18 @@ int receive_error_msg()
> >>=20
> >>             goto out;
> >>        =20
> >>         }
> >>=20
> >> -       acknowledge(ntohs(icmph.un.echo.sequence));
> >> +       error_pkt =3D (e->ee_type !=3D ICMP_REDIRECT &&
> >> +                e->ee_type !=3D ICMP_SOURCE_QUENCH);
> >> +       if (error_pkt) {
> >> +           acknowledge(ntohs(icmph.un.echo.sequence));
> >> +           net_errors++;
> >> +           nerrors++;
> >> +       }
> >> +       else {
> >> +           saved_errno =3D 0;
> >> +       }
> >=20
> > In my understanding these changes are required to support non-raw I=
CMP
> > sockets because they cannot use setsockopt(icmp_sock, SOL_RAW,
> > ICMP_FILTER...) and they need to get rid of ICMP_REDIRECT and
> > ICMP_SOURCE_QUENCH in a different way. IMHO this change alone does =
not
> > make much sense.
>=20
> OK, I understand.
>=20
> > Anyway if you think that this and other changes should be in differ=
ent
> > commits I'll post a split PATCHv2.
>=20
> No, please just exclude this from first patch:
> -			printf("From %s icmp_seq=3D%u ", pr_addr(sin->sin_addr.s_addr),
> ntohs(icmph.un.echo.sequence)); +			printf("From %s: icmp_seq=3D%u=20
",
> pr_addr(sin->sin_addr.s_addr), ntohs(icmph.un.echo.sequence));

Great, I'll submit PATCHv2 as soon as possible.


> And, would you provide patch for ping6 as well?

I was planning to work on ping6 as well If this patch get accepted.


> Thank you.

Thank you too for your time.

Salvatore Mesoraca
