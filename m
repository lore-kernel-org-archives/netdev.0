From: "David S. Miller" <davem@redhat.com>
Subject: Re: 2.6.7-rc3: unregister_netdevice: waiting for tun0 to become
 free. Usage count = 1
Date: Sun, 13 Jun 2004 21:27:08 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040613212708.1903d54c.davem@redhat.com>
References: <20040613121514.6b3c1c8a.davem@redhat.com>
	<E1BZeW1-0008Ny-00@gondolin.me.apana.org.au>
	<20040613234142.GA32329@gondor.apana.org.au>
	<20040613183622.3a814506.davem@redhat.com>
	<20040614015013.GA11048@gondor.apana.org.au>
	<20040613210725.70dbd016.davem@redhat.com>
	<20040614042216.GA28669@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: schwab@suse.de, netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040614042216.GA28669@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 14 Jun 2004 14:22:16 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> OK, in that case either they all need to check whether idev is
> NULL before doing this or we'll need to fix ->ifdown to set the
> dev to something other than NULL.

That's correct, I don't exactly how to deal with that race
just yet.

> BTW in looking at this I've found two bugs in the dst code wrt
> cleaning up net devices.
> 
> 1. The code in dst_dev_event relies on the entries with dev in it
> getting onto the garbage list before it is called.  Unfortunately
> for routing entries, the flushing is done asynchronusly so it is
> entirely possible for the entries to get onto the garbage list after
> dst_dev_event has been called twice (DOWN and then UNREGISTER).
> 
> This is not fatal though since another GC run will pick them up in
> at most two minutes.  But the user may well be alarmed by those
> dreaded "waiting for..." errors.

Right.

> 2. dst_dev_event doesn't clean up dst->child at all.

DST object is disassembled at GC time, so I classift this just
like case #1 above.
