From: Scott Feldman <scofeldm@cisco.com>
Subject: Re: [net-next-2.6 PATCH 1/2] Add ndo_set_vf_port_profile
Date: Tue, 27 Apr 2010 13:57:16 -0700
Message-ID: <C7FC9DBC.2C218%scofeldm@cisco.com>
References: <201004271435.25480.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: "Rose, Gregory V" <gregory.v.rose@intel.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"chrisw@redhat.com" <chrisw@redhat.com>,
	"Williams, Mitch A" <mitch.a.williams@intel.com>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-1.cisco.com ([171.71.176.70]:49393 "EHLO
	sj-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756894Ab0D0U5S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Apr 2010 16:57:18 -0400
In-Reply-To: <201004271435.25480.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/27/10 5:35 AM, "Arnd Bergmann" <arnd@arndb.de> wrote:

> On Tuesday 27 April 2010, Scott Feldman wrote:
>>> Yes, I believe that's there today:
>>> 
>>>     NLA_PUT_U32(skb, IFLA_NUM_VF, dev_num_vf(dev->dev.parent));
>>> 
>>> The number of VFs is returned in RTM_GETLINK.  But, it's only returned if:
>>> 
>>>     if (dev->netdev_ops->ndo_get_vf_config && dev->dev.parent)
>>> 
>>> For my proposal, I'll need to return IFLA_NUM_VF unconditionally so callers
>>> can get num VFs.
>> 
>> Hmmm...seems IFLA_NUM_VF assumes a PCI device supporting SR-IOV when it uses
>> dev_num_vf().  I think a better option would have been to query the device
>> for the number of VFs, without assuming SR-IOV or even PCI.
>> 
>> I see a ndo_get_num_vf() coming...
> 
> Shouldn't the number of registered port profiles be totally independent of
> the number of virtual functions?
> 
> Any of the VFs could multiplex multiple guests using macvlan, which means you
> need to register each guest separately, not each VF.
> 
> Anything that ties port profiles to VFs seems fundamentally flawed AFAICT,
> at least when we want to extend this to adapters that don't do it in firmware.

Ya, I tend I agree.  Let's just make port-profile a setting of any netdev,
an eth, macvtap, eth.x, bond, etc.  That's probably what I should have done
in the first place.  Something like:

       ip link set DEVICE [ { up | down } ]
                          [ arp { on | off } ]
                            <...clip...>
                          [ alias NAME ]
                          [ vf NUM [ mac LLADDR ]
                                   [ vlan VLANID [ qos VLAN-QOS ] ]
                                   [ rate TXRATE ] ]
                          [ port_profile [ PORT-PROFILE
                                   [ mac LLADDR ]
                                   [ host_uuid HOST_UUID ]
                                   [ client_uuid CLIENT_UUID ]
                                   [ client_name CLIENT_NAME ] ] ] ]
       ip link show [ DEVICE ]

I think I was trying to be too accommodating for models with VFs, but it
doesn't matter like you point out.

This way, I can get the RTM_GETLINK to return the port-profile in use.

New patches coming soon...

-scott

