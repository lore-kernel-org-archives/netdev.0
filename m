From: "David S. Miller" <davem@redhat.com>
Subject: Re: TCP IP Offloading Interface
Date: Sun, 13 Jul 2003 17:42:42 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030713174242.3ceb8213.davem@redhat.com>
References: <ODEIIOAOPGGCDIKEOPILCEMBCMAA.alan@storlinksemi.com>
	<20030713004818.4f1895be.davem@redhat.com>
	<52u19qwg53.fsf@topspin.com>
	<20030713160200.571716cf.davem@redhat.com>
	<20030713233503.GA31793@work.bitmover.com>
	<20030713164003.21839eb4.davem@redhat.com>
	<20030713235424.GB31793@work.bitmover.com>
	<20030713165323.3fc2601f.davem@redhat.com>
	<200307140046.h6E0kcMQ021180@turing-police.cc.vt.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-net@vger.kernel.org,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Valdis.Kletnieks@vt.edu
In-Reply-To: <200307140046.h6E0kcMQ021180@turing-police.cc.vt.edu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 13 Jul 2003 20:46:38 -0400
Valdis.Kletnieks@vt.edu wrote:

> On Sun, 13 Jul 2003 16:53:23 PDT, "David S. Miller" said:
> 
> > I really don't see why receive is so much of a big deal
> > compared to send, and we do a send side version of this
> > stuff already with zero problems.
> 
> Well.... there's optimizations you can do on the send side..

I consider the send side complete covered already.  We don't
touch any of the data portion, we only put together the
headers.

> It's hard to do tricks like that when you don't know (for instance) how
> many IP option fields the packet has until you've already started sucking
> the packet off the wire - at which point either the NIC itself has to be clever
> (Hmm, there's that IP offload again) or you have literally about 30 CPU cycles
> to do interrrupt latency *and* decide what to do....

There are cards, both existing and in development, that have
very simple header parsing engines you can program to do stuff
like this, it isn't hard at all.

But this is only half of the problem, you need a flow cache and
clever RX buffer management as well to make the RX side zero-copy
stuff work.
