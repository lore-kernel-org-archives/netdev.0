From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3 01/10] dql: Dynamic queue limits
Date: Wed, 23 Nov 2011 16:05:50 +0100
Message-ID: <1322060750.17693.42.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <alpine.DEB.2.00.1111222138280.13686@pokey.mtv.corp.google.com>
	 <1322060288.17693.37.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f53.google.com ([209.85.216.53]:45808 "EHLO
	mail-qw0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753168Ab1KWPFx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2011 10:05:53 -0500
Received: by qadb14 with SMTP id b14so1534860qad.19
        for <netdev@vger.kernel.org>; Wed, 23 Nov 2011 07:05:53 -0800 (PST)
In-Reply-To: <1322060288.17693.37.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 23 novembre 2011 =C3=A0 15:58 +0100, Eric Dumazet a =C3=A9c=
rit :

> Another question is : Is DQL planned to work on 32bit arch ?
>=20
> A fast interface can probably send more than 2^32 bytes for large
> slack_hold_time values, and wrap around.
>=20
> If yes : We can use "unsigned int" instead of "unsigned long" to lowe=
r
> memory need on 64bit arch.
>=20
> If no, "unsigned long" type is not enough on 32bit, or we need to lim=
it
> slack_hold_time to small intervals...
>=20
>=20

Hmm, reading again the code, 32bit counters should be more than enough,
instead of "unsigned long", on all arches.

unsigned long is only needed for slack_start_time  (to store jiffies)

This would lower sizeof( struct dql) to 48 or 56 bytes.
