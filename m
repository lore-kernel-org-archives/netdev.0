From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] net_sched: sch_mqprio: dont leak kernel
 memory
Date: Thu, 27 Jan 2011 08:04:03 +0100
Message-ID: <1296111843.1783.130.camel@edumazet-laptop>
References: <1296062517.2899.86.camel@edumazet-laptop>
	 <1296063823.6115.37.camel@Joe-Laptop>
	 <20110126.115530.226756606.davem@davemloft.net>
	 <1296108251.2448.183.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	john.r.fastabend@intel.com
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:55202 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750835Ab1A0HEK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Jan 2011 02:04:10 -0500
Received: by wwa36 with SMTP id 36so1840429wwa.1
        for <netdev@vger.kernel.org>; Wed, 26 Jan 2011 23:04:08 -0800 (PST)
In-Reply-To: <1296108251.2448.183.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 26 janvier 2011 =C3=A0 22:04 -0800, Joe Perches a =C3=A9cri=
t :

> /* MQPRIO */
> #define TC_QOPT_BITMASK 15
> #define TC_QOPT_MAX_QUEUE 16
>=20
> struct tc_mqprio_qopt {
> __u8 num_tc;
> __u8 prio_tc_map[TC_QOPT_BITMASK + 1];
> __u8 hw;
> __u16 count[TC_QOPT_MAX_QUEUE];
> __u16 offset[TC_QOPT_MAX_QUEUE];
> };
>=20
> I believe this struct needs to be declared __packed.
>=20

Oh my god. Yet another ugly thing.

> It could otherwise be 24 bytes not 22.

22 ? You are kidding probably. Its 82 exactly.

Listen, I doubled check my patch, its good, while your rants are lazy.

> Or if char array declarations have a different
> alignment requirement, could be any size.
>=20

If if if... could could could...


> memset is better than {0}.
>=20

You never stop do you ?

The bigger object is u16, therefore alignof() is 2, not 4

No ABI requires a short (u16) is aligned on 4 byte boundary.

If you find a compiler not respecting this, you can bet linux wont run
at all if compiled with it. mqprio 'potential 2 bytes leak' will hardly
be a problem.



