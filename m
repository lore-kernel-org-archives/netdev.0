From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ip_gre: fix msg_name parsing for recvfrom/recvmsg
Date: Thu, 12 Dec 2013 15:34:29 -0500 (EST)
Message-ID: <20131212.153429.1628298422222449867.davem@davemloft.net>
References: <1386838432-18889-1-git-send-email-timo.teras@iki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, pshelar@nicira.com
To: timo.teras@iki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39578 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751608Ab3LLUed convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Dec 2013 15:34:33 -0500
In-Reply-To: <1386838432-18889-1-git-send-email-timo.teras@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Timo Ter=E4s <timo.teras@iki.fi>
Date: Thu, 12 Dec 2013 10:53:52 +0200

> ipgre_header_parse() needs to parse the tunnel's ip header for gettin=
g
> the link-layer addresses, and uses mac_header to get the header. This
> fixes setting mac_header on the receive path to original behaviour.
>=20
> Bug added in commit c54419321455 (GRE: Refactor GRE tunneling code.)
>=20
> Cc: Pravin B Shelar <pshelar@nicira.com>
> Signed-off-by: Timo Ter=E4s <timo.teras@iki.fi>
> ---
> Alternate would be to do skb_reset_inner_headers() in ip_tunnel_rcv()=
 and
> update ipgre_header_parse() to use skb_inner_network_header(). Though=
, then
> inner would then be referring to the "outer" headers.
>=20
> If applied as-is, should go to -stable too.

Would skb_reset_mac_header() work just as equally?  I'd prefer that ove=
r
direct modification of skb->*_header values.

Thanks.
