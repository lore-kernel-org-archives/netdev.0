From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [E1000-devel] discussion questions: SR-IOV, virtualization, and
 bonding
Date: Thu, 02 Aug 2012 21:50:06 -0700
Message-ID: <501B587E.6040703@intel.com>
References: <501AD33E.5090308@genband.com> <17679.1343939453@death.nxdomain> <501AFEAD.10001@genband.com> <501B0037.1010804@genband.com> <20421.1343948491@death.nxdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Chris Friesen <chris.friesen@genband.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	netdev <netdev@vger.kernel.org>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:51600 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750744Ab2HCEuH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Aug 2012 00:50:07 -0400
In-Reply-To: <20421.1343948491@death.nxdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/2/2012 4:01 PM, Jay Vosburgh wrote:
> Chris Friesen <chris.friesen@genband.com> wrote:
>
>> On 08/02/2012 04:26 PM, Chris Friesen wrote:
>>> On 08/02/2012 02:30 PM, Jay Vosburgh wrote:
>>
>>>> The best long term solution is to have a user space API that
>>>> provides link state input to bonding on a per-slave basis, and then some
>>>> user space entity can perform whatever link monitoring method is
>>>> appropriate (e.g., LLDP) and pass the results to bonding.
>>>
>>> I think this has potential. This requires a virtual communication
>>> channel between guest/host if we want the host to be able to influence
>>> the guest's choice of active link, but I think that's not unreasonable.
>
> 	Not necessarily, if something like LLDP runs across the virtual
> link between the guest and slave, then the guest will notice when the
> link goes down (although perhaps not very quickly).  I'm pretty sure the
> infrastructure to make LLDP work on inactive slaves is already there; as
> I recall, the "no wildcard" or "deliver exact" business in the receive
> path is at least partially for LLDP.

Right we run LLDP over the inactive bond. However because LLDP
uses nearest customer bridge, nearest bridge, or neareast non-tpmr
addresses it should be dropped by switching components. The problem
with having VMs send LLDP and _not_ dropping the packets is it looks
like multiple neighbors to the peer. The point is there is really an
edge relay like component in the hardware with SR-IOV. So likely using
LLDP do to do this wouldn't work

If you happen to have the 2010 802.1Q rev section 8.6.3 "frame
filtering" has some more details. The 802.1AB spec has details on the
multiple neighbor case.

>
> 	Still, though, isn't "influence the guest's choice" pretty much
> satisified by having the VF interface go carrier down in the guest when
> the host wants it to?  Or are you thinking about more fine grained than
> that?
>

Perhaps one argument against this is if the hardware supports loopback
modes or the edge relay in the hardware is acting like a VEB it may
still be possible to support VF to VF traffic even if the external link
is down. Not sure how useful this is though or if any existing hardware
even supports it.

Just in case its not clear (it might not be) an edge relay (ER) is
defined in the new 802.1Qbg-2012 spec. "An ER supports local relay
among virtual stations and/or between a virtual station and other
stations on a bridged LAN". Similar to a bridge but without spanning
tree operations.

.John
