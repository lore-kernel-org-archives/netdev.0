From: Amir Noam <amir.noam@intel.com>
Subject: Re: [bonding] Add basic support for dynamic configuration of bond interfaces
Date: Sun, 11 Jan 2004 16:28:07 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200401111628.07930.amir.noam@intel.com>
References: <E6F7D288B394A64585E67497E5126BA601F991D1@hasmsx403.iil.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <bonding-devel@lists.sourceforge.net>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "Jeff Garzik" <jgarzik@pobox.com>
In-Reply-To: <E6F7D288B394A64585E67497E5126BA601F991D1@hasmsx403.iil.intel.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sunday 11 January 2004 03:34 am, Jeff Garzik wrote:
> Amir Noam wrote:
> > The following patch sets provide basic support for future bonding
> > operations (specifically for dynamic configuration of bonding
> > interfaces).
> >
> > This is done by adding two new bonding ioctls: one for deviceless
> > commands (an ioctl hook) and one for device oriented commands.
> > Like ethtool, the first u32 value in the data structure will
> > indicate the exact sub-command to be executed.
> >
> > The sets are against the latest netdev-2.4 and
> > net-drivers-2.5-exp trees.
>
> I don't disagree with the overall goal of these patches, but I
> think we might need to pause a bit, and consider how best to
> configure, add, and remove bonding interfaces, if we are coming up
> with a new interface.
>
>
> For configuration tasks that occur outside the scope of a single
> bonding interface (i.e. a single struct net_device), you need a
> separate entity from a socket ioctl.  It's not ideal at all to
> configure N objects using a special ioctl ... when opening one of
> said objects :)

That's not exactly what the new ioctls do.

The new SIOCBONDING ioctl handles commands aimed for the bonding 
module (and not to any specific bonding interface). This is done via 
an ioctl hook that captures these commands at the socket level 
(before dev_ioctl()) and passes it to the bonding code. Such commands 
do not require opening a bonding interface at all, just a valid 
socket to send the ioctl.

Also, such commands do not configure N other objects (like bonding 
interfaces) at all. They are used explicitly for "deviceless" 
commands, like dynamically adding and removing a bonding interface 
from the system.

> I would suggest a simple character device (misc_register), and let
> the userland application configure settings unrelated to a single
> object.

I was trying to follow the example of several other network modules 
(e.g. vlan, dlci, bridge) that use a socket level ioctl hook to 
handle such deviceless commands.

Do you think that a char device is preferrable, given that other 
similar modules use a socket ioctl hook?

> For a configuring state related to a _single_ bonding interface
> (i.e. a single net_device), socket ioctls are OK.

For such configuration commands (aimed at a specific bonding 
interface) I've added the SIOCBONDDEVICE ioctl, which is designed to 
be extendable to more commands in the future.

-- 
Amir
