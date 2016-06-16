From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH v2 net] gre: fix error handler
Date: Thu, 16 Jun 2016 09:40:58 +0200
Message-ID: <20160616094059.6ce42eb6@griffin>
References: <1465967701.7945.200.camel@edumazet-glaptop3.roam.corp.google.com>
	<1465969537.7945.201.camel@edumazet-glaptop3.roam.corp.google.com>
	<1465997040.7945.207.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Tom Herbert <tom@herbertland.com>,
	Maciej =?UTF-8?B?xbtlbmN6eWtvd3NraQ==?= <maze@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57080 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751252AbcFPHlD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2016 03:41:03 -0400
In-Reply-To: <1465997040.7945.207.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 15 Jun 2016 06:24:00 -0700, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
>=20
> 1) gre_parse_header() can be called from gre_err()
>=20
>    At this point transport header points to ICMP header, not the inne=
r
> header.
>=20
> 2) We can not really change transport header as ipgre_err() will late=
r
> assume transport header still points to ICMP header (using icmp_hdr()=
)
>=20
> 3) pskb_may_pull() logic in gre_parse_header() really works
>   if we are interested at zone pointed by skb->data
>=20
> 4) As Jiri explained in commit b7f8fe251e46 ("gre: do not pull header=
 in
> ICMP error processing") we should not pull headers in error handler.
>=20
> So this fix :
>=20
> A) changes gre_parse_header() to use skb->data instead of
> skb_transport_header()
>=20
> B) Adds a nhs parameter to gre_parse_header() so that we can skip the
> not pulled IP header from error path.
>   This offset is 0 for normal receive path.
>=20
> C) remove obsolete IPV6 includes
>=20
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Tom Herbert <tom@herbertland.com>
> Cc: Maciej =C5=BBenczykowski <maze@google.com>
> Cc: Jiri Benc <jbenc@redhat.com>

Reviewed-by: Jiri Benc <jbenc@redhat.com>

I know this has already been applied. Didn't get to it earlier, sorry.
The patch looks good. Thanks!

 Jiri
