From: Caleb Cushing <xenoterracide@gmail.com>
Subject: Re: large packet loss take2 2.6.31.x
Date: Wed, 18 Nov 2009 04:59:03 -0500
Message-ID: <81bfc67a0911180159g45a45675k44ce3f251c6bddea@mail.gmail.com>
References: <81bfc67a0911111448q2e7938fcq18adf2454d6bc8f1@mail.gmail.com>
	 <20091112113836.GA7963@ff.dom.local>
	 <81bfc67a0911120546g26627ac5q5860d85f446b29bb@mail.gmail.com>
	 <4AFC5C58.9030207@gmail.com>
	 <81bfc67a0911130825o6d9b93b2he70677157ad889f2@mail.gmail.com>
	 <20091113211640.GA2540@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Frans Pop <elendil@planet.nl>, Andi Kleen <andi@firstfloor.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756862AbZKRJ7A@vger.kernel.org>
In-Reply-To: <20091113211640.GA2540@ami.dom.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Might be the same bugzilla report, I guess. We need to establish if
> these pings reach 192.168.1.1, so a short test and tcpdump without any
> special options just to get a few lost cases as seen on both sides.
> (And ifconfigs before and after the test.)
>
> Btw, could you check with lsmod if usbserial module is loaded before
> this test? I'd like to verify this git bisection result. (If the
> module is loaded or you have CONFIG_USB_SERIAL=y instead of m, try to
> recompile the kernel with this option turned off, for this test.)

sorry for taking so long to get back. busy problematic times.

the dumps and ifconfigs are a bit less 'clean' because the router
serves several other computers (none of which have this issue
(windows)) here's the ifconfig -a from the router.

usbserial is not loaded. actually from reading the patch submission I
suspected the official cause might be off... but I'm not kernel
programmer all I know is where I could see the loss during tests.and I
haven't been able to reproduce over dozens of reboots from this
2.6.31.1-test-00091-gfa31221 kernel.

I totally forgot to do it during the dump's so I hope these are still useful

I haven't rebooted this in a few weeks (the router)

br-lan    Link encap:Ethernet  HWaddr 00:1D:7E:F8:21:66
          inet addr:192.168.1.1  Bcast:192.168.1.255  Mask:255.255.255.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:60613991 errors:0 dropped:0 overruns:0 frame:0
          TX packets:67849334 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:2172912561 (2.0 GiB)  TX bytes:3999263405 (3.7 GiB)

eth0      Link encap:Ethernet  HWaddr 00:1D:7E:F8:21:66
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:144116625 errors:0 dropped:0 overruns:0 frame:0
          TX packets:122639966 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:1986512923 (1.8 GiB)  TX bytes:1548485891 (1.4 GiB)
          Interrupt:4

eth0.0    Link encap:Ethernet  HWaddr 00:1D:7E:F8:21:66
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:57318567 errors:0 dropped:0 overruns:0 frame:0
          TX packets:62317675 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:3466538358 (3.2 GiB)  TX bytes:2132301174 (1.9 GiB)

eth0.1    Link encap:Ethernet  HWaddr 00:1D:7E:F8:21:66
          inet addr:68.42.198.183  Bcast:255.255.255.255  Mask:255.255.255.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:86777655 errors:0 dropped:0 overruns:0 frame:0
          TX packets:60312064 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:205005516 (195.5 MiB)  TX bytes:3162930981 (2.9 GiB)

lo        Link encap:Local Loopback
          inet addr:127.0.0.1  Mask:255.0.0.0
          UP LOOPBACK RUNNING  MTU:16436  Metric:1
          RX packets:168 errors:0 dropped:0 overruns:0 frame:0
          TX packets:168 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:19706 (19.2 KiB)  TX bytes:19706 (19.2 KiB)

wl0       Link encap:Ethernet  HWaddr 00:1D:7E:F8:21:68
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:5114480 errors:0 dropped:0 overruns:0 frame:720205
          TX packets:7576790 errors:1902 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:762579947 (727.2 MiB)  TX bytes:3981402458 (3.7 GiB)
          Interrupt:2 Base address:0x5000

this is the ifconfig -a from my desktop while experiencing the issue

eth0      Link encap:Ethernet  HWaddr 00:21:9B:06:4C:C9
          inet addr:192.168.1.3  Bcast:192.168.1.255  Mask:255.255.255.0
          inet6 addr: fe80::221:9bff:fe06:4cc9/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:3465 errors:0 dropped:0 overruns:0 frame:0
          TX packets:4951 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:100
          RX bytes:1467320 (1.3 Mb)  TX bytes:631808 (617.0 Kb)
          Memory:fdfc0000-fdfe0000

lo        Link encap:Local Loopback
          inet addr:127.0.0.1  Mask:255.0.0.0
          inet6 addr: ::1/128 Scope:Host
          UP LOOPBACK RUNNING  MTU:16436  Metric:1
          RX packets:624 errors:0 dropped:0 overruns:0 frame:0
          TX packets:624 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:64397 (62.8 Kb)  TX bytes:64397 (62.8 Kb)


-- 
Caleb Cushing

http://xenoterracide.blogspot.com
