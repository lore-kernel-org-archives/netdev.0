From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] [PATCH] Fix deadlock in af_packet while stressing raw
 ethernet socket interface
Date: Tue, 12 Jul 2011 10:23:06 +0200
Message-ID: <1310458986.4763.4.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <20110711.202717.1764669415135298036.davem@davemloft.net>
	 <CAMJ=MEf8KkNNSvHy-pepg_GfkrnquKo+zW3GyB7RDAYO2H+SVA@mail.gmail.com>
	 <1310453928.2860.32.camel@edumazet-laptop>
	 <20110712.001953.709404117315345178.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ronny.meeus@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:37829 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751259Ab1GLIXS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jul 2011 04:23:18 -0400
Received: by wwe5 with SMTP id 5so4685985wwe.1
        for <netdev@vger.kernel.org>; Tue, 12 Jul 2011 01:23:17 -0700 (PDT)
In-Reply-To: <20110712.001953.709404117315345178.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 12 juillet 2011 =C3=A0 00:19 -0700, David Miller a =C3=A9crit =
:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Tue, 12 Jul 2011 08:58:48 +0200
>=20
> > This seems a bug, but in softirq handling in your arch
>=20
> That's not the problem, it's the dev_queue_xmit_nit() code
> path that interrupt is interrupting.

Isnt it what I said ?

Unless I am mistaken, dev_queue_xmit_nit() is called from
dev_hard_start_xmit(), and from dev_queue_xmit(), therefore BH
are/should_be masked. Calling do_softirq() while BH are masked is the
bug.

Something must be messing the !in_interrupt() test done from irq_exit()



