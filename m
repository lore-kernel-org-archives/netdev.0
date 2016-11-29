From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: Re: [PATCH v2 net-next 10/11] qede: Add basic XDP support
Date: Tue, 29 Nov 2016 17:51:31 +0000
Message-ID: <BL2PR07MB23061A22119C747AA7E9A2FA8D8D0@BL2PR07MB2306.namprd07.prod.outlook.com>
References: <1480430830-17671-1-git-send-email-Yuval.Mintz@cavium.com>
        <1480430830-17671-11-git-send-email-Yuval.Mintz@cavium.com>
        <583DA362.7010702@iogearbox.net>,<20161129171020.6b8b552d@jkicinski-Precision-T1700>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "alexei.starovoitov@gmail.com" <alexei.starovoitov@gmail.com>
To: Jakub Kicinski <kubakici@wp.pl>,
        Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn3nam01on0075.outbound.protection.outlook.com ([104.47.33.75]:18560
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1756330AbcK2Rve (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 29 Nov 2016 12:51:34 -0500
In-Reply-To: <20161129171020.6b8b552d@jkicinski-Precision-T1700>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > You also need to wrap this under rcu_read_lock() (at least I haven't se=
en
> > it in your patches) for same reasons as stated in 326fe02d1ed6 ("net/ml=
x4_en:
> > protect ring->xdp_prog with rcu_read_lock"), as otherwise xdp_prog coul=
d
> > disappear underneath you. mlx4 and nfp does it correctly, looks like ml=
x5
> > doesn't.

> My understanding was that Yuval is always doing full stop()/start() so
> there should be no RX packets in flight while the XDP prog is being
> changed.=A0 But thinking about it again, perhaps is worth adding the
> optimization to forego the full qede_reload() in qede_xdp_set() if there
> is a program already loaded and just do the xchg()+put() (and add RCU
> protection on the fast path)?

Yeps. That the current state of the code.
I'll surely pursue this later, but I don't think all this added complexity
is required for the initial submission.

BTW, one of the problems [or perhaps 'lack of motivation' is a better term]
I had with the program switching scenario was that there was no sample
application that did it.
If it's really an interesting [basic] scenario, perhaps it's worthy to add
a sample user app. that will repeatedly switch the attached eBPF?=
