From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: RFC new ethtool command
Date: Tue, 1 Mar 2005 10:43:38 -0800
Message-ID: <20050301104338.1380b7cc@dxpl.pdx.osdl.net>
References: <3a958240e12af10ef6777f908abfe682@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@oss.sgi.com>, Jeff Garzik <jgarzik@pobox.com>
To: Andy Fleming <afleming@freescale.com>
In-Reply-To: <3a958240e12af10ef6777f908abfe682@freescale.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 1 Mar 2005 09:22:07 -0600
Andy Fleming <afleming@freescale.com> wrote:

> I propose adding a new command to ethtool which allows ethernet drivers 
> to specify a command list.  A command list would consist of a 
> name/value pair, conforming to the cmdline_info structure already 
> present in ethtool.  I see two immediate benefits of this system:
> 
> 1) controllers which have "cutting-edge", or at least unusual, features 
> can easily add support for these features.  As an example, the 85xx 
> allows the ethernet controller's DMA engine to allocate and/or lock 
> buffer descriptors into the L2 cache of the processor.  Using this 
> method, a command could be created which is specific to that driver 
> which allows users to turn this feature on or off.
> 
> 2) When debugging a new driver, or a new feature for an old driver, it 
> is easy to add a quick interface to change the testing parameters 
> without having to add new /proc entries.
> 
> Three patches follow; the first allows ethtool to use this new feature, 
> the second allows the kernel to invoke the new feature, and the third 
> is an example of how the gianfar driver uses this feature to expose 
> failure testing features in the PHY-level code (note that this third 
> patch is not a final version.  It also contains a few elements from the 
> PHY abstraction patch, which can be ignored for the purposes of this 
> discussion).

I understand the motivation, but it seems to go against the philosophy
of having a general purpose interface.  Rather than having device driver
specific special cases, why not add useful abstractions for new features.
Phy interface testing and management is generic, and several devices could
support it.

This proposal is basically a device specific multiplexing interface like
ioctl or SIOCDEVPRIVATE. This style of interface is considered bad, and
undesirable.

For the first case, of "cutting-edge" controller's, the best solution is to
always turn the feature on and make it work correctly.  If you can't make it
work correctly then use module parameter or chip set detection to turn it off.
Another option to expose warts is using sysfs attribute groups to add additional
fields to /sys/class/net/ethXX/.  

When debugging a new driver, module parameters work find for controlling
test parameters.  If this needs to make into production code, sysfs could
also be used.
