From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [regression, 2.6.37-rc1] 'ip link tap0 up' stuck in do_exit()
Date: Thu, 09 Dec 2010 18:07:54 +0100
Message-ID: <1291914474.4063.68.camel@edumazet-laptop>
References: <20101103062609.GB31163@dastard>
	 <1288768402.2467.665.camel@edumazet-laptop> <20101103103448.GA9169@dastard>
	 <20101103112936.GB9169@dastard> <20101104002140.GA13830@dastard>
	 <20101104054718.GC5210@cr0.nay.redhat.com>
	 <20101208100245.01cf23c5@schatten.dmk.lab>
	 <20101208134116.GA16923@redhat.com> <20101208134712.GB16923@redhat.com>
	 <20101208140822.GA18681@redhat.com>  <20101209164748.GA3218@hack>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Oleg Nesterov <oleg@redhat.com>,
	Florian Mickler <florian@mickler.org>,
	Ingo Molnar <mingo@elte.hu>,
	Dave Chinner <david@fromorbit.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: =?ISO-8859-1?Q?Am=E9rico?= Wang <xiyou.wangcong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101209164748.GA3218@hack>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le vendredi 10 d=C3=A9cembre 2010 =C3=A0 00:47 +0800, Am=C3=A9rico Wang=
 a =C3=A9crit :

> Yeah, there is no point that a zombie can trigger a BUG_ON in kenrel.
> But it is still interesting to know why it becomes a zombie...
>=20

A zombie is very easy to get.

Technically speaking, all processes die and become zombies, unless
parent said : signal(SIGCLD, SIG_IGN) before fork()

The parent is buggy (sudo in this case ?) and doesnt call wait() to
'free' one of its children.
