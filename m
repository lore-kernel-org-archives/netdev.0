From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [bonding] Add basic support for dynamic configuration of bond
 interfaces
Date: Sat, 10 Jan 2004 20:34:48 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4000A838.5040808@pobox.com>
References: <200401081819.54484.amir.noam@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <fubar@us.ibm.com>, bonding-devel@lists.sourceforge.net,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Amir Noam <amir.noam@intel.com>
In-Reply-To: <200401081819.54484.amir.noam@intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Amir Noam wrote:
> The following patch sets provide basic support for future bonding 
> operations (specifically for dynamic configuration of bonding 
> interfaces).
> 
> This is done by adding two new bonding ioctls: one for deviceless 
> commands (an ioctl hook) and one for device oriented commands. Like 
> ethtool, the first u32 value in the data structure will indicate the 
> exact sub-command to be executed.
> 
> The sets are against the latest netdev-2.4 and net-drivers-2.5-exp 
> trees.


I don't disagree with the overall goal of these patches, but I think we 
might need to pause a bit, and consider how best to configure, add, and 
remove bonding interfaces, if we are coming up with a new interface.

For configuration tasks that occur outside the scope of a single bonding 
interface (i.e. a single struct net_device), you need a separate entity 
from a socket ioctl.  It's not ideal at all to configure N objects using 
a special ioctl ... when opening one of said objects :)

I would suggest a simple character device (misc_register), and let the 
userland application configure settings unrelated to a single object.

For a configuring state related to a _single_ bonding interface (i.e. a 
single net_device), socket ioctls are OK.

	Jeff
