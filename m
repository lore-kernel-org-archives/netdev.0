From: Will Jhun <wjhun@cisco.com>
Subject: Getting details about an 802.1q VLAN interface from userspace
Date: Thu, 13 Feb 2003 14:39:21 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030213143921.A21977@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: greearb@candelatech.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Dave,

As stated below, I'm looking for a way to get specifics about an 802.1q
VLAN interface from userspace. Currently, I listen to NEWLINK messages
over a netlink socket and classify the different types of interfaces. I
identify these VLAN devices by their name (e.g. "eth0.10", admittedly
not a good idea since the vlan netdev name formats can vary) and
existence in /proc/net/vlan/config. This seems kind of gross.

Is there a better way to get this information via netlink or some
ioctl()? Would it be useful if I (or someone) added an ioctl() type to
get information about a VLAN interface? (vlan, ifindex of trunking
(real_dev) interface, priority maps; basically the content of struct
vlan_dev_info)

Thanks,
William

----- Forwarded message from Ben Greear <greearb@candelatech.com> -----

Date: Thu, 13 Feb 2003 14:09:41 -0800
From: Ben Greear <greearb@candelatech.com>
To: Will Jhun <wjhun@cisco.com>
Subject: Re: Determining if a new interface is an 802.1q VLAN interface

Will Jhun wrote:
> Ben,
> 
> I have a program that listens for netlink NEWLINK updates and keeps
> track of interfaces in a system. I need to know if a new interface is an
> 802.1q VLAN interface and also what its trunking interface and vlan are.
> Right now, I'm just deducing these from the netdevice name and
> /proc/net/vlan/config, since it looks like the netdev's priv_flags is
> never exported to userspace, either by ioctl() or via netlink.
> 
> Is there a better way to do this?

The flag that determines if an interface can handle VLAN is not currently
exported to user-space through any ioctl that I know of.  Maybe we could
talk DaveM into adding such an ioctl?

The code would be simple enough if you could get Dave to accept it.

Please ask Dave, and CC me.  (I didn't want to forward your
email w/out permission...)

Ben

> 
> Thanks,
> William
> 


-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear



----- End forwarded message -----
