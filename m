From: Ben Greear <greearb@candelatech.com>
Subject: Re: netdev_ops?
Date: Wed, 23 Jul 2003 00:28:27 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F1E391B.80209@candelatech.com>
References: <3F1E17BC.30100@candelatech.com>	<20030722220745.379a73c6.davem@redhat.com>	<3F1E1D62.90009@candelatech.com>	<20030722230215.284dd270.davem@redhat.com>	<3F1E2A00.5080506@candelatech.com>	<20030722232719.216d7823.davem@redhat.com>	<3F1E2CE9.2080404@candelatech.com> <20030723000130.3a6a917e.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030723000130.3a6a917e.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> On Tue, 22 Jul 2003 23:36:25 -0700
> Ben Greear <greearb@candelatech.com> wrote:
> 
> 
>>I am not writing drivers, I'm trying to write code that works with
>>everything that looks remotely like an ethernet device.
> 
> 
> Making ethtool interfaces available on every net device is not right,
> what about the ISDN folks?  What if they specifically want ethtool
> ioctls to fail for their devices?  How can one accomplish that after
> your changes?
> 
> Answer: You can't.

In my case, if the net_device can return net_device_stats, then I want it to work.
If it can't, -ENOTSUPP is returned.  I cannot fathom a reason for this
in itself to harm anyone.  As you noticed below, existing code would never
try this ioctl, and new code can likewise ignore it if it cannot handle
the consequences.

> Whatever tools you write which depend upon this will not work
> on any existing 2.4.x kernel, therefore making their utility
> basically NIL.

That can be said for every new feature or ioctl.  Of course
it won't work with older stuff...but it will work with newer
stuff, and I'm smart enough to be able to fall back to the
less efficient parsing of /proc/net/dev if the ioctls are
not supported.  Anyone else that cares can write programs just
as clever.


> What is this "other platform" issue?
> 
> If you add anything new, along the lines of SIOCDEVETHTOOl, it's
> going to have to go through an entire full review process and in
> that review process any necessary 32-bit ioctl translation code
> would get added.

Yes, and since I am ignorant of that stuff, and have no hardware to
test with, then I want to avoid it.  I can't imagine I'm the
only one.  Overloading the ethtool ioctl is one way to avoid that pain..adding
a new, similar ioctl would also work, but seems like duplicated
effort to me.

Since it seems very unlikly that this sort of patch will be accepted
in the near future, how _DO_ you want to see new features added that
require configuration (and reading) from user space?  IOCTLs are easy to add on x86
at least, but maybe you'd prefer some text based proc interface instead?

Ben

-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear
