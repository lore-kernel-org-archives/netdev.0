From: Ben Greear <greearb@candelatech.com>
Subject: Re: [bonding] Add basic support for dynamic configuration of bond
 interfaces
Date: Sun, 11 Jan 2004 13:34:16 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4001C158.6040103@candelatech.com>
References: <E6F7D288B394A64585E67497E5126BA601F991D1@hasmsx403.iil.intel.com> <200401111628.07930.amir.noam@intel.com> <4001A667.2020904@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Amir Noam <amir.noam@intel.com>, bonding-devel@lists.sourceforge.net,
        netdev@oss.sgi.com, hadi@cyberus.ca
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <4001A667.2020904@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> Amir Noam wrote:
> 
>> The new SIOCBONDING ioctl handles commands aimed for the bonding 
>> module (and not to any specific bonding interface). This is done via 
>> an ioctl hook that captures these commands at the socket level (before 
>> dev_ioctl()) and passes it to the bonding code. Such commands do not 
>> require opening a bonding interface at all, just a valid socket to 
>> send the ioctl.
> 
> 
> Right.  And this last requirement is spurious.  The operation is 
> essentially "open a socket unrelated to X, to perform actions on X".
> 
> bonding (and it sounds like VLAN too) needs a specific, well-known 
> control point, for controlling module-level data such as the creation 
> and deletion of interfaces.
> 
> One such well-known control point would be a /dev node.  Jamal's 
> suggestion is also an excellent one:  let userspace use netlink to 
> communicate with a well known "address" inside the kernel, which would 
> work as the central (and thus bonding-module-wide) bonding control 
> interface.
> 
> 
>> I was trying to follow the example of several other network modules 
>> (e.g. vlan, dlci, bridge) that use a socket level ioctl hook to handle 
>> such deviceless commands.
>>
>> Do you think that a char device is preferrable, given that other 
>> similar modules use a socket ioctl hook?
> 
> 
> If vlan/dlci/bridge has similar requirements to described above ("open 
> socket unrelated to X, to perform actions on X") then they need to be 
> fixed up too.
> 
> Opening a random socket to use an ioctl(2) to produce some magic 
> behavior is just ugly, and we need to avoid that.  Maybe bgreear would 
> be open to updating VLAN's interface to netlink at the same time, for 

Actually, I am not a fan of netlink for normal configuration, and would
prefer to keep the VLAN control through IOCTL calls.  This is mainly
because I have not had an easy time of figuring out a simple way to
use netlink, while ioctls are very easy to use.

If someone wants to update vlan and vconfig to use netlink, then
maybe we could add that API as well, but definately we should not
remove the IOCTL calls untill at least 2.7.

I would also be open to moving the VLAN ioctls over into the
ethtool ioctl space, but that just exchanges one magic ioctl for
another...

Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
