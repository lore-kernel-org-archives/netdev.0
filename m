From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Bug in computing data_len in tcp_sendmsg?
Date: Fri, 02 Dec 2011 17:05:35 +0100
Message-ID: <1322841935.2762.33.camel@edumazet-laptop>
References: <CA+mtBx8+sajFaCWqHRr+pY5EAHwN8G61v6cr-HydYhbbdxAgHQ@mail.gmail.com>
	 <1322710962.2577.3.camel@edumazet-laptop>
	 <CA+mtBx_CUsuGunKONwBNA8qyVni16+RtrRL8w=THYY0mEDcvaA@mail.gmail.com>
	 <1322713032.2577.7.camel@edumazet-laptop>
	 <CAGK4HS8fLWwdPsrag6+Mz93_ZNg2B5JRjx2s=Re8_Qiv4V=T=w@mail.gmail.com>
	 <1322778621.2750.48.camel@edumazet-laptop>
	 <CAGK4HS84vepB-cOnjOASqXy2gLWGwx=RHnQ3PbbMPezxJ5m3QQ@mail.gmail.com>
	 <1322827188.2607.19.camel@edumazet-laptop>
	 <1322840663.2762.26.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tom Herbert <therbert@google.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Vijay Subramanian <subramanian.vijay@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:61474 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756880Ab1LBQFl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2011 11:05:41 -0500
Received: by lagp5 with SMTP id p5so239421lag.19
        for <netdev@vger.kernel.org>; Fri, 02 Dec 2011 08:05:40 -0800 (PST)
In-Reply-To: <1322840663.2762.26.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 02 d=C3=A9cembre 2011 =C3=A0 16:44 +0100, Eric Dumazet a =C3=
=A9crit :

> [PATCH net-next] tcp: fix tcp_trim_head()
>=20
> commit f07d960df3 (tcp: avoid frag allocation for small frames)
> breaked assumption in tcp stack that skb is either linear (data_len =3D=
=3D
> 0), either fully fragged (data_len =3D=3D len)
>=20
> Thanks to Vijay for providing a very detailed explanation.
>=20
> Reported-by: Vijay Subramanian <subramanian.vijay@gmail.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---

Another problem is the possible misalignement of skb->data if/when we
receive an ACK of an odd (not a 4 multiple) tcp sequence.

So when/if packet is restransmited, tcp header (and IP header as well)
could be misaligned.

Hmm, I probably miss something obvious, since this problem could happen
for linear skbs before my patch ?
