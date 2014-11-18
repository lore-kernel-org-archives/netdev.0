From: David Miller <davem@davemloft.net>
Subject: Re: [net-next v2 00/11][pull request] Intel Wired LAN Driver
 Updates 2014-11-18
Date: Tue, 18 Nov 2014 13:38:29 -0500 (EST)
Message-ID: <20141118.133829.2246481313976384106.davem@davemloft.net>
References: <1416302731-11327-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55447 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754460AbaKRSif (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Nov 2014 13:38:35 -0500
In-Reply-To: <1416302731-11327-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 18 Nov 2014 01:25:20 -0800

> This series contains updates to i40e only.
> 
> Shannon provides a patch to clean up the driver to only warn once that
> PTP is not supported when linked at 100Mbps.
> 
> Mitch provides a fix for i40e where the VF interrupt processing takes
> a long time and it is possible that we could lose a VFLR event if it
> happens while processing a VFLR on another VF.  To correct this situation,
> we enable the VFLR interrupt cause before we begin processing any pending
> resets.
> 
> Neerav provides several patches to update DCB support in i40e.  When
> there are DCB configuration changes based on DCBx, the firmware suspends
> the port's Tx and generates an event to the PF.  The PF is then
> responsible to reconfigure the PF VSIs and switching topology as per the
> updated DCB configuration and then resume the port's Tx by calling the
> "Resume Port Tx" AQ command, so add this call to the flow that handles
> DCB re-configuration in the PF.  Allow the driver to query and use DCB
> configuration from firmware when firmware DCBx agent is in CEE mode.
> Add a check whether LLDP Agent's default AdminStatus is enabled or
> disabled on a given port, and sets DCBx status to disabled if the
> status is disabled.  Fix an issue when the port TC configuration
> changes as a result of DCBx and the driver modifies the enabled TCs for
> the VEBs it manages but does not update the enabled_tc value that 
> was cached on a per VEB basis.  Add a new PF state so that if a port's
> Tx is in suspended state the Tx queue disable flow would just put the
> request for the queue to be disabled and return without waiting for the
> queue to be actually disabled.  Allows the driver to enable/disable
> the XPS based on the number of TCs being enabled for the given VSI.

Pulled, thanks Jeff.

> v2: Dropped patch "i40e: Handle a single mss packet with more than 8 frags"
>     while we rework the patch after we test a bit more based on feedback from 
>     Eric Dumazet.

Since, as Eric showed, it's easy to hang the card with a simple
netperf command line due to this issue, you might want to consider
sending that fix to 'net' instead.
