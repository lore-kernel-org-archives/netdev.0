From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH net-next-2.6] rps: shortcut net_rps_action()
Date: Tue, 20 Apr 2010 08:32:38 +0800
Message-ID: <p2j412e6f7f1004191732p41094214yf82d2755f9081d1d@mail.gmail.com>
References: <t2p65634d661004141031xf80f62e7sb64362ea1ce10a1f@mail.gmail.com>
	<1271590476.16881.4925.camel@edumazet-laptop> <1271669822.16881.7520.camel@edumazet-laptop>
	<k2u412e6f7f1004190248s8ac633beof2475645e799f2ea@mail.gmail.com>
	<1271679244.3845.43.camel@edumazet-laptop> <p2u412e6f7f1004190528l65cc6253w8b7f43f2657b551d@mail.gmail.com>
	<1271683627.3845.44.camel@edumazet-laptop> <1271686957.3845.49.camel@edumazet-laptop>
	<1271689653.3845.73.camel@edumazet-laptop> <n2y412e6f7f1004191656qd53a8d77occ407ac288c53bbc@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:41505 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752454Ab0DTAdB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Apr 2010 20:33:01 -0400
Received: by gyg13 with SMTP id 13so2900699gyg.19
        for <netdev@vger.kernel.org>; Mon, 19 Apr 2010 17:32:59 -0700 (PDT)
In-Reply-To: <n2y412e6f7f1004191656qd53a8d77occ407ac288c53bbc@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 20, 2010 at 7:56 AM, Changli Gao <xiaosuo@gmail.com> wrote:
>
> It seems you prefetch rps_ipi_next. I think it isn't necessary, as th=
e
> list should be short. If you insist on this, is the macro prefetch()
> better?

Oh, I read the code again and got the answer. After the IPI is sent,
this softnet will be queued by the other CPUs. We prefetch the pointer
rps_ipi_next to avoid this race condition.

Sorry for noise :)


--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
