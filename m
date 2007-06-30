From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: e1000: backport ich9 support from 7.5.5 ?
Date: Sat, 30 Jun 2007 09:29:21 -0700
Message-ID: <468684E1.6080901@intel.com>
References: <1183138159.17243.16.camel@blaa>	 <20070629175006.GB3917@falooley.org> <468571C6.3090305@garzik.org>	 <46857C08.4030303@intel.com>	 <20070629150350.414553d4.akpm@linux-foundation.org>	 <4685838D.9080108@garzik.org> <c0a09e5c0706291657kd5e4baawb113a17ca5ab2191@mail.gmail.com> <46859F3F.305@garzik.org> <4685C09B.7040908@intel.com> <4686692E.5080604@katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>,
	Jeff Garzik <jeff@garzik.org>,
	Andrew Grover <andy.grover@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Jason Lunz <lunz@reflexsecurity.com>,
	Mark McLoughlin <markmc@redhat.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:16019 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754440AbXF3Q33 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 30 Jun 2007 12:29:29 -0400
In-Reply-To: <4686692E.5080604@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

James Chapman wrote:
> Kok, Auke wrote:
>> Jeff Garzik wrote:
>>> Can knowledgeable people characterize the PCIe adapters somehow?  Is 
>>> that "ICH8-era and later", or does it go back further than that?
>> ich8 and 9 are consistent with 82571/2/3 - on-board nic's based on the 
>> 82571 design with different PHY's, and added features for the newer 
>> demands. A driver split here would be possible but not justified IMHO.
>>
>  > if you want a quick view of features by chipset type, open the patch
>  > and search forward to /e1000_setup_flags/.
> 
> I briefly looked over your new driver. I think it might benefit by 
> moving common parts into one or more libraries (or modules) and have 
> separate chip-specific drivers for 82540, 82541, 82542, 82543, 82571 
> etc. Put all the chip-specific bits in a chip-specific driver and have 
> each driver call into the common (shared) code. The device 
> probe/init/remove would be done by the chip-specific code, not the 
> common code like it is now. When built as a module, the chip-specific 
> parts and the common parts could be built as separate modules; modprobe 
> would load the common parts automatically. Most of the code would be in 
> the common part since these chips are very similar.

splitting beyond the obvious does not make any sense and will just add 
confusion. I'm not against a pcie/pre-pcie split or even going a step further 
and looking into using PHYlib as you suggest below, but we should really avoid 
trying to create an unmaintainable mess where we have to patch 7 drivers for 
each generic issue we find.

> Doing the above would lead naturally to a series of patches which will 
> make it easier to review. When Intel release a new device variant in the 
> future, it might be supported by a new, small driver rather than needing 
> modifications to one big monolith. Also, the kernel would be loaded with 
> only the code it needed to support the specific device(s) present.
> 
> BTW, since you're doing a major update, would it be a good time to 
> switch to phylib to manage your PHYs?

well, PHYlib might help, so I'm not negative against doing that right now. It 
will be quite some work.

Auke

