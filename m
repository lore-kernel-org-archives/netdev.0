From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] Add ability to register class interfaces for network
 class
Date: Wed, 27 Oct 2004 11:55:38 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041027115538.540de19e@guest-251-240.pdx.osdl.net>
References: <20041026183526.GA23535@two.research.nokia.com>
	<20041026184838.GB16621@infradead.org>
	<20041026205239.GA23825@two.research.nokia.com>
	<20041027111317.GA27240@infradead.org>
	<417F86F8.6020004@nokia.com>
	<20041027085906.665d0125@guest-251-240.pdx.osdl.net>
	<20041027183804.GA12585@two.research.nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ext ext Christoph Hellwig <hch@infradead.org>, davem@davemloft.net,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Teras Timo (EXT-YomiGroup/Helsinki)" <Ext-Timo.Teras@nokia.com>
In-Reply-To: <20041027183804.GA12585@two.research.nokia.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 27 Oct 2004 21:38:04 +0300
"Teras Timo (EXT-YomiGroup/Helsinki)" <Ext-Timo.Teras@nokia.com> wrote:

> On Wed, Oct 27, 2004 at 08:59:06AM -0700, ext Stephen Hemminger wrote:
> > The Ethernet bridge code creates attribute groups in several places
> > without additional interfaces.  How hard is it to do:
> > 
> > int br_sysfs_addbr(struct net_device *dev)
> > {
> > 	struct kobject *brobj = &dev->class_dev.kobj;
> > 	struct net_bridge *br = netdev_priv(dev);
> > 	int err;
> > 
> > 	err = sysfs_create_group(brobj, &bridge_group);
> > 	if (err) {
> > 		pr_info("%s: can't create group %s/%s\n",
> > 			__FUNCTION__, dev->name, bridge_group.name);
> > 		goto out1;
> > 	}
> 
> This way the problem is that I have to know which devices I will
> add the attributes. But the point is to add attributes to
> all netdevs.
> 
> Using this approach I'd have to enumerate all the interfaces every
> now and then.
> 
> If I have my class interface I get a callback whenever an
> interface is created or deleted and I can automatically add the
> attribute to all netdevs.
> 

If you are doing something to all interfaces, then it probably should
either be part of the common net-sysfs layer, or you can dynamically
discover and do it by following device transitions with 
register_device_notifier.
