From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] [NET]: Fix deletion of local addresses only varying in prefix length
Date: Sat, 5 Mar 2005 17:23:23 +0100
Message-ID: <20050305162323.GM31837@postel.suug.ch>
References: <20050304012003.GA31837@postel.suug.ch> <E1D78DN-0002te-00@gondolin.me.apana.org.au> <20050304131419.GE31837@postel.suug.ch> <20050304233212.GA27421@gondor.apana.org.au> <20050305002910.GJ31837@postel.suug.ch> <20050305005911.GA27804@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@oss.sgi.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <20050305005911.GA27804@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Herbert Xu <20050305005911.GA27804@gondor.apana.org.au> 2005-03-05 11:59
> On Sat, Mar 05, 2005 at 01:29:10AM +0100, Thomas Graf wrote:
> > 
> > I've been thinking about this since yesterday and the best solution I
> > came up so far is to encode it in one of the yet unused bits in
> > the prefixlength field. After all we're only using 5bits of it. What
> > i'm thinking of in particular is to encode it as in 1 bit wildcard
> > flag 5 bits prefix length.
> 
> That's sound fine as long as we treat the current ip(8) prefix length
> as a wild card.

Although we should keep the behaviour of ip a a 1.1.1.1/24; ip a d
1.1.1.1, what about ip a a 1.1.1.1/24; ip a d 1.1.1.1/16? I think the
latter should not result in a deletion. We could achieve this by checking
the prefix length if either the exact-match flag is set or the 
prefixlength is != 32. This is of course quite minor and only affects
old iproute2 versions in combination with newer kernels.

Thougts?
