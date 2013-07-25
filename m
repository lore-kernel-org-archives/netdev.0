From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [patch net-next v4 4/4] igb/igbvf: implement ndo_get_phys_port_id
Date: Thu, 25 Jul 2013 11:00:06 -0700
Message-ID: <51F167A6.808@intel.com>
References: <1374757385-10875-1-git-send-email-jiri@resnulli.us>  <1374757385-10875-5-git-send-email-jiri@resnulli.us>  <51F14F9F.1010703@intel.com> <1374770653.3058.9.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
	davem@davemloft.net, stephen@networkplumber.org,
	Narendra_K@Dell.com, john.r.fastabend@intel.com,
	or.gerlitz@gmail.com, jeffrey.t.kirsher@intel.com,
	jesse.brandeburg@intel.com, bruce.w.allan@intel.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	gregory.v.rose@intel.com, peter.p.waskiewicz.jr@intel.com,
	john.ronciak@intel.com, tushar.n.dave@intel.com,
	matthew.vick@intel.com, mitch.a.williams@intel.com,
	vyasevic@redhat.com, amwang@redhat.com, johannes@sipsolutions.net
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:23261 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932389Ab3GYSEa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Jul 2013 14:04:30 -0400
In-Reply-To: <1374770653.3058.9.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/25/2013 09:44 AM, Ben Hutchings wrote:
> On Thu, 2013-07-25 at 09:17 -0700, Alexander Duyck wrote:
>> On 07/25/2013 06:03 AM, Jiri Pirko wrote:
>>> @@ -1982,6 +2001,21 @@ static s32 igb_init_i2c(struct igb_adapter *adapter)
>>>  	return status;
>>>  }
>>>  
>>> +static void igb_compute_phys_port_id(struct igb_adapter *adapter)
>>> +{
>>> +	adapter->phys_port_id = *((u32 *) adapter->netdev->dev_addr);
>>> +	adapter->phys_port_id ^= *((u32 *) adapter->netdev->dev_addr + 4);
>>> +	adapter->phys_port_id ^= (long) adapter;
>>> +	adapter->phys_port_id ^= (long) adapter->hw.hw_addr;
>>> +	adapter->phys_port_id ^= (long) adapter->hw.flash_address;
>>> +	adapter->phys_port_id ^= (u32) adapter->hw.io_base;
>>> +	adapter->phys_port_id ^= adapter->hw.device_id;
>>> +	adapter->phys_port_id ^= adapter->hw.subsystem_vendor_id;
>>> +	adapter->phys_port_id ^= adapter->hw.subsystem_device_id;
>>> +	adapter->phys_port_id ^= adapter->hw.vendor_id;
>>> +	adapter->phys_port_id ^= adapter->hw.revision_id;
> I didn't look at Jiri's patch initially, but... what's wrong with using
> the MAC address from NVRAM (should already be in netdev->perm_addr)?
> That's what I'm expecting to do for the SFC9000 family in sfc.
>
>>> +}
>>> +
>>>  /**
>>>   *  igb_probe - Device Initialization Routine
>>>   *  @pdev: PCI device information struct
>> I really think this bit here should be standardized and made available
>> to all drivers.
> [...]
>
> I think it's a bad example and should not be used in any drivers!
>
> Ben.
>

I agree.  That is why the second paragraph started listing what was
wrong with this implementation.  What I said was meant in the more
general sense that whatever solution should be used should be the same
across multiple drivers, not up to each driver to compute.

Thanks,

Alex
