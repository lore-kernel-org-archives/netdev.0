From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6 v4] net_sched: SFB flow scheduler
Date: Thu, 24 Feb 2011 06:40:35 +0100
Message-ID: <1298526035.2898.20.camel@edumazet-laptop>
References: <1298390536.2861.9.camel@edumazet-laptop>
	 <1298474091.3301.364.camel@edumazet-laptop>
	 <1298494577.2898.9.camel@edumazet-laptop>
	 <20110223.140614.112607341.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Juliusz.Chroboczek@pps.jussieu.fr, linville@tuxdriver.com,
	shemminger@vyatta.com, kaber@trash.net, netdev@vger.kernel.org,
	andi@firstfloor.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:48256 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751537Ab1BXFkl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Feb 2011 00:40:41 -0500
Received: by wyg36 with SMTP id 36so192656wyg.19
        for <netdev@vger.kernel.org>; Wed, 23 Feb 2011 21:40:40 -0800 (PST)
In-Reply-To: <20110223.140614.112607341.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 23 f=C3=A9vrier 2011 =C3=A0 14:06 -0800, David Miller a =C3=
=A9crit :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Wed, 23 Feb 2011 21:56:17 +0100
>=20
> > This is the Stochastic Fair Blue scheduler, based on work from :
>=20
> Applied with the 'static' fix, thanks Eric!

Thanks David !

My next step is to expand the idea I had some time ago (with my SFQ
works in december) :

Add a generic (core) service :

- Timestamp skb when it enters qdisc (might use skb->tstamp ?)
- At dequeue time, compute the delay.

1) Be able to mark/drop the packet right before giving it to device if
delay above a threshold, or use an array of thresholds depending on TOS

2) Integrate the delay into one EWMA

3) For SFB : Use the EWMA to eventually replace the non convenient
penalty_box by auto adaptative mechanism : Allow non elastic flows to
take part of the bandwidth, using a drop/mark probability depending on
this EWMA.



