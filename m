From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [RFC] ixgbe: is DCA really that good ?
Date: Wed, 06 Apr 2011 10:05:30 -0700
Message-ID: <4D9C9D5A.4030500@intel.com>
References: <1302097444.3209.85.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Brattain, Ross B" <ross.b.brattain@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:1634 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754587Ab1DFRFb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Apr 2011 13:05:31 -0400
In-Reply-To: <1302097444.3209.85.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/6/2011 6:44 AM, Eric Dumazet wrote:
> Hi guys
>
>
> In a forwarding [or RPS/RFS] setup, why should we populate cpu caches
> with full frames content ? We only need first cache line to perform
> routing [or RPS/RFS] decision.
>
> ->  DCA should be a knob (ethtool ?) that an admin can switch off and on,
> port by port, not a CONFIG_IXGBE_DCA thing.
>
> Thanks

The problem is the implementation essentially makes it so that DCA is 
controlled by the availability of the DCA providers.  What would 
probably be the best solution would be for the DCA provider to have a 
means of shutting down specific devices.

The quick and dirty way to disable DCA is to rmmod the ioatdma module 
from the system.  With that removed it will remove the DCA provider and 
essentially turn off DCA.

Thanks,

Alex
