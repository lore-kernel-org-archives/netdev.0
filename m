From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] ethertap can use alloc_etherdev
Date: Tue, 11 Nov 2003 16:47:58 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031111164758.66298833.shemminger@osdl.org>
References: <20031111144557.38bde052.shemminger@osdl.org>
	<3FB17650.2000408@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <3FB17650.2000408@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 11 Nov 2003 18:52:48 -0500
Jeff Garzik <jgarzik@pobox.com> wrote:

> Stephen Hemminger wrote:
> > Can use alloc_etherdev, don't need to call ether_setup.
> > Found by viro.
> > 
> > diff -Nru a/drivers/net/ethertap.c b/drivers/net/ethertap.c
> > --- a/drivers/net/ethertap.c	Tue Nov 11 09:36:15 2003
> > +++ b/drivers/net/ethertap.c	Tue Nov 11 09:36:15 2003
> > @@ -72,8 +72,7 @@
> >  	struct net_device *dev;
> >  	int err = -ENOMEM;
> >  
> > -	dev = alloc_netdev(sizeof(struct net_local), "tap%d",
> > -			   ether_setup);
> > +	dev = alloc_etherdev(sizeof(struct net_local));
> 
> 
> Um?  This clearly changes the device's interface name, which 
> alloc_etherdev() not ether_setup() assigns.
> 

It forces it already several lines later and it hasn't registered yet.

	if (!dev)
		goto out;

	SET_MODULE_OWNER(dev);

	sprintf(dev->name, "tap%d", unit);
	dev->base_addr = unit + NETLINK_TAPBASE;


-- 
Stephen Hemminger <shemminger@osdl.org>
Open Source Development Lab	 http://developer.osdl.org

:-) Ignorance never settles a question
