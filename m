From: David Dillow <dave@thedillows.org>
Subject: Re: [RFC 2.6.10 5/22] xfrm: Attempt to offload bundled xfrm_states
	for outbound xfrms
Date: Sat, 22 Jan 2005 00:53:01 -0500
Message-ID: <1106373181.3691.41.camel@ori.thedillows.org>
References: <20041230035000.13@ori.thedillows.org>
	 <20041230035000.14@ori.thedillows.org>
	 <20050121152045.5c92ee05.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050121152045.5c92ee05.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2005-01-21 at 15:20 -0800, David S. Miller wrote: 
> On Thu, 30 Dec 2004 03:48:35 -0500
> David Dillow <dave@thedillows.org> wrote:
> 
> > +static void xfrm_accel_bundle(struct dst_entry *dst)
> > +{
> > +	struct xfrm_bundle_list bundle, *xbl, *tmp;
> > +	struct net_device *dev = dst->dev;
> > +	INIT_LIST_HEAD(&bundle.node);
> > +
> > +	if (dev && netif_running(dev) && (dev->features & NETIF_F_IPSEC)) {
> 
> netif_running() is only steady while the RTNL semaphore is held,
> which is not necessarily true when xfrm_lookup() is invoked.

I've been reworking this area already to add the ability for the user to
control which devices/states combinations can be offloaded, so this code
will change. What do you think about just having the driver be
responsible for ignoring offload requests when they don't make sense,
like when the device is down, or in sleep mode?

BTW, xfrm_lookup() also calls stale_bundle(), which also relies on
netif_running(), among other tests.
-- 
David Dillow <dave@thedillows.org>
