From: Ben Greear <greearb@candelatech.com>
Subject: Re: VLAN patch for 2.4.21
Date: Thu, 07 Aug 2003 08:49:32 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F32750C.4000600@candelatech.com>
References: <E791C176A6139242A988ABA8B3D9B38A014C9472@hasmsx403.iil.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Hen, Shmulik" <shmulik.hen@intel.com>
In-Reply-To: <E791C176A6139242A988ABA8B3D9B38A014C9472@hasmsx403.iil.intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hen, Shmulik wrote:
>>-----Original Message-----
>>From: Ben Greear [mailto:greearb@candelatech.com]
>>Sent: Thursday, August 07, 2003 10:28 AM
>>To: Hen, Shmulik
>>Cc: netdev@oss.sgi.com
>>Subject: Re: VLAN patch for 2.4.21
>>
>>
>>You can just check the things in the net_device struct directly
>>I imagine.  The calls I added are mainly to provide the info to
>>user-space.
> 
> 
> That was my guess too. I'll figure out a way to do that
> safely from kernel space.
> 
> 
>>What information do you need, and where do you need it?
> 
> 
> In bonding, to better handle self generated packets, I'll need
> to know what vlan ID's are on top of the bond device. So, I'll
> need to listen to net dev registration notifications and sort
> out which ones are for VLAN devices, and then see if they were
> added on top of a bond device. Once I've got that, I'll need to
> get the VID and store it in bonding, so both your additions
> do exactly what I need. I also heard from the bridge developers
> that they wanted similar support, so that's 2 birds...

If it's a VLAN device, it will have priv_flags & 0x1 turned on,
see dev->priv_flags and if.h for possible values that priv_flags
can have:

/* Private (from user) interface flags (netdevice->priv_flags). */
#define IFF_802_1Q_VLAN 0x1             /* 802.1Q VLAN device.          */


You can then get it's vlan-ID by looking for:

VLAN_DEV_INFO(dev)->vlan_id;

VLAN_DEV_INFO is defined in if_vlan.h as:

#define VLAN_DEV_INFO(x) ((struct vlan_dev_info *)(x->priv))

> 
> 
> 	Shmulik.
> 
> 


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
