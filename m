From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: SO_REUSEPORT - can it be done in kernel?
Date: Tue, 01 Mar 2011 15:52:40 +0100
Message-ID: <1298991160.3284.108.camel@edumazet-laptop>
References: <1298975602.3284.13.camel@edumazet-laptop>
	 <20110301110708.GJ9763@canuck.infradead.org>
	 <1298977984.3284.15.camel@edumazet-laptop>
	 <20110301112759.GK9763@canuck.infradead.org>
	 <1298979909.3284.28.camel@edumazet-laptop>
	 <20110301121829.GM9763@canuck.infradead.org>
	 <20110301121951.GA7267@gondor.apana.org.au>
	 <20110301135053.GA6684@canuck.infradead.org>
	 <1298988419.3284.107.camel@edumazet-laptop>
	 <20110301142235.GA10761@canuck.infradead.org>
	 <20110301143050.GB10761@canuck.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>, rick.jones2@hp.com,
	therbert@google.com, wsommerfeld@google.com,
	daniel.baluta@gmail.com, netdev@vger.kernel.org
To: Thomas Graf <tgraf@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:41168 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754390Ab1CAOwq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2011 09:52:46 -0500
Received: by fxm17 with SMTP id 17so4873296fxm.19
        for <netdev@vger.kernel.org>; Tue, 01 Mar 2011 06:52:45 -0800 (PST)
In-Reply-To: <20110301143050.GB10761@canuck.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 01 mars 2011 =C3=A0 09:30 -0500, Thomas Graf a =C3=A9crit :
> On Tue, Mar 01, 2011 at 09:22:35AM -0500, Thomas Graf wrote:
> > On Tue, Mar 01, 2011 at 03:06:59PM +0100, Eric Dumazet wrote:
> > > Would be nice to cpu affine named to _not_ run on CPU11, just to
> > > specialize it for TX completions and have softirq time percentage=
 and
> > > "perf top -C 11 " results
>=20
> CPU 1 isolated as well (named running with mask 0,2-10)
>=20
> ---------------------------------------------------------------------=
-------------------------------------------------
>    PerfTop:     580 irqs/sec  kernel:100.0%  exact:  0.0% [1000Hz cpu=
-clock-msecs],  (all, CPU: 1)
> ---------------------------------------------------------------------=
-------------------------------------------------
>=20
>              samples  pcnt function                    DSO
>              _______ _____ ___________________________ ______________=
_____________________________________________
>=20
>               283.00  9.2% get_rx_page_info            /lib/modules/2=
=2E6.38-rc5+/kernel/drivers/net/benet/be2net.ko
>               256.00  8.4% _raw_spin_unlock_irqrestore /lib/modules/2=
=2E6.38-rc5+/build/vmlinux                    =20
>               190.00  6.2% be_poll_rx                  /lib/modules/2=
=2E6.38-rc5+/kernel/drivers/net/benet/be2net.ko
>               182.00  5.9% get_page_from_freelist      /lib/modules/2=
=2E6.38-rc5+/build/vmlinux                    =20
>               157.00  5.1% intel_idle                  /lib/modules/2=
=2E6.38-rc5+/build/vmlinux                    =20
>               143.00  4.7% __do_softirq                /lib/modules/2=
=2E6.38-rc5+/build/vmlinux                    =20
>               133.00  4.3% sock_queue_rcv_skb          /lib/modules/2=
=2E6.38-rc5+/build/vmlinux                    =20
>               133.00  4.3% __udp4_lib_lookup           /lib/modules/2=
=2E6.38-rc5+/build/vmlinux                    =20
>               131.00  4.3% sk_run_filter               /lib/modules/2=
=2E6.38-rc5+/build/vmlinux  =20

sk_run_filter ? Do you have a packet filter running ?


