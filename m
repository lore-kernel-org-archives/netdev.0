From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [PATCH] Fix deadlock in af_packet while stressing raw
 ethernet socket interface
Date: Tue, 12 Jul 2011 01:26:55 -0700 (PDT)
Message-ID: <20110712.012655.1526748393425458264.davem@davemloft.net>
References: <1310453928.2860.32.camel@edumazet-laptop>
	<20110712.001953.709404117315345178.davem@davemloft.net>
	<1310458986.4763.4.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ronny.meeus@gmail.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:34419 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750813Ab1GLI07 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jul 2011 04:26:59 -0400
In-Reply-To: <1310458986.4763.4.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 12 Jul 2011 10:23:06 +0200

> Le mardi 12 juillet 2011 =E0 00:19 -0700, David Miller a =E9crit :
>> From: Eric Dumazet <eric.dumazet@gmail.com>
>> Date: Tue, 12 Jul 2011 08:58:48 +0200
>>=20
>> > This seems a bug, but in softirq handling in your arch
>>=20
>> That's not the problem, it's the dev_queue_xmit_nit() code
>> path that interrupt is interrupting.
>=20
> Isnt it what I said ?
>=20
> Unless I am mistaken, dev_queue_xmit_nit() is called from
> dev_hard_start_xmit(), and from dev_queue_xmit(), therefore BH
> are/should_be masked. Calling do_softirq() while BH are masked is the
> bug.
>=20
> Something must be messing the !in_interrupt() test done from irq_exit=
()

Aha, I see.  Yes, this seems to be where the problem are.
