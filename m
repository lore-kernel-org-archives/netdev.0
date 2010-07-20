From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next-2.6 PATCH 2/5] ixgbe: drop support for UDP in RSS
 hash generation
Date: Tue, 20 Jul 2010 08:30:00 +0200
Message-ID: <1279607400.2458.76.camel@edumazet-laptop>
References: <20100719235831.14112.14175.stgit@localhost.localdomain>
	 <20100719235925.14112.65890.stgit@localhost.localdomain>
	 <20100719.202417.218061462.davem@davemloft.net>
	 <20100720020754.135b5ff7.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	alexander.h.duyck@intel.com, donald.c.skidmore@intel.com
To: Bill Fink <billfink@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:52709 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752234Ab0GTGaG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jul 2010 02:30:06 -0400
Received: by wwj40 with SMTP id 40so369811wwj.1
        for <netdev@vger.kernel.org>; Mon, 19 Jul 2010 23:30:05 -0700 (PDT)
In-Reply-To: <20100720020754.135b5ff7.billfink@mindspring.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 20 juillet 2010 =C3=A0 02:07 -0400, Bill Fink a =C3=A9crit :
> On Mon, 19 Jul 2010, David Miller wrote:
>=20

> Should there be a /proc or ethtool setting for whether or not to
> use RSS hashing for UDP flows?  I would think that for many common
> UDP applications, IP fragmentation would not be an issue because
> they often tend to use sub-MTU sized datagrams.  And of course
> UDP does not guarantee in-order delivery in any event.  Then a
> remaining issue is what the default setting of such an option
> should be.  I would lean to having it enabled by default, but
> I can also see the safety argument for having it off by default.
>=20

Their are several issues here.

1) Ability for the NIC to spread UDP loads on several queues.

2) Ability for the NIC to provide the hash to our stack, to speedup a
bit RPS.


If the patch is about 1), ie disables NIC ability to split UDP flows on
several RX queues, then yes : its probably _not_ wanted.



Commit message is not very clear on this topic.

By nature, UDP flows are subject to out of order issues, so what is thi=
s
patch tries to avoid ?



