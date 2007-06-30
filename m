From: James Chapman <jchapman@katalix.com>
Subject: Re: e1000: backport ich9 support from 7.5.5 ?
Date: Sat, 30 Jun 2007 15:31:10 +0100
Message-ID: <4686692E.5080604@katalix.com>
References: <1183138159.17243.16.camel@blaa>	 <20070629175006.GB3917@falooley.org> <468571C6.3090305@garzik.org>	 <46857C08.4030303@intel.com>	 <20070629150350.414553d4.akpm@linux-foundation.org>	 <4685838D.9080108@garzik.org> <c0a09e5c0706291657kd5e4baawb113a17ca5ab2191@mail.gmail.com> <46859F3F.305@garzik.org> <4685C09B.7040908@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>,
	Andrew Grover <andy.grover@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Jason Lunz <lunz@reflexsecurity.com>,
	Mark McLoughlin <markmc@redhat.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s36.avahost.net ([74.53.95.194]:45760 "EHLO s36.avahost.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757455AbXF3Obd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 30 Jun 2007 10:31:33 -0400
In-Reply-To: <4685C09B.7040908@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kok, Auke wrote:
> Jeff Garzik wrote:
>> Can knowledgeable people characterize the PCIe adapters somehow?  Is 
>> that "ICH8-era and later", or does it go back further than that?
> 
> ich8 and 9 are consistent with 82571/2/3 - on-board nic's based on the 
> 82571 design with different PHY's, and added features for the newer 
> demands. A driver split here would be possible but not justified IMHO.
>
 > if you want a quick view of features by chipset type, open the patch
 > and search forward to /e1000_setup_flags/.

I briefly looked over your new driver. I think it might benefit by 
moving common parts into one or more libraries (or modules) and have 
separate chip-specific drivers for 82540, 82541, 82542, 82543, 82571 
etc. Put all the chip-specific bits in a chip-specific driver and have 
each driver call into the common (shared) code. The device 
probe/init/remove would be done by the chip-specific code, not the 
common code like it is now. When built as a module, the chip-specific 
parts and the common parts could be built as separate modules; modprobe 
would load the common parts automatically. Most of the code would be in 
the common part since these chips are very similar.

Doing the above would lead naturally to a series of patches which will 
make it easier to review. When Intel release a new device variant in the 
future, it might be supported by a new, small driver rather than needing 
modifications to one big monolith. Also, the kernel would be loaded with 
only the code it needed to support the specific device(s) present.

BTW, since you're doing a major update, would it be a good time to 
switch to phylib to manage your PHYs?

-- 
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development

