From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [RFC PATCH] net: Add support for virtual machine device queues
 (VMDQ)
Date: Sun, 26 Aug 2012 12:09:22 -0700
Message-ID: <503A7462.1030803@intel.com>
References: <20120718220544.22619.97136.stgit@i40e.jf1> <CAJZOPZJBhDdQp2-8WG-UsToPHwyawYYVctqjZMT8JN85DK3XYQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, roland@kernel.org, netdev@vger.kernel.org,
	ali@mellanox.com, sean.hefty@intel.com, shlomop@mellanox.com
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:15433 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752658Ab2HZTJY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 26 Aug 2012 15:09:24 -0400
In-Reply-To: <CAJZOPZJBhDdQp2-8WG-UsToPHwyawYYVctqjZMT8JN85DK3XYQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/26/2012 6:11 AM, Or Gerlitz wrote:
> On Thu, Jul 19, 2012 at 1:05 AM, John Fastabend
> <john.r.fastabend@intel.com> wrote:
>> This adds support to allow virtual net devices to be created. These
>> devices can be managed independently of the physical function but
>> use the same physical link.
>>
>> This is analogous to an offloaded macvlan device. The primary
>> advantage to VMDQ net devices over virtual functions is they can
>> be added and removed dynamically as needed.
>
> Hi John,
>
> When VMDQ devices are opened over a virtual function which is
> assigned to guest, the design should include a way to apply the
> following ndo_set_vf_yyy  calls to them
>
> int (*ndo_set_vf_mac)(struct net_device *dev, int vf, u8* mac);
> int (*ndo_set_vf_vlan)(struct net_device *dev, int vf, u16 vlan, u8 qos);
> int (*ndo_set_vf_tx_rate)(struct net_device *dev, int vf, int rate);
> int (*ndo_set_vf_spoofchk)(struct net_device *dev, int vf, bool setting);
>
>
> Someone here suggested using a sub-index notation, that is m.n
> represents vmdq device index = n on VF index = m where vf.0 is
> the non vmdq VF device, makes sense? other thoughts?
>
> Or.
>

That seems reasonable to me. Adding a 'sub' argument to the set
routines should do it. Also the 'get' routines would need to be
extended to report back these virtual net devices.

int (*ndo_set_vf_mac)(struct net_device *dev, int vf, int sub, u8* mac);
int (*ndo_set_vf_vlan)(struct net_device *dev,
		       int vf, int sub,
		       u16 vlan, u8 qos);
int (*ndo_set_vf_tx_rate)(struct net_device *dev,
			  int vf, int sub,
			  int rate);
int (*ndo_set_vf_spoofchk)(struct net_device *dev,
			   int vf, int sub,
			   bool setting);
int (*ndo_get_vf_config)(struct net_device *dev,
			 int vf, int sub,
			 struct fila_vf_info *ivf)


I would need to check if any of the ixgbe/igb supported hardware can
support virtual device queues on virtual functions like this but I
presume if your looking at this you have some hardware that can.

I was hoping to get back to this in September, of course if someone
beats me to it that would be great also.

.John
