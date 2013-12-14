From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ip_gre: fix msg_name parsing for recvfrom/recvmsg
Date: Sat, 14 Dec 2013 00:52:32 -0500 (EST)
Message-ID: <20131214.005232.1773340007123224291.davem@davemloft.net>
References: <1386838432-18889-1-git-send-email-timo.teras@iki.fi>
	<20131212.153429.1628298422222449867.davem@davemloft.net>
	<20131213080844.3b48e774@vostro>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, pshelar@nicira.com
To: timo.teras@iki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48638 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751088Ab3LNFwg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Dec 2013 00:52:36 -0500
In-Reply-To: <20131213080844.3b48e774@vostro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Timo Teras <timo.teras@iki.fi>
Date: Fri, 13 Dec 2013 08:08:44 +0200

> On Thu, 12 Dec 2013 15:34:29 -0500 (EST)
> David Miller <davem@davemloft.net> wrote:
>=20
>> From: Timo Ter=E4s <timo.teras@iki.fi>
>> Date: Thu, 12 Dec 2013 10:53:52 +0200
>>=20
>> > ipgre_header_parse() needs to parse the tunnel's ip header for
>> > getting the link-layer addresses, and uses mac_header to get the
>> > header. This fixes setting mac_header on the receive path to
>> > original behaviour.
>> >=20
>> > Bug added in commit c54419321455 (GRE: Refactor GRE tunneling code=
=2E)
>> >=20
>> > Cc: Pravin B Shelar <pshelar@nicira.com>
>> > Signed-off-by: Timo Ter=E4s <timo.teras@iki.fi>
>> > ---
>> > Alternate would be to do skb_reset_inner_headers() in
>> > ip_tunnel_rcv() and update ipgre_header_parse() to use
>> > skb_inner_network_header(). Though, then inner would then be
>> > referring to the "outer" headers.
>> >=20
>> > If applied as-is, should go to -stable too.
>>=20
>> Would skb_reset_mac_header() work just as equally?  I'd prefer that
>> over direct modification of skb->*_header values.
>=20
> No. It was actually converted originally to skb_reset_mac_header() bu=
t
> that led to problems. See commit 1d0691674764098304ae4c63c715f588.
>=20
> When ipgre_rcv is entered, the outer iphdr has been already pulled,
> thus head points to the GRE header. So skb_reset_mac_header() would
> make it point at the GRE header instead of the desired outer IP heade=
r.
>=20
> But I agree that it'd be better to use helpers. That's why I suggeste=
d
> the skb_reset_inner_headers() as an alternative. But as it's slightly
> more intrusive approach, I opted to just restore the original assignm=
ent
> as first suggestion.

Just make a helper that does this mac_header =3D network_header thing,
call it something like "skb_pop_mac_header(skb)" and the make the ip_gr=
e
code use it.

Thanks.
