From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: large packet loss take2 2.6.31.x
Date: Wed, 18 Nov 2009 13:51:36 +0000
Message-ID: <20091118135136.GA9224@ff.dom.local>
References: <81bfc67a0911111448q2e7938fcq18adf2454d6bc8f1@mail.gmail.com> <20091112113836.GA7963@ff.dom.local> <81bfc67a0911120546g26627ac5q5860d85f446b29bb@mail.gmail.com> <4AFC5C58.9030207@gmail.com> <81bfc67a0911130825o6d9b93b2he70677157ad889f2@mail.gmail.com> <20091113211640.GA2540@ami.dom.local> <81bfc67a0911180159g45a45675k44ce3f251c6bddea@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Frans Pop <elendil@planet.nl>, Andi Kleen <andi@firstfloor.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Caleb Cushing <xenoterracide@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757119AbZKRNvs@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <81bfc67a0911180159g45a45675k44ce3f251c6bddea@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 18, 2009 at 04:59:03AM -0500, Caleb Cushing wrote:
> > Might be the same bugzilla report, I guess. We need to establish if
> > these pings reach 192.168.1.1, so a short test and tcpdump without any
> > special options just to get a few lost cases as seen on both sides.
> > (And ifconfigs before and after the test.)
> >
> > Btw, could you check with lsmod if usbserial module is loaded before
> > this test? I'd like to verify this git bisection result. (If the
> > module is loaded or you have CONFIG_USB_SERIAL=y instead of m, try to
> > recompile the kernel with this option turned off, for this test.)
> 
> sorry for taking so long to get back. busy problematic times.
No problem, don't hurry.

> 
> the dumps and ifconfigs are a bit less 'clean' because the router
> serves several other computers (none of which have this issue
> (windows)) here's the ifconfig -a from the router.

Actually, I'm a little bit surprised. Maybe I missed something from
your previous messages, but I expected something more similar to the
first wireshark dump, which suggested to me there was only this mtr
traffic. Now there is a lot more (plus we know it's not all).

So, there is a basic question: can this mtr loss be seen while no
other traffic is present? After looking into these current dumps I
doubt. There are e.g. 3 pings unanswered between 09:21:50 and
09:21:52 (21:31:34 to 21:31:38 router time), but a lot of tcp
packets to and from 192.168.1.3, so looks like simply dropped and
we can guess the reason.

> 
> usbserial is not loaded. actually from reading the patch submission I
> suspected the official cause might be off... but I'm not kernel
> programmer all I know is where I could see the loss during tests.and I
> haven't been able to reproduce over dozens of reboots from this
> 2.6.31.1-test-00091-gfa31221 kernel.

Since this patch from the bisection is really limited to this one
module I doubt we should follow this direction. IMHO it shows the
test wasn't reproducible enough. Probably the amount and/or kind of
other traffic really matter. If I'm wrong and missed something again
let me know. Btw, could you try if changing with ifconfig the
txqueuelen of desktop's eth0 from 100 to 1000 changes anything
in this mtr test?

Jarek P.

> this is the ifconfig -a from my desktop while experiencing the issue
> 
> eth0      Link encap:Ethernet  HWaddr 00:21:9B:06:4C:C9
>           inet addr:192.168.1.3  Bcast:192.168.1.255  Mask:255.255.255.0
>           inet6 addr: fe80::221:9bff:fe06:4cc9/64 Scope:Link
>           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
>           RX packets:3465 errors:0 dropped:0 overruns:0 frame:0
>           TX packets:4951 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:0 txqueuelen:100
>           RX bytes:1467320 (1.3 Mb)  TX bytes:631808 (617.0 Kb)
>           Memory:fdfc0000-fdfe0000
