From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] macvlan: lockless tx path
Date: Thu, 11 Nov 2010 00:36:24 +0100
Message-ID: <1289432184.17691.141.camel@edumazet-laptop>
References: <1289403709.2860.216.camel@edumazet-laptop>
	 <4CDAD8C8.20807@candelatech.com>
	 <1289411027.2860.248.camel@edumazet-laptop>
	 <4CDADC17.6070506@candelatech.com>
	 <1289413120.2469.12.camel@edumazet-laptop>
	 <4CDAE713.7020309@candelatech.com>
	 <1289421187.2469.127.camel@edumazet-laptop> <4CDB1021.507@candelatech.com>
	 <1289427705.17691.52.camel@edumazet-laptop>
	 <4CDB226A.8080903@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:49982 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757268Ab0KJXg2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Nov 2010 18:36:28 -0500
Received: by wyb36 with SMTP id 36so1269064wyb.19
        for <netdev@vger.kernel.org>; Wed, 10 Nov 2010 15:36:26 -0800 (PST)
In-Reply-To: <4CDB226A.8080903@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 10 novembre 2010 =C3=A0 14:53 -0800, Ben Greear a =C3=A9cri=
t :

> I did similar, and then wrote extra code to detect a 64-bit kernel an=
d if
> so assume that the counters wrap at 64 bits so I didn't have to poll =
so
> often to make sure I didn't miss a wrap for a 10G NIC.  If instead on=
e wraps at 33
> bits and the other at 36, there is no way for me to deal with the wra=
p
> properly w/out explicitly knowing about that 33 and 36.
>=20

How do you define 'wrap around' ? Maybe your definition is wrong.

> If the old 32-bit counters in /proc/net/dev instead had a driver that
> managed to wrap them at 28 bits, I can't see how your application cou=
ld
> have worked properly, so you must have been assuming that the kernel =
would
> always return a full 32-bit counter.

I suggest you take a look at various SNMP applications that handle this
just fine. RRD for example. You can patch your favorite driver to cap
the stats to 37, 38, ... 31 or 30 bits, it works.

If you sample values faster than half the period, it works.

This has nothing to do with 32 or 64 bits, really.

Read RFC1230 for a good advice


	All the statistics are defined using the
        syntax Counter as 32 bit wrap around
        counters.  Thus, if an interface's
        hardware chip set maintains these
        statistics in 16-bit counters, then the
        agent must read the hardware's counters
        frequently enough to prevent loss of
        significance, in order to maintain
        a 32-bit counter in software."

Yes, 16bit counters _are_ fine, even if provided in a 32bit counter, if
you read value fast enough.



