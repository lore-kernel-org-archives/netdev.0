From: Andi Kleen <ak@suse.de>
Subject: Re: bad TSO performance in 2.6.9-rc2-BK
Date: Wed, 29 Sep 2004 01:27:57 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040929012757.5d0dff61.ak@suse.de>
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
	<20040928155706.65405e88.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, niv@us.ibm.com, andy.grover@gmail.com,
        anton@samba.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20040928155706.65405e88.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 28 Sep 2004 15:57:06 -0700
"David S. Miller" <davem@davemloft.net> wrote:

> On Wed, 29 Sep 2004 00:33:44 +0200
> Andi Kleen <ak@suse.de> wrote:
> 
> > Looking at my tcpdumps and comparing TSO on/off I see a quite
> > strange effect. It only acks on every ~25th packet with TSO off
> > but every ~16th packet with TSO on.
> > 
> > Receiver is a 2.6.5 kernel, it's weird that it violates the
> > ack every two MSS rule.
> 
> Your system is SMP and packet reordering is occuring?

The sender is SMP, but the receiver is UP.
I tcpdumped at the receiver.

> If so, you can lock the interrupts of the card
> to a specific cpu to see if that makes the problem go
> away.
> 
> Another possibility is tcpdump dropping some of the ACKs

Possible, unfortunately there are no counters for this
(anyone on netdev motivated to add them to each packet drop
in PF_PACKET and dev.c?) 

> or some bug in the TCP code of your "interesting experiment
> based upon 2.6.5" kernel :-)

Possible. 

I tried to re-test it but I didn't get very far because the kernel
with your patch crashes regularly during netperf. No serial console,
but the backtrace is {tcp_ack+877} {tcp_rcv_established+350} ... 
Before that there are a few "retrans out leaked" messages.


-Andi
