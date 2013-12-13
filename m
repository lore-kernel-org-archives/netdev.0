From: Timo Teras <timo.teras@iki.fi>
Subject: Re: [PATCH net] ip_gre: fix msg_name parsing for recvfrom/recvmsg
Date: Fri, 13 Dec 2013 08:08:44 +0200
Message-ID: <20131213080844.3b48e774@vostro>
References: <1386838432-18889-1-git-send-email-timo.teras@iki.fi>
	<20131212.153429.1628298422222449867.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, pshelar@nicira.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f54.google.com ([209.85.215.54]:45825 "EHLO
	mail-la0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750756Ab3LMGIm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Dec 2013 01:08:42 -0500
Received: by mail-la0-f54.google.com with SMTP id b8so1066691lan.27
        for <netdev@vger.kernel.org>; Thu, 12 Dec 2013 22:08:41 -0800 (PST)
In-Reply-To: <20131212.153429.1628298422222449867.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 12 Dec 2013 15:34:29 -0500 (EST)
David Miller <davem@davemloft.net> wrote:

> From: Timo Ter=C3=A4s <timo.teras@iki.fi>
> Date: Thu, 12 Dec 2013 10:53:52 +0200
>=20
> > ipgre_header_parse() needs to parse the tunnel's ip header for
> > getting the link-layer addresses, and uses mac_header to get the
> > header. This fixes setting mac_header on the receive path to
> > original behaviour.
> >=20
> > Bug added in commit c54419321455 (GRE: Refactor GRE tunneling code.=
)
> >=20
> > Cc: Pravin B Shelar <pshelar@nicira.com>
> > Signed-off-by: Timo Ter=C3=A4s <timo.teras@iki.fi>
> > ---
> > Alternate would be to do skb_reset_inner_headers() in
> > ip_tunnel_rcv() and update ipgre_header_parse() to use
> > skb_inner_network_header(). Though, then inner would then be
> > referring to the "outer" headers.
> >=20
> > If applied as-is, should go to -stable too.
>=20
> Would skb_reset_mac_header() work just as equally?  I'd prefer that
> over direct modification of skb->*_header values.

No. It was actually converted originally to skb_reset_mac_header() but
that led to problems. See commit 1d0691674764098304ae4c63c715f588.

When ipgre_rcv is entered, the outer iphdr has been already pulled,
thus head points to the GRE header. So skb_reset_mac_header() would
make it point at the GRE header instead of the desired outer IP header.

But I agree that it'd be better to use helpers. That's why I suggested
the skb_reset_inner_headers() as an alternative. But as it's slightly
more intrusive approach, I opted to just restore the original assignmen=
t
as first suggestion.

- Timo
