From: "David S. Miller" <davem@davemloft.net>
Subject: Re: Current 2.6.x TSO state
Date: Fri, 1 Oct 2004 12:56:43 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041001125643.30c6830f.davem@davemloft.net>
References: <20040930213221.06a3f5b3.davem@davemloft.net>
	<20041001121123.19511403.ak@suse.de>
	<20041001124733.1ac4266a.davem@davemloft.net>
	<20041001195146.GA23046@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ak@suse.de, netdev@oss.sgi.com, jheffner@psc.edu,
        herbert@gondor.apana.org.au
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <20041001195146.GA23046@wotan.suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 1 Oct 2004 21:51:47 +0200
Andi Kleen <ak@suse.de> wrote:

> > >      max win adv:            5840 bytes     max win adv:           63712 bytes
> > >      min win adv:            5840 bytes     min win adv:            5792 bytes
> > 
> > That stinks that the receiver is only using a 64K window,
> > that's way too small for gigabit.
> 
> Just using the default, no tuning.
> 
> I have some patches in the pipeline to do automatic window tuning
> based on link speed based on dev->features. But they were actually more 
> intended for 10Gbit/s (where all the defaults are completely inadequate)  
> And it needs a bit more work. 

As mentioned, the TCP receive buffer auto-tuning takes care
of all of this in 2.6.6 and later.  It's just 2.6.5 doesn't
have John Heffner's auto-tuning code which is why your test
case is so stuck in the mud.

Also, the stretch ACK's are quite normal.  If the receiver can't
advertize a larger window, we won't spit out an ACK until
the ack timeout.
