From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [PATCH net-next 19/19] sfc: Add SR-IOV back-end support for SFC9000
 family
Date: Tue, 21 Feb 2012 11:52:04 -0800
Message-ID: <4F43F5E4.5000902@intel.com>
References: <1329352938.2565.26.camel@bwh-desktop>  <1329353550.2565.45.camel@bwh-desktop> <4F3C595A.3020401@intel.com> <1329357439.3048.115.camel@deadeye>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com,
	Shradha Shah <sshah@solarflare.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:30231 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752611Ab2BUTwG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Feb 2012 14:52:06 -0500
In-Reply-To: <1329357439.3048.115.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/15/2012 5:57 PM, Ben Hutchings wrote:
> On Wed, 2012-02-15 at 17:18 -0800, John Fastabend wrote:
>> On 2/15/2012 4:52 PM, Ben Hutchings wrote:
>>> On the SFC9000 family, each port has 1024 Virtual Interfaces (VIs),
>>> each with an RX queue, a TX queue, an event queue and a mailbox
>>> register.  These may be assigned to up to 127 SR-IOV virtual functions
>>> per port, with up to 64 VIs per VF.
>>>
>>> We allocate an extra channel (IRQ and event queue only) to receive
>>> requests from VF drivers.
>>>
>>> There is a per-port limit of 4 concurrent RX queue flushes, and queue
>>> flushes may be initiated by the MC in response to a Function Level
>>> Reset (FLR) of a VF.  Therefore, when SR-IOV is in use, we submit all
>>> flush requests via the MC.
>>>
>>> The RSS indirection table is shared with VFs, so the number of RX
>>> queues used in the PF is limited to the number of VIs per VF.
>>>
>>> This is almost entirely the work of Steve Hodgson, formerly
>>> shodgson@solarflare.com.
>>>
>>> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
>>> ---
>>
>> Hi Ben,
>>
>> So how would multiple VIs per VF work? Looks like each VI has a TX/RX
>> pair all bundled under a single netdev with some set of TX MAC filters.
> 
> They can be used to provide a multiqueue net device for use in multi-
> processor guests.

OK thanks its really just a multiqueue VF then. Calling it a virtual
interface seems a bit confusing here. For example it doesn't resemble
a VSI (Virtual Station Interface) per 802.1Q spec at all.

I'm guessing using this with a TX MAC/VLAN filter looks something like
Intel's VMDQ solutions.

> 
>> Do you expect users to build tc rules and edit the queue_mapping to get
>> the skb headed at the correct tx queue? Would it be better to model each
>> VI has its own net device.
> 
> No, we expect users to assign the VF into the guest.
> 

Got it.

.John
