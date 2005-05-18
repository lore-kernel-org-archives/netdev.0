From: Arthur Kepner <akepner@sgi.com>
Subject: Re: [RFC/PATCH] "strict" ipv4 reassembly
Date: Tue, 17 May 2005 18:06:14 -0700 (PDT)
Message-ID: <Pine.LNX.4.61.0505171751400.3664@linux.site>
References: <20050517.104947.112621738.davem@davemloft.net>
 <E1DYAHF-0006qW-00@gondolin.me.apana.org.au> <20050518004733.GG13748@postel.suug.ch>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>, Thomas Graf <tgraf@suug.ch>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Rick Jones <rick.jones2@hp.com>, Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050518004733.GG13748@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


It sounds as if Herbert and Rick have much the same idea. And 
it sounds like a good idea, definitely worth considering...

On Wed, 18 May 2005, Thomas Graf wrote:

> * Herbert Xu <E1DYAHF-0006qW-00@gondolin.me.apana.org.au> 2005-05-18 08:11
> > Instead of measuring the distance using time, let's measure it
> > in terms of packet counts.  So every time we receive a fragmented
> > packet, we find all waiting fragments with the same src/dst pair.
> > If the id is identical we perform reassembly, if it isn't we increase
> > a counter in that fragment.  If the counter exceeds a threshold,
> > we drop the fragment.
> 
> I like this, although the problem is derived to the definition
> of the threshold. Any ideas on how to define this? A
> combination of your idea together with the idea I stated in
> another post which would additional expire fragments earlier
> depending on the actual packet (or fragment) rate might give
> better results.
> 

------------------------------ [snip] ------------------------------
> On Tue, 17 May 2005, Rick Jones wrote:
> .....
> Actually, I was ass-u-me-ing they would be monotonic, but thinking about 
> it more, that doesn't really matter.  If N datagrams from that 
> source/dest/prot tuple have been reassembled since the first/current 
> frag of this datagam has arrived, chances are still good that the rest 
> of the fragments of this datagram are toast and any subsequent 
> fragments with a matching src/dst/prot/id would likely create a 
> frankengram.
> 
> in broad handwaving terms, those N other datagrams (non-fragmented or 
> fragmented and successfully reassembled or not I suspect) are a measure 
> of just how far "out of order" the rest of the fragments of this 
> datagram happen to be.  for some degree of "out of orderness" we can 
> ass-u-me the datagram is toast.
> 
> chosing a strawman, if we've received 24000 datagrams from that 
> source/dest/prot (perhaps even just that source) since we've started 
> reassembling this datagram from that source/dest/prot, chances seem 
> pretty good indeed that this datagram is toast.  a value of N even 
> smaller than 24000 might suffice.
> 
> the devil seems to be in the accounting.

------------------------------ [snip] ------------------------------
