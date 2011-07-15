From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 07/10] net: remove NETIF_F_NO_CSUM feature
Date: Thu, 14 Jul 2011 17:05:06 -0700 (PDT)
Message-ID: <20110714.170506.1425372007221475085.davem@davemloft.net>
References: <20110714205623.GD16759@rere.qmqm.pl>
	<20110714.143121.1603730405553208694.davem@davemloft.net>
	<20110714224445.GA18237@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: therbert@google.com, bhutchings@solarflare.com,
	netdev@vger.kernel.org
To: mirq-linux@rere.qmqm.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:56892 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932359Ab1GOAGQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jul 2011 20:06:16 -0400
In-Reply-To: <20110714224445.GA18237@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>
Date: Fri, 15 Jul 2011 00:44:45 +0200

> On Thu, Jul 14, 2011 at 02:31:21PM -0700, David Miller wrote:
>> From: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>
>> Date: Thu, 14 Jul 2011 22:56:23 +0200
>> > That's why its turned off by default and should be enabled only wh=
en user
>> > knows he will win some pps with it.
>> More people are going to lose than win by your change.
>>=20
>> The nocopy feature helps more real situations than it hurts, the
>> existing default is the best.
>=20
> I see. I still want to remove NO_CSUM (as I explained in other mail),
> so would you accept replacing it with something more specific to
> nocache-copy feature? READS_DATA maybe? That could be later added to
> sk_route_caps whenever it's known for a route there will be need to
> read packets' data.

I don't actually see what the problem is.

The code wants to conditionalize the nocache-copy feature based upon
whether hardware will checksum the packet or not.

And that's exactly what it's testing.

The reason, of course, is because it doesn't want to enable
nocache-copy if the cpu is just going to read the data back into it's
caches during the checksum.  But that's no reason to change the
flag name to have the word "read" instead of "checksum" in it.

