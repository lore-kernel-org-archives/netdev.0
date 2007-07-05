From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: Splitting e1000 (Was: Re: e1000: backport ich9 support from 7.5.5
 ?)
Date: Thu, 05 Jul 2007 11:32:27 -0700
Message-ID: <468D393B.2040503@intel.com>
References: <1183138159.17243.16.camel@blaa> <20070629175006.GB3917@falooley.org> <468571C6.3090305@garzik.org> <46857C08.4030303@intel.com> <20070629150350.414553d4.akpm@linux-foundation.org> <4685838D.9080108@garzik.org> <c0a09e5c0706291657kd5e4baawb113a17ca5ab2191@mail.gmail.com> <46859F3F.305@garzik.org> <4685C09B.7040908@intel.com> <20070630082520.GA20140@infradead.org> <468AD23A.4090904@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Christoph Hellwig <hch@infradead.org>,
	Andrew Grover <andy.grover@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Jason Lunz <lunz@reflexsecurity.com>,
	Mark McLoughlin <markmc@redhat.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	"Ronciak, John" <john.ronciak@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	'Stephen Hemminger' <shemminger@linux-foundation.org>,
	Andy Gospodarek <andy@greyhouse.net>,
	Arjan van de Ven <arjan@linux.intel.com>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:14215 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759022AbXGESco (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Jul 2007 14:32:44 -0400
In-Reply-To: <468AD23A.4090904@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kok, Auke wrote:
> Christoph Hellwig wrote:
>> On Fri, Jun 29, 2007 at 07:31:55PM -0700, Kok, Auke wrote:
>>> all the pci-express adapters that are supported are extremely similar:
>>>
>>> - they all support 2 queues
>>> - the register sets are (almost entirely) identical
>>> - there is minimal feature variance between 82571/2/3, esb2lan, ich8/9
>>>
>>> The major differences between 82571/2/3, esb2lan and ich8/9 are PHY-based 
>>> (4 different PHY's basically, one for 82571/2/3, one for esb2lan and 2 for 
>>> ich8/9, excluding fiber and serdes here) and NVM/EEPROM.
>>>
>>> ich8 and 9 are consistent with 82571/2/3 - on-board nic's based on the 
>>> 82571 design with different PHY's, and added features for the newer 
>>> demands. A driver split here would be possible but not justified IMHO.
>> Sounds like the perfect split to me.  I'd suggest you rip out support
>> for older hardware from your new driver and do the resulting simplification
>> and post a new e1000e driver for this hardware, removing existing support
>> from e1000 at the same time.  Later you can do the feature flags and similar
>> improvements to the old driver driver in an incremental fashion without the
>> burden of having to keep up with new hardware.
> 
> Jeff,
> 
> it seems that this is the preferred path to go including "e1000e" as the new 
> driver name for all 8257x family based adapters. Just for the record I'd like 
> your acknowledgement on the following plan:
> 
> 
> 1a) We post an e1000e driver that implements support for all 8257x (ich8/9, 
> es2lan etc) devices.
> 1b) We post a patch that drops support for all of these devices in the form of a 
> pci-ID removal (no code removed) for e1000.
> 
> 2) we post patches that remove code support for non-8254x devices at a later stage.
> 
> 3) we backport any and all cleanups and flags from e1000e to e1000 where applicable.
> 
> 
> This plan leaves a significant gap that I'm worrying about: after step (1) we 
> basically have forced everyone to switch without providing a fallback (allthough 
> we have our out-of-tree driver, but no in-kernel version in case issues exist).

Actually, this plan temporarily allows users to manually bind "e1000" to 
pci-express adapters in case they wish to do so, thereby providing a fallback 
driver for everyone.

If we leave the "e1000" driver untouched (not removing code support for pci-e 
adapters) for at least a full kernel release, this should be reasonable for 
everyone I hope. After we have gained some confidence in "e1000e" we can start 
removing code from "e1000" for pci-e adapters.

How does that sound?

Auke
