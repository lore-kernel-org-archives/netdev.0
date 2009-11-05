From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [rfc 4/4] igb: expose 82576 bandiwidth allocation
Date: Thu, 05 Nov 2009 15:00:02 -0800
Message-ID: <4AF358F2.9000109@intel.com>
References: <20091105005847.941190065@vergenet.net> <20091105010628.148945886@vergenet.net>
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
Received: from mga02.intel.com ([134.134.136.20]:62721 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751762AbZKEW75 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Nov 2009 17:59:57 -0500
In-Reply-To: <20091105010628.148945886@vergenet.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Simon Horman wrote:
> The 82576 has support for bandwidth allocation to VFs.
> 
> Contrary to the documentation in the 82576 datasheet v2.41 this
> appears to work as follows:
> 
> * The ratio supplied is always proportional to 1Gbit/s,
>   regardless of if the link speed.
> * The ratio supplied is an upper-bound on bandwidth available
>   to the VF, not a minimun guarantee
> 
> This patch exposes bandwidth control to userspace through a simple
> per-device (PF) sysfs file, bandwidth_allocation.
> 
> * The file contains a whitespace delimited list of values, one per VF.
> * The first value corresponds to the first VF and so on.
> * Valid values are integers from 0 to 1000
> * A value of 0 indicates that bandwidth_allocation is disabled.
> * Other values indicate the allocated bandwidth, in 1/1000ths of a gigabit/s
> 
> e.g. The following for a PF with 4 VFs allocates ~20Mbits/ to VF 1,
>      ~100Mbit/s to VF 2, and leave the other 2 VFs with no allocation.
> 
>      echo "20 100 0 0" > /sys/class/net/eth3/device/bandwidth_allocation
> 
> This interface is intended to allow testing of the hardware feature.
> There are ongoing discussions about how to expose this feature
> to user-space in a more generic way.
> 
> Signed-off-by: Simon Horman <horms@verge.net.au>
> 

Of the patches it looks like the only one that really has any issues is 
this one and it is mostly due to the sysfs implementation.  The others I 
would say can be applied and pushed up into the net-next-2.6 tree.

We're currently working on an iproute2 based solution for configuring 
VFs and can incorporate this functionality into it at some point in the 
future.

Thanks,

Alex
