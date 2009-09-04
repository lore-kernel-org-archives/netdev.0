From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: Re: [net-next PATCH 1/3] ixgbe: Add support for multiple Tx queues
 for FCoE in 82599
Date: Thu, 3 Sep 2009 21:06:02 -0700 (Pacific Daylight Time)
Message-ID: <Pine.WNT.4.64.0909032052420.800@ppwaskie-MOBL2.amr.corp.intel.com>
References: <20090904005549.14869.66878.stgit@localhost.localdomain>
 <20090903.200809.212485138.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>, "Zou, Yi" <yi.zou@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:64302 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750776AbZIDEGA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Sep 2009 00:06:00 -0400
In-Reply-To: <20090903.200809.212485138.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 3 Sep 2009, David Miller wrote:

> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: Thu, 03 Sep 2009 17:55:50 -0700
> 
> > From: Yi Zou <yi.zou@intel.com>
> > 
> > This patch adds support for multiple transmit queues to the Fiber Channel
> > over Ethernet (FCoE) feature found in 82599. Currently, FCoE has multiple
> > Rx queues available, along with a redirection table, that helps distribute
> > the I/O load across multiple CPUs based on the FC exchange ID. To make
> > this the most effective, we need to provide the same layout of transmit
> > queues to match receive.
> > 
> > Particularly, when Data Center Bridging (DCB) is enabled, the designated
> > traffic class for FCoE can have dedicated queues for just FCoE traffic,
> > while not affecting any other type of traffic flow.
> > 
> > Signed-off-by: Yi Zou <yi.zou@intel.com>
> > Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> 
> Applied.
> 
> So does this eat into the TX queues available to non-FCOE traffic
> or is this a shared setup?

When DCB is enabled, then this is purely isolated to the FCoE traffic 
class.  When DCB is enabled, all the queues in the hardware are 
hard-partitioned.  Since our FCoE implementation sets a different MTU, and 
also disables packet split, to the FCoE queues, these are completely 
isolated.

Now when DCB is not enabled, 82599 operates in a kind of HBA-ish mode.  
FCoE and LAN will be running on the same queues, so yes, these queues 
would be eaten up from the LAN queues.

That all being said, 82599 has 128 Tx queues available.  But we only 
enable 1 queue per online CPU in today's driver without FCoE, so we won't 
run out of queues (yet).

Cheers,
-PJ
