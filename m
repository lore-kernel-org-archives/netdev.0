From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv4: use next hop exceptions also for input
 routes
Date: Fri, 28 Jun 2013 21:28:37 -0700 (PDT)
Message-ID: <20130628.212837.1075149236161606798.davem@davemloft.net>
References: <1372318025-7634-1-git-send-email-timo.teras@iki.fi>
	<alpine.LFD.2.00.1306271146550.2436@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: timo.teras@iki.fi, netdev@vger.kernel.org
To: ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46196 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751820Ab3F2E2i convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Jun 2013 00:28:38 -0400
In-Reply-To: <alpine.LFD.2.00.1306271146550.2436@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Julian Anastasov <ja@ssi.bg>
Date: Thu, 27 Jun 2013 11:52:14 +0300 (EEST)

>=20
> 	Hello,
>=20
> On Thu, 27 Jun 2013, Timo Ter=E4s wrote:
>=20
>> Commit d2d68ba9 (ipv4: Cache input routes in fib_info nexthops)
>> assmued that "locally destined, and routed packets, never trigger
>> PMTU events or redirects that will be processed by us".
>>=20
>> However, it seems that tunnel devices do trigger PMTU events in cert=
ain
>> cases. At least ip_gre, ip6_gre, sit, and ipip do use the inner flow=
's
>> skb_dst(skb)->ops->update_pmtu to propage mtu information from the
>> outer flows. These can cause the inner flow mtu to be decreased. If
>> next hop exceptions are not consulted for pmtu, IP fragmentation wil=
l
>> not be done properly for these routes.
>>=20
>> It also seems that we really need to have the PMTU information alway=
s
>> for netfilter TCPMSS clamp-to-pmtu feature to work properly.
>>=20
>> So for the time being, cache separate copies of input routes for
>> each next hop exception.
>>=20
>> Signed-off-by: Timo Ter=E4s <timo.teras@iki.fi>
>=20
> 	Looks good to me
>=20
> Reviewed-by: Julian Anastasov <ja@ssi.bg>

Applied to net-next, thanks everyone.
