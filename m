From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v2] tcp: avoid reducing cwnd when ACK+DSACK is
 received
Date: Thu, 08 Jan 2015 08:25:25 -0800
Message-ID: <1420734325.5947.61.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1420719609-18638-1-git-send-email-sebastien.barre@uclouvain.be>
	 <1420730396.5947.55.camel@edumazet-glaptop2.roam.corp.google.com>
	 <54AEA498.5030202@uclouvain.be>
	 <CADVnQy=A57TUYD=kGtZXvq7-FGSN=vN3D2heaNCnBB=zjujwUg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?ISO-8859-1?Q?S=E9bastien_Barr=E9?= <sebastien.barre@uclouvain.be>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Gregory Detal <gregory.detal@uclouvain.be>,
	Nandita Dukkipati <nanditad@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f180.google.com ([209.85.223.180]:65106 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754305AbbAHQZ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2015 11:25:28 -0500
Received: by mail-ie0-f180.google.com with SMTP id rp18so10272837iec.11
        for <netdev@vger.kernel.org>; Thu, 08 Jan 2015 08:25:27 -0800 (PST)
In-Reply-To: <CADVnQy=A57TUYD=kGtZXvq7-FGSN=vN3D2heaNCnBB=zjujwUg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-01-08 at 10:49 -0500, Neal Cardwell wrote:
> On Thu, Jan 8, 2015 at 10:39 AM, S=C3=A9bastien Barr=C3=A9
> <sebastien.barre@uclouvain.be> wrote:
> > What do you and Neal think ?
>=20
> My preference is to have the whole expression detecting the case wher=
e
> the receiver got the probe packet encoded in a single expression. I
> don't have a strong feeling about whether it should be stored in a
> bool (to reduce the size of the diff) or written directly into the if
> () expression (to reduce the size of the code). I'll defer to Eric on
> which he thinks is better. :-)

There is no shame using helpers with nice names to help understand this
TCP stack. Even if the helper is used exactly once.

In this case, it seems we test 2 different conditions, so this could us=
e
2 helpers with self describing names.

When I see :=20

> +     if (((ack =3D=3D tp->tlp_high_seq) &&
> +          !(flag & (FLAG_SND_UNA_ADVANCED |
> +                    FLAG_NOT_DUP | FLAG_DATA_SACKED))) ||
> +         (!before(ack, tp->tlp_high_seq) && (flag & FLAG_DSACKING_AC=
K))) {
>               tp->tlp_high_seq =3D 0;

My brain hurts.
