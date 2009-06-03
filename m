From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Question regarding protocol specific mtu for FCoE
Date: Wed, 03 Jun 2009 11:03:35 -0700
Message-ID: <4A26BAF7.3070301@hp.com>
References: <7C88852EF6F99F4EB538472FCFEBE2223A7E6F45@orsmsx509.amr.corp.intel.com>
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
Received: from g4t0017.houston.hp.com ([15.201.24.20]:18089 "EHLO
	g4t0017.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751601AbZFCSDf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2009 14:03:35 -0400
In-Reply-To: <7C88852EF6F99F4EB538472FCFEBE2223A7E6F45@orsmsx509.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Zou, Yi wrote:
> Hi,
> I am trying to figure out a way to support a different MTU for Fiber
> Channel over Ethernet (FCoE), where it is preferred to have a baby jumbo
> frame with MTU=2158 (14 bytes FCoE header + 24 bytes FC header + 2112
> bytes max FC payload + 4 bytes FC CRC + 4 bytes FCoE trailer).
> 
> Similar to nedev->mtu being used everywhere for LAN traffic, I wonder if
> it is desirable or feasible to add another protocol specific MTU (which
> is my case is FCoE) to netdev so any eth driver supporting converged
> traffic (e.g. LAN + FCoE) over netdev can make use of it.

Do FCoE upper layers have anything analagous to a TCP_MAXSEG option?  That allows 
an application using TCP to ask for a smaller MSS than TCP might have chosen 
otherwise.

Would a NIC over which FCoE was running be able to be of two minds of what the 
MTU happens to be?  I'd think that if one user of the NIC needed/wanted and MTU > 
foo one would just set the MTU large enough to include foo and be done with it?

In IP networking space at least, if there is a destination for which one does not 
want to use the default MTU, one can set-up a destination-specific (Path) MTU in 
the routing table that will (if smaller) override the link-local MTU for traffic 
going to/from that destination.

rick jones
