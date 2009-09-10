From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: L2 switching in igb
Date: Thu, 10 Sep 2009 10:30:09 -0700
Message-ID: <4AA937A1.9070504@intel.com>
References: <Pine.LNX.4.64.0909031116070.22050@zuben.voltaire.com> <5f2db9d90909032135l26cfdba6n52329f6be75c16a5@mail.gmail.com> <4AA8B317.2080706@voltaire.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Fischer, Anna" <anna.fischer@hp.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: Or Gerlitz <ogerlitz@voltaire.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:8198 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752866AbZIJRaH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Sep 2009 13:30:07 -0400
In-Reply-To: <4AA8B317.2080706@voltaire.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Or Gerlitz wrote:
> Note that VEPA mode is a characteristic of the PF, correct? and the PF 
> resides in the host kernel. Also, as I wrote you earlier, I do see many 
> schemes where a VF spawned in the host kernel IS very useful, and as 
> such I'd be happy to continue the discussion on the approach suggested 
> by Dave and Stephen, can you provide a pointer? (thanks).
> 
> Or.

You are correct, the vSwitch can basically do VEPA by disabling local 
loopback enable bit in the DTXSWC register.  This would force all 
traffic from the PF/VFs out the lan physical port and from the lan 
physical port to the appropriate PF/VFs without doing any switching in 
between PF/VFs.

I am currently thinking what probably needs to be done is to add an 
rtnl_link_ops interface to handle vSwitch configuration that could then 
be applied to the igb netdevs that support VEPA/vSwitch technologies.  A 
subset of that interface could then be dedicated to VF configuration to 
handle things such as spawning VFs, setting the default mac addresses, 
security controls, etc.

Thanks,

Alex

