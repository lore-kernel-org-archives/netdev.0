From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] macvlan: lockless tx path
Date: Wed, 10 Nov 2010 21:33:07 +0100
Message-ID: <1289421187.2469.127.camel@edumazet-laptop>
References: <1289403709.2860.216.camel@edumazet-laptop>
	 <4CDAD8C8.20807@candelatech.com>
	 <1289411027.2860.248.camel@edumazet-laptop>
	 <4CDADC17.6070506@candelatech.com>
	 <1289413120.2469.12.camel@edumazet-laptop>
	 <4CDAE713.7020309@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	netdev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:63433 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755379Ab0KJUdM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Nov 2010 15:33:12 -0500
Received: by wyb36 with SMTP id 36so1100152wyb.19
        for <netdev@vger.kernel.org>; Wed, 10 Nov 2010 12:33:11 -0800 (PST)
In-Reply-To: <4CDAE713.7020309@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 10 novembre 2010 =C3=A0 10:40 -0800, Ben Greear a =C3=A9cri=
t :

> In my opinion, the kernel and/or driver should deal with this such th=
at
> at worst the user has to deal with 32 v/s 64 bits based on whether th=
e
> kernel is compiled for 32 or 64 bit CPUs.  (Let the driver sample at
> intervals needed to never wrap it's counters more than once and updat=
e
> software stats of well-defined bit-width, and present those software
> counters to users.
>=20

How so ? Are you willing to provide patches for all network drivers ?

> In practice, this seems to be the case, at least for the NICs I've us=
ed
> (mostly Intel).  But, please don't propagate the idea that any width =
of
> counters is OK to present to user-space:  It is completely unfair to
> make app writers have to know the network driver and/or hardware quir=
ks to
> know how often it must sample stats.
>=20

I am sorry Ben, but /proc/net/dev doesnt publish each counter effective
width. Its unfair, but its like that.

An appplication must be able to cope for wrap arounds, running on a 32
or 64bit kernel. Our duty is to provide 64bit counters for high speed
interfaces where possible.
=46or a 10Mb adapter, there is no need, since a 32bit counter doesnt wr=
ap
in less than one hour (RFC1902 suggestion)

As I said, many drivers counters are not 32bit or 64bit. I did many
driver get_stats() checks lately...

Why should we cap them to 32bit if they really are 36 or 40 bits ?=20


> Well, maybe using u32 would have positive benefits on 64-bit kernels =
then?
>=20

But we want to handle 40/100Gbps devices, and keep SNMP apps happy.

We really need 64bit for them, and MACVLAN might be used on top of such
devices.

Or are you suggesting using u32 instead of "unsigned long" for
rx_errors/tx_dropped ?

This would indeed save 8 bytes per cpu per macvlan.



