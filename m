From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: Re: [net-next PATCH 2/3] ixgbe: Distribute transmission of FCoE
 traffic in 82599
Date: Thu, 3 Sep 2009 21:12:46 -0700 (Pacific Daylight Time)
Message-ID: <Pine.WNT.4.64.0909032107410.800@ppwaskie-MOBL2.amr.corp.intel.com>
References: <20090904005549.14869.66878.stgit@localhost.localdomain>
 <20090904005609.14869.89202.stgit@localhost.localdomain>
 <20090903.200915.157113657.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>, "Zou, Yi" <yi.zou@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:48369 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750852AbZIDEMo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Sep 2009 00:12:44 -0400
In-Reply-To: <20090903.200915.157113657.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 3 Sep 2009, David Miller wrote:

> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: Thu, 03 Sep 2009 17:56:10 -0700
> 
> > From: Yi Zou <yi.zou@intel.com>
> > 
> > This adds a simple selection of a FCoE tx queue based on the current cpu id to
> > distribute transmission of FCoE traffic evenly among multiple FCoE transmit
> > queues.
> > 
> > Signed-off-by: Yi Zou <yi.zou@intel.com>
> > Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> 
> Applied.
> 
> Does it matter that arbitrary programs or other stacks could transmit
> ETH_P_FCOE traffic as well?  Would that interfere with how this offload
> hardware works now that you're directing all ETH_P_FCOE traffic to
> FCOE rings?

If another stack uses the FCoE Ethertype, the filtering we use in the 
qdisc layer to filter FCoE frames would assume they belong in the FCoE 
flow ID in the driver.  As long as the other stacks send standard FCoE 
frames, there won't be a problem.  If a stack uses the Ethertype but 
doesn't follow the standard FCoE frame format, then I'd say that stack was 
in need of being fixed.

The FCoE offload on Tx in 82599 is basically just a segmenter, like TSO.

Cheers,
-PJ
