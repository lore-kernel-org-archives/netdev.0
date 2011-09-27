From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: unalias tcp_skb_cb flags and ip_dsfield
Date: Tue, 27 Sep 2011 11:23:29 +0200
Message-ID: <1317115409.2541.6.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1317103249.2796.25.camel@edumazet-laptop>
	 <201109271037.38786.christoph.paasch@uclouvain.be>
	 <20110927.040853.516739403765881835.davem@davemloft.net>
	 <201109271138.00318.christoph.paasch@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	hkchu@google.com, ilpo.jarvinen@helsinki.fi, jhs@mojatatu.com
To: christoph.paasch@uclouvain.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:54031 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752594Ab1I0JXT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2011 05:23:19 -0400
Received: by gyg10 with SMTP id 10so4966322gyg.19
        for <netdev@vger.kernel.org>; Tue, 27 Sep 2011 02:23:18 -0700 (PDT)
In-Reply-To: <201109271138.00318.christoph.paasch@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 27 septembre 2011 =C3=A0 11:38 +0300, Christoph Paasch a =C3=A9=
crit :
> On Tuesday 27 September 2011 wrote David Miller:
> > From: Christoph Paasch <christoph.paasch@uclouvain.be>
> > Date: Tue, 27 Sep 2011 10:37:38 +0300
> >=20
> > > However, (as far as I can see) before Eric's change it was 42 byt=
es long
> > > and now it became 43 bytes.
> >=20
> > Then, I suggest that you go buy a pair of glasses. :-)
>=20
> Yeah, maybe it's time to... ;-)
>=20
> This two-byte hole, is it because "flags" and "sacked" are both __u8 =
and=20
> fields are aligned to 32-bit ?

Not exactly.

Reason for the hole is the following :

struct whatever {
	u8   first;
	u8   second;
	u32  third;
};

"third" field has an alignement requirement of 4 bytes on most arches.

Compiler inserts a 2 bytes hole before "third" to respect this
requirement.

There is no hole between "first" and "second", since second has no
alignment requirement.

sizeof(struct whatever) =3D 8
