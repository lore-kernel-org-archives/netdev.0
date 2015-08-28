From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [RFC PATCH net-next 0/2] Add new switchdev device class
Date: Fri, 28 Aug 2015 13:52:55 +0200
Message-ID: <20150828115255.GC20774@lunn.ch>
References: <1440659806-56582-1-git-send-email-sfeldma@gmail.com>
 <20150827074525.GA8094@lunn.ch>
 <CAE4R7bD0Ka0187Qq=+6cZL7UqgnxJASKL_6AmaC2z_jiF5Jp1w@mail.gmail.com>
 <20150827090603.GC8094@lunn.ch>
 <CAE4R7bCxb8Ni4b5=o80FG+iGEA_dtpefWm9o5eqqKLboC35stg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Netdev <netdev@vger.kernel.org>,
	=?iso-8859-1?B?Smk/P+0gUO1ya28=?= <jiri@resnulli.us>,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:41554 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751844AbbH1MA2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Aug 2015 08:00:28 -0400
Content-Disposition: inline
In-Reply-To: <CAE4R7bCxb8Ni4b5=o80FG+iGEA_dtpefWm9o5eqqKLboC35stg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> So with kobj, a device can have a parent.  So I experimented with my
> RFC patch and changed register_switchdev to take a parent switchdev
> arg, which is NULL for leaf switchdevs:
> 
> int register_switchdev(struct switchdev *sdev, const char *name,
>                        struct switchdev *parent)
> {
>         struct device *dev = &sdev->dev;
>         int err;
> 
>         device_initialize(dev);
> 
>         dev->class = &switchdev_class;
>         if (parent)
>                 dev->parent = &parent->dev;
> 
>         err = dev_set_name(dev, "%s", name);
>         if (err)
>                 return err;
> 
>         return device_add(dev);
> }
 
...

> With this, we can stack switchdevs, I guess as high as we want.  Does
> this look usable for DSA?   An attr set on the master would get pushed
> down to the leaves.  We'd can do it with the same style of recursive
> algos we use for switchdev port attrs.

Since this is a file system, we are limited to trees. But the hardware
is actually a graph. The interconnect points are ports on the switch,
and possible trunks/bonds of ports. I doubt there is a nice way to
represent this.

So it probably makes sense to have the switch with the port to the
host as the root of the tree, and all other switches are leafs of that
root.

How do you envisage addressing? I want to use netlink to read the
global registers from a specific switch for example.

       Andrew
