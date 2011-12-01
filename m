From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Bug in computing data_len in tcp_sendmsg?
Date: Thu, 01 Dec 2011 10:15:37 +0100
Message-ID: <1322730937.2335.6.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <CA+mtBx8+sajFaCWqHRr+pY5EAHwN8G61v6cr-HydYhbbdxAgHQ@mail.gmail.com>
	 <1322710962.2577.3.camel@edumazet-laptop>
	 <CA+mtBx_CUsuGunKONwBNA8qyVni16+RtrRL8w=THYY0mEDcvaA@mail.gmail.com>
	 <1322713032.2577.7.camel@edumazet-laptop>
	 <CA+mtBx9fE0qQc-LndM03ykhVMV5n9Z4KHcD6PpTiy=M79GOnKw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:43170 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751741Ab1LAJPk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2011 04:15:40 -0500
Received: by vbbfc26 with SMTP id fc26so1214909vbb.19
        for <netdev@vger.kernel.org>; Thu, 01 Dec 2011 01:15:40 -0800 (PST)
In-Reply-To: <CA+mtBx9fE0qQc-LndM03ykhVMV5n9Z4KHcD6PpTiy=M79GOnKw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 30 novembre 2011 =C3=A0 21:09 -0800, Tom Herbert a =C3=A9cr=
it :
> > Or the "bug" was to assume that skb was headless.
> > It was true until recently.
> >
> > We recently added commit f07d960df33c5aef
> > (tcp: avoid frag allocation for small frames)
> >
> > to avoid page allocation for small frames.
> >
> > So now, skb can contain in head part of tcp data.
>=20
> Yes, reverting that patch seems to fix the problem.  Eric, do you hav=
e
> an idea what should be used to determine length of headers in an skb
> now (mac through transport).

I dont know why its even necessary :

TSO enabled NIC all provide hardware counters, so why even bother
computing tx_bytes ourself ?

skb->len is appropriate for BQL, as long as producers/consumer use the
same skb->len. 1 or 2% error is not a problem if not cumulative ?
