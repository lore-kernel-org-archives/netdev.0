From: Andi Kleen <ak@suse.de>
Subject: Re: bad TSO performance in 2.6.9-rc2-BK
Date: Wed, 29 Sep 2004 00:33:44 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040928223344.GC2975@wotan.suse.de>
References: <20040923164149.5368d291.davem@davemloft.net> <E1CBkIW-0001dF-00@gondolin.me.apana.org.au> <20040927025048.GA6723@gondor.apana.org.au> <20040926210029.22750d47.davem@davemloft.net> <20040927054541.GA8858@gondor.apana.org.au> <20040927120154.09fdcadf.davem@davemloft.net> <20040927213233.GC7243@gondor.apana.org.au> <20040928141002.164c60af.davem@davemloft.net> <20040928213415.GA4646@wotan.suse.de> <20040928145345.2530d30e.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <ak@suse.de>, herbert@gondor.apana.org.au, niv@us.ibm.com,
        andy.grover@gmail.com, anton@samba.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20040928145345.2530d30e.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Sep 28, 2004 at 02:53:45PM -0700, David S. Miller wrote:
> On Tue, 28 Sep 2004 23:34:15 +0200
> Andi Kleen <ak@suse.de> wrote:
> 
> > I admit I lost track of all your patches now - can you give me a big
> > diff against the latest BK so that I can check that the problem
> > is gone for me too? 
> 
> Here are all of the pending TCP bug fixes, attached in order.
> I'll be pushing these to Linus some time today.

I'm afraid I must report it's still not completely solved for me yet.
10s netperf with TSO on with your patches gives now ~10MB/s less than 
with TSO off (57 vs 67). It's better than before, but not really
fixed yet.

Looking at my tcpdumps and comparing TSO on/off I see a quite
strange effect. It only acks on every ~25th packet with TSO off
but every ~16th packet with TSO on.

Receiver is a 2.6.5 kernel, it's weird that it violates the
ack every two MSS rule.

-Andi
