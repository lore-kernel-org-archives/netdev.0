From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [rfc 4/4] igb: expose 82576 bandiwidth allocation
Date: Thu, 05 Nov 2009 15:42:28 -0800
Message-ID: <4AF362E4.3040507@intel.com>
References: <20091105005847.941190065@vergenet.net> <20091105010628.148945886@vergenet.net> <4AF358F2.9000109@intel.com> <20091105233034.GA9588@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	Arnd Bergmann <arndbergmann@googlemail.com>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:62293 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758405AbZKEXmX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Nov 2009 18:42:23 -0500
In-Reply-To: <20091105233034.GA9588@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Simon Horman wrote:
> On Thu, Nov 05, 2009 at 03:00:02PM -0800, Alexander Duyck wrote:
>> Simon Horman wrote:
>>> The 82576 has support for bandwidth allocation to VFs.
>>>
>>> Contrary to the documentation in the 82576 datasheet v2.41 this
>>> appears to work as follows:
>>>
>>> * The ratio supplied is always proportional to 1Gbit/s,
>>>  regardless of if the link speed.
>>> * The ratio supplied is an upper-bound on bandwidth available
>>>  to the VF, not a minimun guarantee
>>>
>>> This patch exposes bandwidth control to userspace through a simple
>>> per-device (PF) sysfs file, bandwidth_allocation.
>>>
>>> * The file contains a whitespace delimited list of values, one per VF.
>>> * The first value corresponds to the first VF and so on.
>>> * Valid values are integers from 0 to 1000
>>> * A value of 0 indicates that bandwidth_allocation is disabled.
>>> * Other values indicate the allocated bandwidth, in 1/1000ths of a gigabit/s
>>>
>>> e.g. The following for a PF with 4 VFs allocates ~20Mbits/ to VF 1,
>>>     ~100Mbit/s to VF 2, and leave the other 2 VFs with no allocation.
>>>
>>>     echo "20 100 0 0" > /sys/class/net/eth3/device/bandwidth_allocation
>>>
>>> This interface is intended to allow testing of the hardware feature.
>>> There are ongoing discussions about how to expose this feature
>>> to user-space in a more generic way.
>>>
>>> Signed-off-by: Simon Horman <horms@verge.net.au>
>>>
>> Of the patches it looks like the only one that really has any issues
>> is this one and it is mostly due to the sysfs implementation.  The
>> others I would say can be applied and pushed up into the
>> net-next-2.6 tree.
> 
> Thanks, I suspected as much.
> 
>> We're currently working on an iproute2 based solution for
>> configuring VFs and can incorporate this functionality into it at
>> some point in the future.
> 
> Do you have any pointers to discussions relating to that interface.
> Do you think it would be worth putting in the sysfs interface in the
> mean-time, or would you rather wait?

I'm not the one working on the interface so I don't know much about it 
other than the fact it is being worked on.  Hopefully we should see 
something in regards to that soon though.

If anything it might be of some use to split this up into 2 patches. 
One that contains the sysfs bits, and another for enabling the bandwidth 
control registers.  We won't be able to get the sysfs interface accepted 
upstream so there isn't much point in us keeping it around for any other 
purpose than testing to verify the registers work as you have described.

Thanks,

Alex
