From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] net/ipv4: push IP options to CB in
 ip_fragment
Date: Tue, 31 Aug 2010 15:13:29 +0200
Message-ID: <1283260409.2550.87.camel@edumazet-laptop>
References: <20100830200917.GA10754@stratus.com>
	 <1283204118.2405.32.camel@edumazet-laptop>
	 <20100830232147.GB10754@stratus.com>
	 <1283232031.2405.38.camel@edumazet-laptop>
	 <20100831082444.GB29281@gondor.apana.org.au>
	 <1283246271.2550.35.camel@edumazet-laptop>
	 <20100831123641.GA31017@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Bandan Das <bandan.das@stratus.com>,
	David Miller <davem@davemloft.net>,
	NetDev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:60293 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757338Ab0HaNNf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Aug 2010 09:13:35 -0400
In-Reply-To: <20100831123641.GA31017@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 31 ao=C3=BBt 2010 =C3=A0 20:36 +0800, Herbert Xu a =C3=A9crit =
:
> On Tue, Aug 31, 2010 at 11:17:51AM +0200, Eric Dumazet wrote:
> >
> > Once again, the IP stack -> bridge -> IP stack flow bites us,
> > because bridge likes to dirty IPCB.
>=20
> OK, so we're talking about a locally transmitted packet, with
> IP options leaving the IP stack, entering bridging, and then
> reentering the IP stack?
>=20
> In that case the packet should no longer be treated as an IP
> packet when it enters the bridge.  So if it did have options
> and we want to support that in bridging then we need to parse
> IP options there as my comment suggested.

Bandan did not provide a full stack trace,
but I believe the problem was :

br_nf_dev_queue_xmit() -> ip_fragment -> icmp_send() ->
ip_options_echo() : crash, because ip_options_echo take bridge CB as
IPCB data.

http://www.spinics.net/lists/netdev/msg139370.html




