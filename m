From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: IPsec and Path MTU
Date: Fri, 18 Jun 2004 09:12:41 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040617231241.GB14739@gondor.apana.org.au>
References: <20040615124334.GA25164@gondor.apana.org.au> <20040616195653.GC29781@ms2.inr.ac.ru> <20040616231317.GA5742@gondor.apana.org.au> <20040617190158.GA10925@ms2.inr.ac.ru> <20040617213832.GC14089@gondor.apana.org.au> <20040617152921.730892c7.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kuznet@ms2.inr.ac.ru, jmorris@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20040617152921.730892c7.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Jun 17, 2004 at 03:29:21PM -0700, David S. Miller wrote:
> On Fri, 18 Jun 2004 07:38:32 +1000
> Herbert Xu <herbert@gondor.apana.org.au> wrote:
> 
> > Suppose that the MTU of 192.168.0.1 is 1500, and that the calculated MTU
> > for the bundle is 1430.
> > 
> > If there is a host 10.10.10.10 on the Internet or behind some sort
> > a VPN where the path from 192.168.0.1 to it has an MTU of 1200,
> > then by sending a 1430-byte packet to 10.10.10.10 from 192.168.0.2,
> > we will get back an ICMP packet saying that the largest MTU for
> > 192.168.0.2-10.10.10.10 is 1200.
> > 
> > This will be successfully stored in the route entry.  But the route
> > entry's MTU is not used at all since the MTU of the bundle is deduced
> > from the MTU of the path, 192.168.0.1.  So we'll continue to send large
> > packets to 10.10.10.10.
> 
> This is what Alexey is talking about.  When we send a packet out for
> an IPSEC rule, we have to remember the inner (per-transform pre-tunnel)
> IP addresses (keyed by outer IP address and ESP/AH spi) in order to get
> the ICMP PMTU messages handled correctly.  We don't do this right now,
> it's difficult and complicated work.

Right, that's *what* Alexey is talking about.  But it's *not* what I'm
talking about :)

In my case, the ICMP message is not coming from the remote IPsec gateway
or a router in front of it.  It's coming from a host behind it.  So
the original IP header is in the ICMP message, in the clear.
 
> It's an issue not specific to making the gateway be the sender of
> the packet, it's an issue with tunnels in all cases currently.

Correct.  But before we get to that, let's fix the simple case first.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email:  Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
