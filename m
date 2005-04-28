From: Thomas Graf <tgraf@suug.ch>
Subject: Re: patch: policy update by id
Date: Thu, 28 Apr 2005 13:43:08 +0200
Message-ID: <20050428114308.GX577@postel.suug.ch>
References: <20050427233924.GA22238@gondor.apana.org.au> <1114650816.7663.13.camel@localhost.localdomain> <20050428012135.GA22950@gondor.apana.org.au> <20050428013014.GA23043@gondor.apana.org.au> <1114653140.7663.36.camel@localhost.localdomain> <20050428020754.GA23326@gondor.apana.org.au> <20050427194356.58a3e618.davem@davemloft.net> <20050428025644.GA23823@gondor.apana.org.au> <1114658160.7663.102.camel@localhost.localdomain> <20050428032045.GA24041@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jamal <hadi@cyberus.ca>, "David S. Miller" <davem@davemloft.net>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <20050428032045.GA24041@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Herbert Xu <20050428032045.GA24041@gondor.apana.org.au> 2005-04-28 13:20
> On Wed, Apr 27, 2005 at 11:16:00PM -0400, jamal wrote:
> > On Thu, 2005-28-04 at 12:56 +1000, Herbert Xu wrote:
> > 
> > > Well netfilter certainly follows this scheme:
> > > 
> > > $ iptables -I INPUT -s 3.3.3.3 -d 4.4.4.4 -j ACCEPT
> > > $ iptables -I INPUT -s 3.3.3.3 -d 4.4.4.4 -j ACCEPT
> > > $ iptables -v -L INPUT -n
> > > Chain INPUT (policy ACCEPT 0 packets, 0 bytes)
> > >  pkts bytes target     prot opt in     out     source               destination 
> > >     0     0 ACCEPT     all  --  *      *       3.3.3.3              4.4.4.4     
> > >     0     0 ACCEPT     all  --  *      *       3.3.3.3              4.4.4.4     
> > 
> > Which is bizare to say the least. If you delete, only the first one gets
> > deleted.
> 
> It isn't that strange.  It's also done using indices except that the
> indices aren't fixed.  Do delete the second rule you would say
> 
> iptables -D INPUT 2

Except for when another iptables instance has modified the ordering of
the rules by inserting or deleting a rule in the meantime. Please do
not adopt this scheme, it's completely unreliable.
