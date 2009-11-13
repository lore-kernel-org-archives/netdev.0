From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: large packet loss take2 2.6.31.x
Date: Fri, 13 Nov 2009 22:16:40 +0100
Message-ID: <20091113211640.GA2540@ami.dom.local>
References: <81bfc67a0911111448q2e7938fcq18adf2454d6bc8f1@mail.gmail.com>
 <20091112113836.GA7963@ff.dom.local>
 <81bfc67a0911120546g26627ac5q5860d85f446b29bb@mail.gmail.com>
 <4AFC5C58.9030207@gmail.com>
 <81bfc67a0911130825o6d9b93b2he70677157ad889f2@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Frans Pop <elendil@planet.nl>, Andi Kleen <andi@firstfloor.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Caleb Cushing <xenoterracide@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f221.google.com ([209.85.220.221]:60140 "EHLO
	mail-fx0-f221.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932236AbZKMVQn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Nov 2009 16:16:43 -0500
Content-Disposition: inline
In-Reply-To: <81bfc67a0911130825o6d9b93b2he70677157ad889f2@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 13, 2009 at 11:25:25AM -0500, Caleb Cushing wrote:
> > So I assume it's your only network device on this box and according
> > to these reports it's 192.168.1.3 with 192.168.1.1 as the gateway,
> > and your only change is kernel on this 192.168.1.3 box, right?
> 
> yes, and semi obviously that router is my box (LinkSys wrt 54gl
> openwrt kamikaze 8.09.1.
> 
> > Since the loss is seen on the first hop already, it seems it should be
> > enough to query 192.168.1.1 only - did you try this? If so, does this
> > happen from the beginning of the test or after many loops? Could you
> > try to repeat this wireshark dump with more data than before (but just
> > to be sure there are a few unanswered pings). If possible it would be
> > nice to have wireshark or tcpdump data from 192.168.1.1 too, while
> > pinged from 192.168.1.3. Please, send it gzipped to bugzilla only plus
> > ifconfig eth0 before and after the test (and let us know here).
> 
> same bug? or new bug? I can see what I can do to get a tcpdump from
> the router.  yes I tried that, I can tell within the first 10 pings. I
> should say I don't notice it on every kernel boot, it's ~80% of
> reboots (but that's pulled from my behind). but I haven't noticed it
> on gfa31221 at all. it's reproducible in 31.6 too (arch just added
> that).

Might be the same bugzilla report, I guess. We need to establish if
these pings reach 192.168.1.1, so a short test and tcpdump without any
special options just to get a few lost cases as seen on both sides.
(And ifconfigs before and after the test.)

Btw, could you check with lsmod if usbserial module is loaded before
this test? I'd like to verify this git bisection result. (If the
module is loaded or you have CONFIG_USB_SERIAL=y instead of m, try to
recompile the kernel with this option turned off, for this test.)

Thanks,
Jarek P.
