From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bonding: reset queue mapping prior to transmission to
 physical device
Date: Thu, 02 Jun 2011 14:10:11 -0700 (PDT)
Message-ID: <20110602.141011.1327782241631020755.davem@davemloft.net>
References: <4DE7EF05.8030505@gmail.com>
	<20110602.134637.1101638217263464114.davem@davemloft.net>
	<1307047906.2812.61.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: nicolas.2p.debian@gmail.com, nhorman@tuxdriver.com,
	netdev@vger.kernel.org, fubar@us.ibm.com, andy@greyhouse.net
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44909 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752080Ab1FBVLY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jun 2011 17:11:24 -0400
In-Reply-To: <1307047906.2812.61.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Ben Hutchings <bhutchings@solarflare.com>
Date: Thu, 02 Jun 2011 21:51:46 +0100

> On Thu, 2011-06-02 at 13:46 -0700, David Miller wrote:
>> From: Nicolas de Peslo=FCan <nicolas.2p.debian@gmail.com>
>> Date: Thu, 02 Jun 2011 22:13:57 +0200
>>=20
>> > To be more precise, due to the way bonding use queue mapping for s=
lave
>> > selection, it is desirable to clear the mapping before sending to =
the
>> > slave, because the meaning of the mapping for the slave interface
>> > might be really different from the meaning for the bonding
>> > interface. Arguably, this is the mapping usage in bonding which is
>> > "different" from other usages, but...
>>=20
>> This just confirms my reasoning behind why I wanted to discourage
>> drivers from providing explicit ->ndo_select_queue() methods unless
>> absolutely necessary.
>>=20
>> Information now gets lost in cases like this bonding issue.
>>=20
>> Bonding should definitely, as I suggested, remember the original
>> rxhash value and restore it when sending to the slave.
>=20
> Surely RX queue (queue_mapping), not RX hash (rxhash, which is unchan=
ged
> anyway AFAIK).

Right.
