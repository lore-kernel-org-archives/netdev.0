From: Andi Kleen <ak@suse.de>
Subject: Re: packet re-ordering on SMP machines.
Date: Tue, 27 Aug 2002 15:13:17 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20020827151317.A3389@wotan.suse.de>
References: <20020827142004.C4358@wotan.suse.de> <200208271306.RAA19164@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8bit
Cc: Andi Kleen <ak@suse.de>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
Content-Disposition: inline
In-Reply-To: <200208271306.RAA19164@sex.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


On Tue, Aug 27, 2002 at 05:06:30PM +0400, A.N.Kuznetsov wrote:
> Hello!
> 
> > Of course. The only problem is that the clock can be non mononotonous 
> > sometimes and not be in sync with gettimeofday, but at least the kernel 
> > users of packet timestamps do not care.
> 
> What kernel users? Where did you find them? :-)

Hmm, I thought TCP used it, but it seems to use jiffies directly.

Ok, no kernel users then. Not sure about sunrpc and out of tree stuff
like SCTP.


> > The only problem is the socket option, but it is obscure enough that I 
> > would not worry too much about it.
> 
> I am very sorry, but passing timestamp to user level is the only purpose
> of timestamping and it _MUST_ be monotonic and synchronous to time of day,
> otherwise it is completely useless.

That make monotonous step doesn't need to be in netif_rx. My old proposal
was to move it to socket layer. Then it would be only done when needed.
Unfortunately it could get somewhat inaccurate when the queueing delay
is too long.

> > > > - Implement lockless
> 
> You talk about this for ages. :-)

It is nearly there for x86-64 ;)  (code is in for vsyscalls, just kernel 
do_gettimeofday doesn't use it yet)

> 
> 
> Actually, the problem is solved very easily. Deprecate SIOCGSTAMP,
> and either count users of SO_TIMESTAMP and enable timestamping only
> when it is required, or, alternatively, to move retrirval timestamp to socket
> level.

Moving it later may make it useless for RTT purposes when the queueing 
delays are too long.

But if no kernel users exist then just making it a global refcnt could work
nicely. Then most people would not eat the overhead when count == 0.


-Andi
