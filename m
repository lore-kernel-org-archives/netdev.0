From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: Fix for stalling connections
Date: Mon, 07 Dec 2009 07:15:48 +0100
Message-ID: <4B1C9D94.3070504@gmail.com>
References: <4B1C4C25.1070104@tvk.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netdev <netdev@vger.kernel.org>,
	=?ISO-8859-15?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Frederic Leroy <fredo@starox.org>,
	David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Greg KH <gregkh@suse.de>
To: Damian Lukowski <damian@tvk.rwth-aachen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:37126 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753809AbZLGGP7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2009 01:15:59 -0500
In-Reply-To: <4B1C4C25.1070104@tvk.rwth-aachen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Damian Lukowski a =E9crit :
> This patch fixes a problem in the TCP connection timeout calculation.
> Currently, timeout decisions are made on the basis of the current
> tcp_time_stamp and retrans_stamp, which is usually set at the first
> retransmission.
> However, if the retransmission fails in tcp_retransmit_skb(),
> retrans_stamp is not updated and remains zero. This leads to wrong
> decisions in retransmits_timed_out() if tcp_time_stamp is larger than
> the specified timeout, which is very likely.
> In this case, the TCP connection dies after the first attempted
> (and unsuccessful) retransmission.
>=20
> With this patch, tcp_skb_cb->when is used instead, when retrans_stamp
> is not available.
>=20
> Thanks to Ilpo J=E4rvinen for code suggestions.
>=20
> Signed-off-by: Damian Lukowski <damian@tvk.rwth-aachen.de>

Hmm, how old is this bug ?

You should a hint of faulty commit so that stable team can apply
this patch to 2.6.32 & 2.6.31

git describe 6fa12c85031485dff38ce550c24f10da23b0adaa

v2.6.31-rc5-1853-g6fa12c8

Or maybe David handles this for us, I dont know...

Minor note : retransmits_timed_out() is used in from net/ipv4/tcp_timer=
=2Ec
I wonder why its a "static inline" in include/net/tcp.h

Thanks

