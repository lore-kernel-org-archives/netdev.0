From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [net-next PATCH v3] igbvf: add new driver to support 82576 virtual
 functions
Date: Wed, 25 Mar 2009 15:33:31 -0700
Message-ID: <49CAB13B.7070601@intel.com>
References: <20090325215248.28529.62295.stgit@lost.foo-projects.org> <20090325150322.40e0a1e6@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:35449 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753890AbZCYWd5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Mar 2009 18:33:57 -0400
In-Reply-To: <20090325150322.40e0a1e6@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> On Wed, 25 Mar 2009 14:52:48 -0700
> Jeff Kirsher <jeffrey.t.kirsher@intel.com> wrote:
> 
>> From: Alexander Duyck <alexander.h.duyck@intel.com>
>>
>> This adds an igbvf driver to handle virtual functions provided by the
>> igb driver when SR-IOV has been enabled.  A virtual function is a
>> lightweight pci-e function that supports a single queue and shares
>> resources with the 82576 physical function contained within the igb
>> driver.
>>
>> To spawn virtual functions from the igb driver all that is needed is to
>> issue a echo X > /sys/class/ethY/num_vfs.  X can be a value between 0 and
>> 7, 0 will disable SR-IOV functionality for the port and is the default.  If
>> the num_vfs sysfs entry is not present then the device does not have SR-IOV
>> capability enabled either in software or hardware.
>>
>> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
>> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> 
> Please don't use sysfs for this.
> Instead build a proper rtnl_link netlink interface (see macvlan).
> 
> Intel doesn't invent unique hardware, other vendors will do the same
> thing (or follow your lead), so doing it right the first time for these
> kind of devices makes sense.

The sysfs part of this is already in net-next as it isn't part of the 
igbvf driver it is part of igb.  It was added in over a month ago:
http://patchwork.ozlabs.org/patch/23471/

I will see what we can do to make use of a netlink interface.  I'm 
honestly not even sure if it will work well for this kind of setup since 
the VF driver won't even be running on the same OS in most cases.  For 
now the sysfs code in igb is actually quite minimal, and the main goal 
was to keep the interface as simple as possible which is what I have done.

We are already planning to make a number of changes to support Host 
configuration of the guest interfaces for 2.6.31, and a number of those 
included sysfs entries that I had rejected for this release.  What I can 
probably do is see about trying to make all of those changes be pushed 
over to a netlink interface since it would make much more sense when we 
have multiple items to configure other than just setting the number of VFs.

Thanks,

Alex
