From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [net-next PATCH v3] igbvf: add new driver to support 82576 virtual
 functions
Date: Wed, 25 Mar 2009 17:54:55 -0700
Message-ID: <49CAD25F.4080705@intel.com>
References: <20090325215248.28529.62295.stgit@lost.foo-projects.org>	<20090325150322.40e0a1e6@nehalam>	<49CAB13B.7070601@intel.com> <20090325.165847.234084422.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "shemminger@vyatta.com" <shemminger@vyatta.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:32866 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750911AbZCZAy7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Mar 2009 20:54:59 -0400
In-Reply-To: <20090325.165847.234084422.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Alexander Duyck <alexander.h.duyck@intel.com>
> Date: Wed, 25 Mar 2009 15:33:31 -0700
> 
>> The sysfs part of this is already in net-next as it isn't part of
>> the igbvf driver it is part of igb.  It was added in over a month
>> ago: http://patchwork.ozlabs.org/patch/23471/
>>
>> I will see what we can do to make use of a netlink interface.  I'm
>> honestly not even sure if it will work well for this kind of setup
>> since the VF driver won't even be running on the same OS in most
>> cases.  For now the sysfs code in igb is actually quite minimal, and
>> the main goal was to keep the interface as simple as possible which
>> is what I have done.
> 
> I have to agree with Stephen that the way to create new links
> of virtual and similar devices is to use rtnl_link.
> 
> We have very good infrastructure for this, and if I understand
> things correctly iproute2 might even work with an igb using
> rtnl_link with zero modifications to the tool sources.
> 
> Please fix this up, it's a very reasonable request for such
> a large new piece of driver infrastructure.  And since this is
> a new driver, you have no time constraints for submission either.
> 

Thanks for allowing me more time, but the issue isn't the igbvf driver. 
  The part that Stephen is referencing will be an issue in the igb 
driver.  That is why I pointed him to 
http://patchwork.ozlabs.org/patch/23471/ since it is the part that 
contains the code that he has issues with.

Since the issue isn't the igbvf driver there is no reason for it to be 
held up.  If you want to revert the offending patch feel free to and 
what I will do is send a patch out that just statically set the number 
of VFs to 7 if the kernel and device supports enabling SR-IOV.  I didn't 
want to take that approach since it means that it disables multi-queue 
for igb on those devices but I feel like I have been backed into a 
corner on this and don't have many other options.

Thanks,

Alex











