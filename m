From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: introduce SO_BPF_EXTENSIONS
Date: Thu, 05 Dec 2013 09:32:50 -0800
Message-ID: <1386264770.30495.204.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1385639832-3938-1-git-send-email-msekleta@redhat.com>
	 <1385659889.5352.25.camel@edumazet-glaptop2.roam.corp.google.com>
	 <5298A0EF.70401@redhat.com>
	 <CAJ7VeQwC7xPPujCN8kQ3KcJAhykwQXLFA=vw2gWABmpUvuz1og@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Daniel Borkmann <dborkman@redhat.com>,
	Michal Sekletar <msekleta@redhat.com>, netdev@vger.kernel.org,
	Michael Kerrisk <mtk.manpages@gmail.com>
To: Michal =?ISO-8859-1?Q?Seklet=E1r?= <sekletar.m@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f44.google.com ([209.85.160.44]:59197 "EHLO
	mail-pb0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756993Ab3LERcv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Dec 2013 12:32:51 -0500
Received: by mail-pb0-f44.google.com with SMTP id rq2so26317855pbb.31
        for <netdev@vger.kernel.org>; Thu, 05 Dec 2013 09:32:51 -0800 (PST)
In-Reply-To: <CAJ7VeQwC7xPPujCN8kQ3KcJAhykwQXLFA=vw2gWABmpUvuz1og@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-12-05 at 18:28 +0100, Michal Seklet=C3=A1r wrote:
> On Fri, Nov 29, 2013 at 3:13 PM, Daniel Borkmann <dborkman@redhat.com=
> wrote:
> > On 11/28/2013 06:31 PM, Eric Dumazet wrote:
> >>
> >> On Thu, 2013-11-28 at 12:57 +0100, Michal Sekletar wrote:
> >>
> >>> +enum {
> >>> +       BPF_ANC_FLAG_PROTOCOL         =3D (1 << 0),
> >>> +       BPF_ANC_FLAG_PKTTYPE          =3D (1 << 1),
> >>> +       BPF_ANC_FLAG_IFINDEX          =3D (1 << 2),
> >>> +       BPF_ANC_FLAG_NLATTR           =3D (1 << 3),
> >>> +       BPF_ANC_FLAG_NLATTR_NEST      =3D (1 << 4),
> >>> +       BPF_ANC_FLAG_MARK             =3D (1 << 5),
> >>> +       BPF_ANC_FLAG_QUEUE            =3D (1 << 6),
> >>> +       BPF_ANC_FLAG_HATYPE           =3D (1 << 7),
> >>> +       BPF_ANC_FLAG_RXHASH           =3D (1 << 8),
> >>> +       BPF_ANC_FLAG_CPU              =3D (1 << 9),
> >>> +       BPF_ANC_FLAG_ALU_XOR_X        =3D (1 << 10),
> >>> +       BPF_ANC_FLAG_SECCOMP_LD_W     =3D (1 << 11),
> >>> +       BPF_ANC_FLAG_VLAN_TAG         =3D (1 << 12),
> >>> +       BPF_ANC_FLAG_VLAN_TAG_PRESENT =3D (1 << 13),
> >>> +       BPF_ANC_FLAG_PAY_OFFSET       =3D (1 << 14),
> >>> +};
> >>> +
> >>
> >>
> >> Why spending 15 bits (out of 32), for all these extensions ?
> >>
> >> It seems a single one should be enough.
> >>
> >> I do not think we will ever remove one of these extension.
> >
> >
> > Agreed, this will just cripple of us adding other extensions in
> > terms of uapi. I assume there won't be so much more extensions,
> > but it's of course hard to predict the future. ;-)
> >
>=20
> Not sure I follow. Can you please elaborate on the explanation. Pleas=
e
> bare with me this is my first kernel patch submission.

if SO_BPF_EXTENSIONS is supported, than you can assume that all current
extensions are supported.

No need to consume one bit per feature, as all these features wont ever
disappear from linux.
