From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: 2.6.7-rc3: unregister_netdevice: waiting for tun0 to become free. Usage count = 1
Date: Mon, 14 Jun 2004 14:47:17 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040614044717.GA28929@gondor.apana.org.au>
References: <20040613121514.6b3c1c8a.davem@redhat.com> <E1BZeW1-0008Ny-00@gondolin.me.apana.org.au> <20040613234142.GA32329@gondor.apana.org.au> <20040613183622.3a814506.davem@redhat.com> <20040614015013.GA11048@gondor.apana.org.au> <20040613210725.70dbd016.davem@redhat.com> <20040614042216.GA28669@gondor.apana.org.au> <20040613212708.1903d54c.davem@redhat.com> <20040614044240.GA28844@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: schwab@suse.de, netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20040614044240.GA28844@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Jun 14, 2004 at 02:42:40PM +1000, herbert wrote:
> On Sun, Jun 13, 2004 at 09:27:08PM -0700, David S. Miller wrote:
> >
> > > 1. The code in dst_dev_event relies on the entries with dev in it
> > > getting onto the garbage list before it is called.  Unfortunately
> > > for routing entries, the flushing is done asynchronusly so it is
> > > entirely possible for the entries to get onto the garbage list after
> > > dst_dev_event has been called twice (DOWN and then UNREGISTER).
> > > 
> > > This is not fatal though since another GC run will pick them up in
> > > at most two minutes.  But the user may well be alarmed by those
> > > dreaded "waiting for..." errors.
> > 
> > Right.
> > 
> > > 2. dst_dev_event doesn't clean up dst->child at all.
> > 
> > DST object is disassembled at GC time, so I classift this just
> > like case #1 above.
> 
> Yes.  In fact the loopback_dev code in dst_dev_event is also like
> this.  Removing that code will simply defer the dropping of the
> dev reference to the GC.

And there's more :) The work done in ifdown also falls in the same
category.  Its work will be carried out in the GC anyway.

Actually in all these cases it could take a lot more than two minutes
if there is a long-living entity (maybe a TCP connection) holding onto
the dst.  So I guess #1 and #2 should be addressed at some point.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email:  Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
