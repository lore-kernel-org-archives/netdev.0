From: Mirko Lindner <mlindner@syskonnect.de>
Subject: Re: [PATCH] (4/25) sk98: change #define to typedef
Date: Tue, 16 Nov 2004 15:56:15 +0000
Message-ID: <419A231F.4020104@syskonnect.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, Mirko Lindner <demon@pro-linux.de>,
        netdev@oss.sgi.com, Ralph Roesler <rroesler@syskonnect.de>
Return-path: <netdev-bounce@oss.sgi.com>
To: Christoph Hellwig <hch@infradead.org>,
        Stephen Hemminger <shemminger@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

 > I don't think the driver is complex enough for all that os-common mess.
 > If you look at the BSD sk driver it's about a third of the size of the
 > Linux driver because it doesn't have all this mess.

Note that the kernel BSD sk driver was _not_ written by SysKonnect and 
only supports Genesis and Yukon1; linux supports Genesis (single and 
dual), Yukon1, Yukon Plus, Yukon EC, Yukon FE and Yukon2 (single and 
dual). The BSD sk driver supports substantially less functionality than 
the Linux driver. For example, there is no link failover capability in 
the sk driver; it has no power management; numerous chip changes and 
minor tweaks have not been added, since many problems have become 
apparent through our other supported platforms (some 15 operating 
systems) and have since been fixed in our common modules; sk has no 
wake-on-LAN and so on. The official SysKonnect BSD driver (yk) also uses 
the common modules and is not open source.

However, the real point is that the Linux driver (as indeed _all_ of our 
drivers) shares common code with all our supported platforms and this 
necessarily introduces some overhead. But it isn't excessive, and the 
benefits _far_ outweigh the drawbacks, namely, that we have a very wide 
range of systems sharing common code and thus the probability of finding 
and fixing bugs is very substantially higher than if we wrote a 
dedicated driver for each platform.

For instance the symbol SK_IOC mentioned in your mail:

 > -#define SK_IOC char __iomem *
 > +typedef void __iomem *SK_IOC;

is used in a large number of OS independent driver files (e.g. skvpd.c).
The -for instance- file skvpd.c used by our Linux driver is used
at the same time without any changes by all our other drivers running
on other operating systems (e.g. Solaris, Windows).

This is the reason why we need to redefine this symbol to the Linux
specific implementation (void __iomem).

Mirko
