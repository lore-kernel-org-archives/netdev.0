From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Generic rx-recycling and emergency skb pool
Date: Sat, 03 Jul 2010 09:31:00 +0200
Message-ID: <1278142260.2474.76.camel@edumazet-laptop>
References: <1278098421-21296-1-git-send-email-sebastian@breakpoint.cc>
	 <1278138205.2474.27.camel@edumazet-laptop>
	 <20100702.234645.104076220.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: sebastian@breakpoint.cc, netdev@vger.kernel.org, tglx@linutronix.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:53892 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753417Ab0GCHbF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Jul 2010 03:31:05 -0400
Received: by wwb24 with SMTP id 24so778131wwb.1
        for <netdev@vger.kernel.org>; Sat, 03 Jul 2010 00:31:03 -0700 (PDT)
In-Reply-To: <20100702.234645.104076220.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 02 juillet 2010 =C3=A0 23:46 -0700, David Miller a =C3=A9cr=
it :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Sat, 03 Jul 2010 08:23:25 +0200
>=20
> > Maybe its time to provide new API, so that a driver can build an sk=
b at
> > the time RX interrupt is handled, not at the time the rx ring buffe=
r is
> > renewed. RX ring should only provide the data part to NIC, and skb
> > should be built when NIC delivers the frame, so that we provide to =
IP
> > stack a real hot skb.
>=20
> Drivers do this already, and in fact I am very sure I'm mentioned thi=
s
> to you at least other time in the past, and one such driver is NIU :-=
)

You did indeed. I should said "provide a generic and universal API",
usable by average NIC driver, not only big ones. (NIU is more than
10.000 lines of code ;) )

NIU still uses netdev_alloc_skb() API. I was thinking of a function to
allocate and populate the sk_buff, but data part provided by caller.

>=20
> It's trivial to do with devices which work on power-of-2 chopped up
> pages.  In fact I'm surprised that RX buffer management scheme is
> not more prevalent in network devices.

Many of them were written in last century :)



