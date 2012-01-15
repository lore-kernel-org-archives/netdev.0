From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Why the number of /proc/interrupts doesn't change when nic is
 under heavy workload?
Date: Mon, 16 Jan 2012 00:10:30 +0100
Message-ID: <1326669030.5287.112.camel@edumazet-laptop>
References: <CAEc1PS0doeaH59621ia7n2GT=WgRSsCit_EzGrCV93QH95XZqw@mail.gmail.com>
	 <1326665367.5287.97.camel@edumazet-laptop>
	 <CAEc1PS0QxYfHfLFTiSFdTX27ufuxVfJd6Vg5oyv5aip5r=tD4A@mail.gmail.com>
	 <CAEc1PS1gpA6p0Nb11bCkmi6q6e-yxN=63R1duPvimOFnjC9kLQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	yhxu@wayne.edu
To: Yuehai Xu <yuehaixu@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAEc1PS1gpA6p0Nb11bCkmi6q6e-yxN=63R1duPvimOFnjC9kLQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le dimanche 15 janvier 2012 =C3=A0 17:45 -0500, Yuehai Xu a =C3=A9crit =
:

>  However, this also means there is a certain core
> needs to handle all softirqs, simply because my smp_affinity of irq
> doesn't work here.

You miss something here. You really should not ask to distribute
hardware irqs on all cores. This is in conflict with RPS, but also with
cache efficiency.

And anyway, if load is high enough, only one core is calling nic poll()
from its NAPI handler.

One cpu handles the nic poll(), and thanks to RPS distributes packets t=
o
other cpus so that they handle (in their softirq handler) the IP stack,
plus the TCP/UDP stack.

>  Even RPS can alleviate some softirqs to other
> cores, it doesn't solve the problem 100%.

Problem is we dont know yet what is 'the problem', as you gave litle
info.

(You didnt tell us if your memcached was using TCP or UDP transport)

If your workload consists of many short lived tcp connections , RPS won=
t
help that much because the three way handshake needs to hold the
listener lock.
