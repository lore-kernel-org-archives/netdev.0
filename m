From: "Zou, Yi" <yi.zou@intel.com>
Subject: RE: Question regarding protocol specific mtu for FCoE
Date: Wed, 3 Jun 2009 12:16:11 -0700
Message-ID: <7C88852EF6F99F4EB538472FCFEBE2223A7E6FBD@orsmsx509.amr.corp.intel.com>
References: <7C88852EF6F99F4EB538472FCFEBE2223A7E6F45@orsmsx509.amr.corp.intel.com>
 <4A26BAF7.3070301@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>,
	"Leech, Christopher" <christopher.leech@intel.com>,
	"Dev, Vasu" <vasu.dev@intel.com>,
	"Love, Robert W" <robert.w.love@intel.com>,
	"Ma, Steve" <steve.ma@intel.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:27874 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753685AbZFCTQL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2009 15:16:11 -0400
In-Reply-To: <4A26BAF7.3070301@hp.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>Zou, Yi wrote:
>> Hi,
>> I am trying to figure out a way to support a different MTU for Fiber
>> Channel over Ethernet (FCoE), where it is preferred to have a baby
>jumbo
>> frame with MTU=2158 (14 bytes FCoE header + 24 bytes FC header + 2112
>> bytes max FC payload + 4 bytes FC CRC + 4 bytes FCoE trailer).
>>
>> Similar to nedev->mtu being used everywhere for LAN traffic, I wonder
>if
>> it is desirable or feasible to add another protocol specific MTU
>(which
>> is my case is FCoE) to netdev so any eth driver supporting converged
>> traffic (e.g. LAN + FCoE) over netdev can make use of it.
>
>Do FCoE upper layers have anything analagous to a TCP_MAXSEG option?
>That allows
>an application using TCP to ask for a smaller MSS than TCP might have
>chosen
>otherwise.
No, FCoE does not have that. The current kernel FCoE initiator initiates
its max frame size based on the associated netdev->mtu, which normally is 1500. So, unless the LAN mtu is changed, FCoE stack is no able to
use baby jumbo frame.

>
>Would a NIC over which FCoE was running be able to be of two minds of
>what the
>MTU happens to be?  I'd think that if one user of the NIC needed/wanted
>and MTU >
>foo one would just set the MTU large enough to include foo and be done
>with it?
For a nic that supports converged traffic, i.e. LAN + FCoE, I think
it's safe to assume the nic has that capability. Setting LAN MTU large
enough will work for FCoE, but it affects everyone using netdev->mtu, so
you may see degraded LAN performance, which is certainly not good.

>
>In IP networking space at least, if there is a destination for which
>one does not
>want to use the default MTU, one can set-up a destination-specific
>(Path) MTU in
>the routing table that will (if smaller) override the link-local MTU
>for traffic
>going to/from that destination.
>
>rick jones
FCoE is on L2 layer, no path specific MTU, everything goes out as
whatever mtu known to the nic. Since the nic is expected to be used for
converged traffic involving multiple traffic types, e.g. LAN, FCoE, I
was wondering if it makes sense to have the additional MTU. Essentially,
the nic driver will be able to setup via netdev for different MTUs for
converged traffic.

Thanks. 

yi
