From: <Narendra_K@Dell.com>
Subject: Re: [PATCH v1 net-next] net: Add phys_port identifier to struct
 net_device and export it to sysfs
Date: Tue, 2 Jul 2013 07:09:04 -0700
Message-ID: <20130702140859.GB11777@fedora18-dev.oslab.blr.amer.dell.com>
References: <20130628152652.GA4247@fedora-17-guest.blr.amer.dell.com>
 <1372709542.2083.61.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: <netdev@vger.kernel.org>, <john.r.fastabend@intel.com>
To: <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausc60pc101.us.dell.com ([143.166.85.206]:58881 "EHLO
	ausc60pc101.us.dell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751889Ab3GBOPK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jul 2013 10:15:10 -0400
In-Reply-To: <1372709542.2083.61.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 02, 2013 at 01:42:22AM +0530, Ben Hutchings wrote:
> 
> On Fri, 2013-06-28 at 20:57 +0530, Narendra_K@Dell.com wrote:
> [...]
> > --- a/include/linux/netdevice.h
> > +++ b/include/linux/netdevice.h
> > @@ -1062,6 +1062,14 @@ struct net_device_ops {
> >                                                     bool new_carrier);
> >  };
> > 
> > +/* This structure holds a universally unique identifier to
> > + * identify the physical port used by a netdevice
> > + */
> > +struct port_identifier {
> > +     unsigned char port_id[MAX_ADDR_LEN];
> > +     unsigned port_id_len;
> 
> Was this meant to be unsigned (int) or unsigned char?  The length is
> typed as unsigned char in show_phys_port().

Sorry, this change was by mistake. It is unsigned char. I will change
it in the next version of the patch. Thank you for pointing out this.

> 
> > +};
> [...]
> > --- a/net/core/net-sysfs.c
> > +++ b/net/core/net-sysfs.c
> > @@ -334,6 +334,27 @@ static ssize_t store_group(struct device *dev, struct
> device_attribute *attr,
> >       return netdev_store(dev, attr, buf, len, change_group);
> >  }
> > 
> > +static ssize_t show_phys_port(struct device *dev,
> > +                           struct device_attribute *attr, char *buf)
> > +{
> > +     struct net_device *net = to_net_dev(dev);
> > +     ssize_t ret = -EINVAL;
> > +     unsigned char len;
> > +
> > +     read_lock(&dev_base_lock);
> > +     if (dev_isalive(net)) {
> > +             len = net->phys_port.port_id_len;
> > +             if (!len) {
> > +                     read_unlock(&dev_base_lock);
> > +                     return 0;
> > +             }
> 
> I would write this as:
>                 if (!len)
>                         ret = 0;
>                 else
> so that the same exit path is used in all three cases.

Ok. I will make this change in the next version of the patch. I will
submit the next version when net-next opens.

> 
> Ben.
> 
> > +             ret = sysfs_format_mac(buf, net->phys_port.port_id, len);
> > +     }
> > +     read_unlock(&dev_base_lock);
> > +
> > +     return ret;
> > +}
> [...]
> 
> --
> Ben Hutchings, Staff Engineer, Solarflare
> Not speaking for my employer; that's the marketing department's job.
> They asked us to note that Solarflare product names are trademarked.
> 
> 

-- 
With regards,
Narendra K
Linux Engineering
Dell Inc.
