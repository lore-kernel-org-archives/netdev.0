From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: 2.6.7-rc3: unregister_netdevice: waiting for tun0 to become free. Usage count = 1
Date: Mon, 14 Jun 2004 14:53:12 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040614045312.GA28999@gondor.apana.org.au>
References: <E1BZeW1-0008Ny-00@gondolin.me.apana.org.au> <20040613234142.GA32329@gondor.apana.org.au> <20040613183622.3a814506.davem@redhat.com> <20040614015013.GA11048@gondor.apana.org.au> <20040613210725.70dbd016.davem@redhat.com> <20040614042216.GA28669@gondor.apana.org.au> <20040613212708.1903d54c.davem@redhat.com> <20040614044240.GA28844@gondor.apana.org.au> <20040614044717.GA28929@gondor.apana.org.au> <20040613214355.772af3a6.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: schwab@suse.de, netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20040613214355.772af3a6.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Jun 13, 2004 at 09:43:55PM -0700, David S. Miller wrote:
> On Mon, 14 Jun 2004 14:47:17 +1000
> Herbert Xu <herbert@gondor.apana.org.au> wrote:
> 
> > And there's more :) The work done in ifdown also falls in the same
> > category.  Its work will be carried out in the GC anyway.
> > 
> > Actually in all these cases it could take a lot more than two minutes
> > if there is a long-living entity (maybe a TCP connection) holding onto
> > the dst.  So I guess #1 and #2 should be addressed at some point.
> 
> Maybe the solution is to initiate a GC run as soon as possible
> instead of however long into the future it would have ended
> up running.
> 
> Wouldn't that help?

Not really.  The GC is powerless until all those entities drop their
references to the dst.

That's why we've got this hack in dst_dev_event that sets ->dev to
loopback_dev in order to drop the dev reference early.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email:  Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
