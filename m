From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] [NET]: Fix deletion of local addresses only varying in prefix length
Date: Sat, 5 Mar 2005 01:29:10 +0100
Message-ID: <20050305002910.GJ31837@postel.suug.ch>
References: <20050304012003.GA31837@postel.suug.ch> <E1D78DN-0002te-00@gondolin.me.apana.org.au> <20050304131419.GE31837@postel.suug.ch> <20050304233212.GA27421@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@oss.sgi.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <20050304233212.GA27421@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Herbert Xu <20050304233212.GA27421@gondor.apana.org.au> 2005-03-05 10:32
> On Fri, Mar 04, 2005 at 02:14:19PM +0100, Thomas Graf wrote:
> > 
> > I do not agree but I might have a better idea. Let's change iproute2
> > to provide a prefixlength of 0 if no prefix was specified and only
> > compare the prefixes if it is non zero. This allows for accurate
> 
> A bigger problem with this approach is that we don't have a magical
> way of getting people to upgrade their ip(8) binary.
> 
> To do this safely, we'll need a way of indicating that the ip(8) binary
> is setting the prefixlen in the way you propose.  Perhaps this can be
> done using a new IFA payload type.
> 
> Alternatively you can use the value of /32 to indicate a wildcard match
> instead of /0.  After all, /0 has a specific meaning in this context so
> it's just as arbitrary to choose /0 as opposed to /32.

I've been thinking about this since yesterday and the best solution I
came up so far is to encode it in one of the yet unused bits in
the prefixlength field. After all we're only using 5bits of it. What
i'm thinking of in particular is to encode it as in 1 bit wildcard
flag 5 bits prefix length.
