From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 2.5.70+] tun using alloc_netdev
Date: Wed, 11 Jun 2003 13:27:15 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030611132715.76a485c7.shemminger@osdl.org>
References: <20030609115857.38bb31d6.shemminger@osdl.org>
	<5.1.0.14.2.20030611121155.0b659e20@unixmail.qualcomm.com>
	<20030611194317.GE31051@gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: maxk@qualcomm.com, davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <20030611194317.GE31051@gtf.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 11 Jun 2003 15:43:18 -0400
Jeff Garzik <jgarzik@pobox.com> wrote:

> On Wed, Jun 11, 2003 at 12:21:44PM -0700, Max Krasnyansky wrote:
> > At 11:58 AM 6/9/2003, Stephen Hemminger wrote:
> > 
> > 
> > >-               if ((err = dev_alloc_name(&tun->dev, name)) < 0)
> > >-                       goto failed;
> > >-               if ((err = register_netdevice(&tun->dev)))
> > >+               dev = alloc_netdev(sizeof(struct tun_struct), name,
> > >+                                  tun_setup);
> > >+               if (!dev)
> > >+                       return -ENOMEM;
> > >+
> > >+               tun = dev->priv;
> > >+               tun->flags = flags;
> > >+
> > >+               if ((err = register_netdevice(tun->dev))) {
> > >+                       kfree(dev);
> > >                        goto failed;
> > >+               }
> > 
> > 
> > This is wrong. register_netdevice() does not expand name (ie %d stuff).
> > So dev_alloc_name() is still needed. i.e.
> 
> Correct.
> 
> But, register_netdev() is preferred precisely for this reason.
> 

Not possible in this case because device is created off socket ioctl so it is
called with rtnl_lock
