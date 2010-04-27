From: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Subject: Re: [net-next-2.6 PATCH 1/2] Add ndo_set_vf_port_profile
Date: Tue, 27 Apr 2010 10:33:04 -0700
Message-ID: <8966E338-1C9C-43D9-B6A3-A44349E7EE18@qlogic.com>
References: <C7FB77DB.2BC42%scofeldm@cisco.com>
 <201004271435.25480.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Scott Feldman <scofeldm@cisco.com>,
	"Rose, Gregory V" <gregory.v.rose@intel.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"chrisw@redhat.com" <chrisw@redhat.com>,
	"Williams, Mitch A" <mitch.a.williams@intel.com>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexcashub1.qlogic.com ([198.70.193.61]:47190 "EHLO
	avexcashub1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756004Ab0D0RdG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Apr 2010 13:33:06 -0400
In-Reply-To: <201004271435.25480.arnd@arndb.de>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Apr 27, 2010, at 5:35 AM, Arnd Bergmann wrote:

> On Tuesday 27 April 2010, Scott Feldman wrote:
>>> Yes, I believe that's there today:
>>> 
>>>    NLA_PUT_U32(skb, IFLA_NUM_VF, dev_num_vf(dev->dev.parent));
>>> 
>>> The number of VFs is returned in RTM_GETLINK.  But, it's only returned if:
>>> 
>>>    if (dev->netdev_ops->ndo_get_vf_config && dev->dev.parent)
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

Correct me if I am wrong. Shouldn't the port profile be tied to the physical NICs which are essentially
PCI functions (be it PF or VF)? I'd think that a port profile would have configuration settings for all the
physical NICs (PF/VF) of a specific physical port of the adapter. I liked the idea of querying the device
for number of VFs as it will cover both SR-IOV and non SR-IOV PCI functions.

thanks,
-Anirban