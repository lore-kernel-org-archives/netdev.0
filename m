From: Andy Fleming <afleming@freescale.com>
Subject: Re: RFC new ethtool command
Date: Tue, 1 Mar 2005 17:15:30 -0600
Message-ID: <2774b2c9a643fd8fadc48be99ec2b5c6@freescale.com>
References: <3a958240e12af10ef6777f908abfe682@freescale.com> <20050301104338.1380b7cc@dxpl.pdx.osdl.net>
Mime-Version: 1.0 (Apple Message framework v619.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@oss.sgi.com>, Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <20050301104338.1380b7cc@dxpl.pdx.osdl.net>
To: Stephen Hemminger <shemminger@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


On Mar 1, 2005, at 12:43, Stephen Hemminger wrote:
>
> I understand the motivation, but it seems to go against the philosophy
> of having a general purpose interface.  Rather than having device 
> driver
> specific special cases, why not add useful abstractions for new 
> features.
> Phy interface testing and management is generic, and several devices 
> could
> support it.

Ok, I probably shouldn't have mentioned the PHY testing, which was just 
a hack to inject errors into some code I was working on.  My point in 
this case was it is easy using this method to add temporary debug 
parameters.  I concede that ethtool may not be the best place for debug 
support.

The problem I'm trying to solve is for the new features I mentioned 
before.  I have an ethernet controller which is part of an SOC, and has 
access to the L2 cache.  As such, the controller can read and write 
buffer descriptors directly from/to the L2 cache, and even lock them 
into the L2.

Adding an abstraction for this to ethtool when there's only one driver 
that uses it seems premature.  If no other controllers implement such a 
feature, then ethtool is cluttered up with what amounts to 
driver-specific code.  If other controllers implement a similar 
feature, it's quite possible that the abstraction will need to change.  
Changing the abstraction (or adding a new one) can take up a 
significant amount of time, since the driver writer now has to modify 
the ethtool source, the ethtool kernel support, and then get the 
changes accepted.

I agree that, eventually, it would be the goal to implement an 
abstraction, and go through the process of getting the changes 
accepted, but not until there's a "market" for the abstraction.


>
> For the first case, of "cutting-edge" controller's, the best solution 
> is to
> always turn the feature on and make it work correctly.  If you can't 
> make it
> work correctly then use module parameter or chip set detection to turn 
> it off.
> Another option to expose warts is using sysfs attribute groups to add 
> additional
> fields to /sys/class/net/ethXX/.

Well, some features are a little more complex than on/off.  The 
stashing feature in the 85xx ethernet controllers allows a portion of 
each incoming packet to be extracted and placed directly in L2.  This 
has performance implications, and so it is useful to be able to tune 
the parameters at runtime.  Especially for benchmarking purposes, but 
also, once benchmarking has been done, to tune performance to the 
workload.

>
> When debugging a new driver, module parameters work find for 
> controlling
> test parameters.  If this needs to make into production code, sysfs 
> could
> also be used.

Module parameters are fine as long as you aren't trying to root your 
filesystem over NFS using the driver.

>
> This proposal is basically a device specific multiplexing interface 
> like
> ioctl or SIOCDEVPRIVATE. This style of interface is considered bad, and
> undesirable.

Well, yes... it uses ioctl and SIOCETHTOOL.  I can see how sysfs could 
be used to do everything I'm trying to do.  However, the same could be 
said about everything ethtool does.  Is ethtool no longer the correct 
tool to use for tuning ethernet performance?  I'm not philosophically 
opposed to the idea of supporting these features through sysfs, but it 
seems easier to be able to point people at ethtool for all their 
performance tuning needs.

Andy Fleming
Open Source Team
Freescale Semiconductor, Inc
