From: "David S. Miller" <davem@davemloft.net>
Subject: Re: bad TSO performance in 2.6.9-rc2-BK
Date: Tue, 28 Sep 2004 15:57:06 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040928155706.65405e88.davem@davemloft.net>
References: <20040923164149.5368d291.davem@davemloft.net>
	<E1CBkIW-0001dF-00@gondolin.me.apana.org.au>
	<20040927025048.GA6723@gondor.apana.org.au>
	<20040926210029.22750d47.davem@davemloft.net>
	<20040927054541.GA8858@gondor.apana.org.au>
	<20040927120154.09fdcadf.davem@davemloft.net>
	<20040927213233.GC7243@gondor.apana.org.au>
	<20040928141002.164c60af.davem@davemloft.net>
	<20040928213415.GA4646@wotan.suse.de>
	<20040928145345.2530d30e.davem@davemloft.net>
	<20040928223344.GC2975@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ak@suse.de, herbert@gondor.apana.org.au, niv@us.ibm.com,
        andy.grover@gmail.com, anton@samba.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <20040928223344.GC2975@wotan.suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 29 Sep 2004 00:33:44 +0200
Andi Kleen <ak@suse.de> wrote:

> Looking at my tcpdumps and comparing TSO on/off I see a quite
> strange effect. It only acks on every ~25th packet with TSO off
> but every ~16th packet with TSO on.
> 
> Receiver is a 2.6.5 kernel, it's weird that it violates the
> ack every two MSS rule.

Your system is SMP and packet reordering is occuring?
If so, you can lock the interrupts of the card
to a specific cpu to see if that makes the problem go
away.

Another possibility is tcpdump dropping some of the ACKs
or some bug in the TCP code of your "interesting experiment
based upon 2.6.5" kernel :-)

On my sparc64 box here, TSO makes performance go up quite
clearly, from 55MB/sec-->63MB/sec, and the sender is a tg3
card on a 32-bit/33Mhz bus.
