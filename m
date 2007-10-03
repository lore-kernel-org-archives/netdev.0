From: Pekka Pietikainen <pp@ee.oulu.fi>
Subject: Re: tcp bw in 2.6
Date: Thu, 4 Oct 2007 00:13:21 +0300
Message-ID: <20071003211321.GA13583@ee.oulu.fi>
References: <E1IcfN0-0007tt-00@gondolin.me.apana.org.au> <20071002150935.GC17418@bitmover.com> <alpine.LFD.0.999.0710021146580.3579@woody.linux-foundation.org> <20071002.133322.52193802.davem@davemloft.net> <20071002212132.GF29944@bitmover.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
To: lm@bitmover.com, David Miller <davem@davemloft.net>,
	torvalds@linux-foundation.org, herbert@gondor.apana.org.au,
	wscott@bitmover.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ee.oulu.fi ([130.231.61.23]:33247 "EHLO ee.oulu.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752981AbXJCVsC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Oct 2007 17:48:02 -0400
Content-Disposition: inline
In-Reply-To: <20071002212132.GF29944@bitmover.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 02, 2007 at 02:21:32PM -0700, Larry McVoy wrote:
> More data, sky2 works fine (really really fine, like 79MB/sec) between
> Linux dylan.bitmover.com 2.6.18.1 #5 SMP Mon Oct 23 17:36:00 PDT 2006 i686
> Linux steele 2.6.20-16-generic #2 SMP Sun Sep 23 18:31:23 UTC 2007 x86_64
> 
> So this is looking like a e1000 bug.  I'll try to upgrade the kernel on 
> the ia64 box and see what happens.
A few notes to the discussion. I've seen one e1000 "bug" that ended up being
a crappy AMD pre-opteron SMP chipset with a totally useless PCI bus
implementation, which limited performance quite a bit-totally depending on
what you plugged in and in which slot. 10e milk-and-bread-store 
32/33 gige nics actually were better than server-class e1000's 
in those, but weren't that great either.

A few things worth trying out is using recv(.., MSG_TRUNC ) on the receiver,
that tests the theoretical sender maximum performance much better (but memory
bandwidth vs. GigE is much higher these days than it was in 2001 so maybe
not that useful anymore).

Check your interrupt rates for the interface. You shouldn't be getting
anywhere near 1 interrupt/packet. If you are, something is badly wrong :).

Running getsockopt(...TCP_INFO) every few secs on the socket and printing
that out can be useful too. That gives you both sides' idea on what the
tcp windows etc. are.

My favourite tool is a home-made thing called yantt btw. 
( http://www.ee.oulu.fi/~pp/yantt.tgz . Needs lots of cleanup love, 
it mucks with the window sizes by default, since in the 2.4 days you really
had to do that to get any kind of performance and the help text is wrong.
But it's pretty easy to hack to try out new ideas, use 
sendfile/MSG_TRUNC/TCP_INFO etc.

Netperf is the kitchen sink of network benchmark tools. But trying out a few
tiny things with it is not fun at all, I tried and quickly decided to 
write my own tool for my master's thesis work ;-)

Oh. Don't measure CPU usage with top. Use a cyclesoaker (google for
cyclesoak, I included akpm's with yantt) :-)

And yes. TCP stacks do have bugs, especially when things get outside the
equipment most people have. Having a dedicated transatlantic 2.5Gbps
connection found a really fun one a long time ago ;)

-- 
Pekka Pietikainen
