From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC] net: Pass full skb hash to ndo_rx_flow_steer
Date: Wed, 19 Nov 2014 18:56:15 -0500 (EST)
Message-ID: <20141119.185615.33858549418617328.davem@davemloft.net>
References: <1416370137-2512-1-git-send-email-therbert@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: luto@amacapital.net, ben@decadent.org.uk, netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39999 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755976AbaKSX4U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2014 18:56:20 -0500
In-Reply-To: <1416370137-2512-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Tue, 18 Nov 2014 20:08:57 -0800

> Currently, for aRFS the index into the flow table is passed to
> ndo_rx_flow_steer as the flow ID of a connection. This is the skb->hash
> & the table mask. It looks like the backend can accept the full
> skb->hash as the flow ID which should reduce the number of collisions
> in the hardware tables.
> 
> This patch provides the skb->hash to the driver for flow steering.
> Expiration of HW steered flows was also updated.
> 
> With a hash collision in RFS, ndo_rx_flow_steer will continue to be
> called with different CPUs, but now with different flow_ids. If this
> is still too much device interaction, then it might make sense for the
> driver to do its own lookup in its structure to see if a matching
> filter is already installed for a given flow_id, an if it is just
> refresh a timestamp to avoid expiration (based on looking at sfc
> driver).
> 
> I don't currently have any HW to test this, if someone could try this
> on hardware with aRFS and provide feedback that would be appreciated.
> 
> Signed-off-by: Tom Herbert <therbert@google.com>

This seems legitimate to me.

The only thing a driver can reliably do with the flow_id is
pass it back into rps_may_expire_flow().  Therefore you can
pass it in whatever format you like.
