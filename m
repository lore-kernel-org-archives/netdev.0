From: Ben Greear <greearb@candelatech.com>
Subject: Re: ARP table question
Date: Mon, 17 Nov 2008 10:17:05 -0800
Message-ID: <4921B521.1010305@candelatech.com>
References: <491B1841.9050404@candelatech.com>	<491B31EB.4050304@candelatech.com>	<491B5452.6020709@candelatech.com> <20081116.191628.135824721.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:34707 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752442AbYKQSRM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Nov 2008 13:17:12 -0500
In-Reply-To: <20081116.191628.135824721.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:

> This change makes a lot of sense to me, I'll add it to net-next-2.6
> so it can cook in there for a while just in case there are some
> unwanted side-effects.

Thanks Dave.

I think I found another problem as well:  If I start 1 TCP and 1 UDP connection
between each of the 500 interfaces on mac-vlans, the ARP tables will not converge.

It seems to be because mac-vlan has to copy broadcast packets to every
mac-vlan on a physical device, there are just too many packets:

500 vlans arping once per second means 500 pkts per second on the
other NIC.
Other NIC must copy these 500 times,
so, 250000 packets per second in each direction are
processed by the stack (they are not all on the wire, at least).

A few get through and those UDP/TCP connections start consuming
bandwidth, which clogs up the 1G link enough that other responses
are lost most of the time.

I'm going to try to work on some sort of random backoff for ARP that can
be enabled in this situation next.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

