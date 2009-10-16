From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP_DEFER_ACCEPT is missing counter update
Date: Fri, 16 Oct 2009 05:51:16 +0200
Message-ID: <4AD7EDB4.7060907@gmail.com>
References: <20091014045226.GA15655@1wt.eu> <Pine.LNX.4.58.0910140912420.2714@u.domain.uli> <20091014201706.GA24298@1wt.eu> <20091014.154349.83940908.davem@davemloft.net> <20091015060834.GB29564@1wt.eu> <Pine.LNX.4.58.0910151120340.2879@u.domain.uli> <20091015124134.GB1073@1wt.eu> <Pine.LNX.4.58.0910152257410.3047@u.domain.uli>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Willy Tarreau <w@1wt.eu>, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:56746 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750951AbZJPDwf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Oct 2009 23:52:35 -0400
In-Reply-To: <Pine.LNX.4.58.0910152257410.3047@u.domain.uli>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Julian Anastasov a =E9crit :
> 	Sorry for the long mail ...
>=20
> 	I was not clear enough in previous email. Your goal
> is to decrease period per client while the actually decreased
> threshold is on the listener's socket. 256 conns will be enough
> to completely disable TCP_DEFER_ACCEPT on the listener (u8). I'm not
> sure that you tested what happens after Nth client (where
> N matches your TCP_DEFER_ACCEPT value as retransmissions), do you
> still see accept deferring for next clients? Now if your patch
> is applied the deferring will be disabled soon after server start.


So, it appears defer_accept value is not an inherited attribute,
but shared by all embryons. Therefore we should not touch it.

No need to type so much text Julian.

Of course it should be done, or add a new connection field to count num=
ber
of pure ACKS received on each SYN_RECV embryon.

Do you volunter for this patch ?
