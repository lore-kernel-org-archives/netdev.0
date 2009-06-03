From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Question regarding protocol specific mtu for FCoE
Date: Wed, 03 Jun 2009 14:01:34 -0700
Message-ID: <4A26E4AE.4020607@hp.com>
References: <7C88852EF6F99F4EB538472FCFEBE2223A7E6F45@orsmsx509.amr.corp.intel.com>	<4A26BAF7.3070301@hp.com> <7C88852EF6F99F4EB538472FCFEBE2223A7E6FBD@orsmsx509.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>,
	"Leech, Christopher" <christopher.leech@intel.com>,
	"Dev, Vasu" <vasu.dev@intel.com>,
	"Love, Robert W" <robert.w.love@intel.com>,
	"Ma, Steve" <steve.ma@intel.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: "Zou, Yi" <yi.zou@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0014.houston.hp.com ([15.201.24.17]:48409 "EHLO
	g4t0014.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752841AbZFCVBe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2009 17:01:34 -0400
In-Reply-To: <7C88852EF6F99F4EB538472FCFEBE2223A7E6FBD@orsmsx509.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> Do FCoE upper layers have anything analagous to a TCP_MAXSEG option? That
>> allows an application using TCP to ask for a smaller MSS than TCP might have
>>  chosen otherwise.
> 
> No, FCoE does not have that. The current kernel FCoE initiator initiates its
> max frame size based on the associated netdev->mtu, which normally is 1500.
> So, unless the LAN mtu is changed, FCoE stack is no able to use baby jumbo
> frame.

So FCoE cannot say "fcoe_mtu = min(OPTIMAL_FCOEMTU,netdev->mtu)" and send-down 
frames based on that?

>> Would a NIC over which FCoE was running be able to be of two minds of what 
>> the MTU happens to be?  I'd think that if one user of the NIC needed/wanted
>>  and MTU > foo one would just set the MTU large enough to include foo and be
>>  done with it?
> 
> For a nic that supports converged traffic, i.e. LAN + FCoE, I think
> it's safe to assume the nic has that capability. Setting LAN MTU large
> enough will work for FCoE, but it affects everyone using netdev->mtu, so
> you may see degraded LAN performance, which is certainly not good.

There have been some instances of increased MTU running causing applcations to 
run afoul of Nagle and what not, but I don't think it is a general truism that 
using a larger MTU degrades LAN performance.

Perhaps it is just me not getting out enough but I'm still having trouble coming 
to grips with the idea of a NIC that has two (or more) ideas of a valid frame 
size based on ethertype or whatnot.

At the risk of another of my "Emily Litella" moments, it sounds like the NIC HW 
will have to be set to use an MTU that is the max of the desired IP and FCoE MTUs 
and so you are not really talking about adding one MTU concept but two so you have:

1) the "HW MTU" used by the NIC and the guts of the driver
2) the legacy networking (eg IP etc) MTU passed up through the legacy path
3) the fcoe MTU passed up through the fcoe path

where 1 is the max of 2,3

rick jones
