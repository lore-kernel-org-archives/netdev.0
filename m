From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] (4/25) sk98: change #define to typedef
Date: Wed, 17 Nov 2004 15:01:34 +0000
Message-ID: <20041117150133.GA8874@infradead.org>
References: <419A231F.4020104@syskonnect.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@osdl.org>, Jeff Garzik <jgarzik@pobox.com>,
        Mirko Lindner <demon@pro-linux.de>, netdev@oss.sgi.com,
        Ralph Roesler <rroesler@syskonnect.de>
Return-path: <netdev-bounce@oss.sgi.com>
To: Mirko Lindner <mlindner@syskonnect.de>
Content-Disposition: inline
In-Reply-To: <419A231F.4020104@syskonnect.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> Note that the kernel BSD sk driver was _not_ written by SysKonnect and 
> only supports Genesis and Yukon1; linux supports Genesis (single and 
> dual), Yukon1, Yukon Plus, Yukon EC, Yukon FE and Yukon2 (single and 
> dual).

They have Yukon2 support for while - unlike Linux.

> The BSD sk driver supports substantially less functionality than 
> the Linux driver. For example, there is no link failover capability in 
> the sk driver;

Which isn't something that belongs into a driver anyway.  It also
means you common code is obsfucated enough that no one noticed :)

> For instance the symbol SK_IOC mentioned in your mail:
> 
> > -#define SK_IOC char __iomem *
> > +typedef void __iomem *SK_IOC;
> 
> is used in a large number of OS independent driver files (e.g. skvpd.c).
> The -for instance- file skvpd.c used by our Linux driver is used
> at the same time without any changes by all our other drivers running
> on other operating systems (e.g. Solaris, Windows).
> 
> This is the reason why we need to redefine this symbol to the Linux
> specific implementation (void __iomem).

And you still haven't explained why your common code uses such
a broken structure instead of having some semi-opaque private data
passed around everywhere.

Also note that we don't new drivers using such horrible "common code"
anymore, you can be happy you sneaked it in at all a few years ago.
