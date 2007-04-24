From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] bridge: if no STP then forward all BPDU's
Date: Tue, 24 Apr 2007 16:20:27 -0700 (PDT)
Message-ID: <20070424.162027.65818763.davem@davemloft.net>
References: <20070424161226.0372f5e8@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35071
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754649AbXDXXUV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Apr 2007 19:20:21 -0400
In-Reply-To: <20070424161226.0372f5e8@dxpl.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Tue, 24 Apr 2007 16:12:26 -0700

> The bridge code by default captures all spanning tree packets and
> doesn't forward them. I propose that this might not be a good idea.
> 
> If a bridge is not running STP, then it has no way to detect a cycle
> in the network (by itself). But if some other machine is running STP,
> then if STP BPDU's get forwarded to the STP can detect the cycle
> (and turn off that link).  
> 
>               +------------+ <-BPDU-  +--------+
>               | transparent|==========| STP    |
>               |  bridge    |==========| bridge |=== ...
>               +------------+ -BPDU->  +--------+
>  
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

This makes a lot of sense, but I wonder about something:

old code:

> -	if (unlikely(is_link_local(dest))) {
> -		skb->pkt_type = PACKET_HOST;

new code:

> +	if (p->br->stp_enabled != BR_NO_STP && is_link_local(dest)) {
> +		/* skb->pkt_type should already be PACKET_MULTICAST */

So what is the true deal wrt. skb->pkt_type.  The original
code must have been setting it to PACKET_HOST for a reason,
won't leaving it at PACKET_MULTICAST break something?
