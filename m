From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: 2.6.7-rc3: unregister_netdevice: waiting for tun0 to become free. Usage count = 1
Date: Mon, 14 Jun 2004 20:28:58 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040614102858.GA12343@gondor.apana.org.au>
References: <20040613121514.6b3c1c8a.davem@redhat.com> <E1BZeW1-0008Ny-00@gondolin.me.apana.org.au> <20040613234142.GA32329@gondor.apana.org.au> <20040613183622.3a814506.davem@redhat.com> <20040614015013.GA11048@gondor.apana.org.au> <20040613210725.70dbd016.davem@redhat.com> <20040614042216.GA28669@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: schwab@suse.de, netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20040614042216.GA28669@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Jun 14, 2004 at 02:22:16PM +1000, herbert wrote:
> 
> 1. The code in dst_dev_event relies on the entries with dev in it
> getting onto the garbage list before it is called.  Unfortunately
> for routing entries, the flushing is done asynchronusly so it is
> entirely possible for the entries to get onto the garbage list after
> dst_dev_event has been called twice (DOWN and then UNREGISTER).

Actually this can't happen since fib_netdev_event will do an
immediate flush.  So it's only #2 or IPsec that's a problem.
 
Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email:  Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
