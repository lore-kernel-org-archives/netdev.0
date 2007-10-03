From: Pekka Pietikainen <pp@ee.oulu.fi>
Subject: Re: tcp bw in 2.6
Date: Thu, 4 Oct 2007 00:50:35 +0300
Message-ID: <20071003215034.GA15468@ee.oulu.fi>
References: <E1IcfN0-0007tt-00@gondolin.me.apana.org.au> <20071002150935.GC17418@bitmover.com> <alpine.LFD.0.999.0710021146580.3579@woody.linux-foundation.org> <20071002.133322.52193802.davem@davemloft.net> <20071002212132.GF29944@bitmover.com> <20071003211321.GA13583@ee.oulu.fi> <20071003212358.GF6183@bitmover.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
To: lm@bitmover.com, David Miller <davem@davemloft.net>,
	torvalds@linux-foundation.org, herbert@gondor.apana.org.au,
	wscott@bitmover.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ee.oulu.fi ([130.231.61.23]:34493 "EHLO ee.oulu.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753796AbXJCVu5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Oct 2007 17:50:57 -0400
Content-Disposition: inline
In-Reply-To: <20071003212358.GF6183@bitmover.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 03, 2007 at 02:23:58PM -0700, Larry McVoy wrote:
> > A few notes to the discussion. I've seen one e1000 "bug" that ended up being
> > a crappy AMD pre-opteron SMP chipset with a totally useless PCI bus
> > implementation, which limited performance quite a bit-totally depending on
> > what you plugged in and in which slot. 10e milk-and-bread-store 
> > 32/33 gige nics actually were better than server-class e1000's 
> > in those, but weren't that great either.
> 
> That could well be my problem, this is a dual processor (not core) athlon
> (not opteron) tyan motherboard if I recall correctly.
If it's AMD760/768MPX, here's some relevant discussion:

http://lkml.org/lkml/2002/7/18/292                                              
http://www.ussg.iu.edu/hypermail/linux/kernel/0307.1/1109.html                  
http://www.ussg.iu.edu/hypermail/linux/kernel/0307.1/1154.html                  
http://www.ussg.iu.edu/hypermail/linux/kernel/0307.1/1212.html 
http://forums.2cpu.com/showthread.php?s=&threadid=31211

> 
> > Check your interrupt rates for the interface. You shouldn't be getting
> > anywhere near 1 interrupt/packet. If you are, something is badly wrong :).
> 
> The acks (because I'm sending) are about 1.5 packets/interrupt.
> When this box is receiving it's moving about 3x ass much data
> and has a _lower_ (absolute, not per packet) interrupt load.
Probably not a problem then, since those acks probably cover many 
sent packets. Current interrupt mitigation schemes are pretty 
dynamic, balancing between latency and bulk performance so the acks
might be fine (thousands vs. tens of thousands/sec)

-- 
Pekka Pietikainen
