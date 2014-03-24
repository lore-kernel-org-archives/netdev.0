From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v6] vxlan: fix nonfunctional neigh_reduce()
Date: Mon, 24 Mar 2014 15:35:42 -0400 (EDT)
Message-ID: <20140324.153542.98521112335550166.davem@davemloft.net>
References: <201403241439.s2OEdwi0002321@xl.dls>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, amwang@redhat.com, netdev@vger.kernel.org
To: dlstevens@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43623 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754177AbaCXTfp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Mar 2014 15:35:45 -0400
In-Reply-To: <201403241439.s2OEdwi0002321@xl.dls>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David L Stevens <dlstevens@us.ibm.com>
Date: Mon, 24 Mar 2014 10:39:58 -0400

> 
> 	The VXLAN neigh_reduce() code is completely non-functional since
> check-in. Specific errors:
> 
> 1) The original code drops all packets with a multicast destination address,
> 	even though neighbor solicitations are sent to the solicited-node
> 	address, a multicast address. The code after this check was never run.
> 2) The neighbor table lookup used the IPv6 header destination, which is the
> 	solicited node address, rather than the target address from the
> 	neighbor solicitation. So neighbor lookups would always fail if it
> 	got this far. Also for L3MISSes.
> 3) The code calls ndisc_send_na(), which does a send on the tunnel device.
> 	The context for neigh_reduce() is the transmit path, vxlan_xmit(),
> 	where the host or a bridge-attached neighbor is trying to transmit
> 	a neighbor solicitation. To respond to it, the tunnel endpoint needs
> 	to do a *receive* of the appropriate neighbor advertisement. Doing a
> 	send, would only try to send the advertisement, encapsulated, to the
> 	remote destinations in the fdb -- hosts that definitely did not do the
> 	corresponding solicitation.
> 4) The code uses the tunnel endpoint IPv6 forwarding flag to determine the
> 	isrouter flag in the advertisement. This has nothing to do with whether
> 	or not the target is a router, and generally won't be set since the
> 	tunnel endpoint is bridging, not routing, traffic.
> 
> 	The patch below creates a proxy neighbor advertisement to respond to
> neighbor solicitions as intended, providing proper IPv6 support for neighbor
> reduction.
> 
> Signed-off-by: David L Stevens <dlstevens@us.ibm.com>

Applied and queued up for -stable, thanks David.
