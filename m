From: "David S. Miller" <davem@davemloft.net>
Subject: Re: take 2-2  WAS(Re: PATCH: IPSEC xfrm events
Date: Mon, 4 Apr 2005 15:25:06 -0700
Message-ID: <20050404152506.15e1404b.davem@davemloft.net>
References: <1112406164.1088.54.camel@jzny.localdomain>
	<20050402014619.GB24861@gondor.apana.org.au>
	<1112469601.1088.173.camel@jzny.localdomain>
	<1112538718.1096.394.camel@jzny.localdomain>
	<20050404005805.GA16543@gondor.apana.org.au>
	<1112614706.1096.439.camel@jzny.localdomain>
	<20050404121641.GA12103@gondor.apana.org.au>
	<1112619096.1088.473.camel@jzny.localdomain>
	<20050404130224.GA12546@gondor.apana.org.au>
	<1112620614.1088.489.camel@jzny.localdomain>
	<20050404213149.GA15222@gondor.apana.org.au>
	<1112653217.1088.2.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, kaber@trash.net, nakam@linux-ipv6.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1112653217.1088.2.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 04 Apr 2005 18:20:17 -0400
jamal <hadi@cyberus.ca> wrote:

> On Mon, 2005-04-04 at 17:31, Herbert Xu wrote:
> > On Mon, Apr 04, 2005 at 09:16:55AM -0400, jamal wrote:
> > > 
> > > Ok, fair enough. It annoys me too when i review patches ;->
> > > So i will fix this before final.
> > 
> > Just one more thing, can you please remove the _bh's that you
> > added to the read_lock for xfrm_km_list? It turns out that they're
> > not necessary since the write_lock()'s are only held in process
> > context.
> 
> Doesnt the policy notification one need it at least ? I thought it is
> entered at interupt context on packet path, no?

If you only take write_lock() from process context, only the write_lock()'s
need BH disabling.  read_lock() takers can then nest arbitrarily, BH or not.
