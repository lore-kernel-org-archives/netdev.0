From: Dimitris Michailidis <dm@chelsio.com>
Subject: Re: [PATCH 1/2] net: Add RX queue weights
Date: Fri, 11 Feb 2011 19:49:36 -0800
Message-ID: <4D560350.5080002@chelsio.com>
References: <alpine.DEB.2.00.1102111552090.2793@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:12281 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758054Ab1BLDto (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Feb 2011 22:49:44 -0500
In-Reply-To: <alpine.DEB.2.00.1102111552090.2793@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tom Herbert wrote:
> This patch adds a weight attribute to the netdev RX queues.  This allows
> control over the relative receive packet load for each queue.  These
> values are set in sysfs variable 'weight' in the rxq directory for
> a device.  When a weight is set, a new netdev operation is called to
> inform the driver of the changed weight.  The driver is expected to
> apply the queue weights in a logical manner to the RSS indirection table
> of the device to achieve the desired weighting.  The driver
> implementation for this is unspecified.
> 
> If a weight for a queue is zero, this effectively disables that queue
> for RSS (but possibly still usable by accelerated RFS, etc.), except
> in the case that all queue weights are zero, then all queues are
> considered equally weighted (the default).
> 
> Example configuration:
> echo 1 > /sys/class/net/eth4/queues/rx-0/weight
> echo 1 > /sys/class/net/eth4/queues/rx-1/weight
> echo 5 > /sys/class/net/eth4/queues/rx-2/weight
> echo 0 > /sys/class/net/eth4/queues/rx-3/weight
> 
> So rx queue 0 and 1 have equal weight, queue 2 is 5X in weight and
> queue 3 is disabled for RSS.

Doesn't ethtool -X already do this?  With the added benefit that ethtool 
doesn't need each driver to provide its own weight handling arithmetic.


