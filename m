From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 2.5.70+] tun using alloc_netdev
Date: Wed, 11 Jun 2003 15:43:18 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030611194317.GE31051@gtf.org>
References: <20030609115857.38bb31d6.shemminger@osdl.org> <5.1.0.14.2.20030611121155.0b659e20@unixmail.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@osdl.org>,
   "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Max Krasnyansky <maxk@qualcomm.com>
Content-Disposition: inline
In-Reply-To: <5.1.0.14.2.20030611121155.0b659e20@unixmail.qualcomm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Jun 11, 2003 at 12:21:44PM -0700, Max Krasnyansky wrote:
> At 11:58 AM 6/9/2003, Stephen Hemminger wrote:
> 
> 
> >-               if ((err = dev_alloc_name(&tun->dev, name)) < 0)
> >-                       goto failed;
> >-               if ((err = register_netdevice(&tun->dev)))
> >+               dev = alloc_netdev(sizeof(struct tun_struct), name,
> >+                                  tun_setup);
> >+               if (!dev)
> >+                       return -ENOMEM;
> >+
> >+               tun = dev->priv;
> >+               tun->flags = flags;
> >+
> >+               if ((err = register_netdevice(tun->dev))) {
> >+                       kfree(dev);
> >                        goto failed;
> >+               }
> 
> 
> This is wrong. register_netdevice() does not expand name (ie %d stuff).
> So dev_alloc_name() is still needed. i.e.

Correct.

But, register_netdev() is preferred precisely for this reason.

	Jeff
