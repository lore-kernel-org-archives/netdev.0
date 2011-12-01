From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Bug in computing data_len in tcp_sendmsg?
Date: Thu, 01 Dec 2011 23:30:21 +0100
Message-ID: <1322778621.2750.48.camel@edumazet-laptop>
References: <CA+mtBx8+sajFaCWqHRr+pY5EAHwN8G61v6cr-HydYhbbdxAgHQ@mail.gmail.com>
	 <1322710962.2577.3.camel@edumazet-laptop>
	 <CA+mtBx_CUsuGunKONwBNA8qyVni16+RtrRL8w=THYY0mEDcvaA@mail.gmail.com>
	 <1322713032.2577.7.camel@edumazet-laptop>
	 <CAGK4HS8fLWwdPsrag6+Mz93_ZNg2B5JRjx2s=Re8_Qiv4V=T=w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tom Herbert <therbert@google.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Vijay Subramanian <subramanian.vijay@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:57687 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754798Ab1LAWa0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2011 17:30:26 -0500
Received: by bkas6 with SMTP id s6so3026019bka.19
        for <netdev@vger.kernel.org>; Thu, 01 Dec 2011 14:30:25 -0800 (PST)
In-Reply-To: <CAGK4HS8fLWwdPsrag6+Mz93_ZNg2B5JRjx2s=Re8_Qiv4V=T=w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 01 d=C3=A9cembre 2011 =C3=A0 14:18 -0800, Vijay Subramanian a =
=C3=A9crit :
> >
> > Or the "bug" was to assume that skb was headless.
> > It was true until recently.
> >
> > We recently added commit f07d960df33c5aef
> > (tcp: avoid frag allocation for small frames)
> >
> > to avoid page allocation for small frames.
> >
> > So now, skb can contain in head part of tcp data.
> >
> >
>=20
> Hi,
> I am looking at tcp_mtu_probe() and was wondering if this commit also
> impacts this function. Once the data are copied from skbs in the writ=
e
> queue to the probe skb, copied data are cleared from the original skb=
s
> in the write queue.
>=20
> It looks like the code assumes that the original skb will have data
> either in linear part or in paged part.  The call to
> __pskb_trim_head(skb, copy) for example does not clear linear part.
>=20
> Can someone more familiar with the code take a look? Apologies if I
> have read this wrong.
>=20

tcp_mtu_probe() builds a linear skb, and populate it using
skb_copy_bits() [ this is frag aware, and aware of payload in header as
well ]

I see no problem in it.
