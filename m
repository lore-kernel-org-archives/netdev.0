From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: Question: should local address be expired when updating PMTU?
Date: Tue, 3 Feb 2015 10:28:46 +0100
Message-ID: <20150203092845.GT13046@secunet.com>
References: <54CF3348.40207@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<yangyingling@huawei.com>, <hannes@redhat.com>
To: shengyong <shengyong1@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:40769 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751202AbbBCJ2z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Feb 2015 04:28:55 -0500
Content-Disposition: inline
In-Reply-To: <54CF3348.40207@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 02, 2015 at 04:20:24PM +0800, shengyong wrote:
> Hi, David Miller
> Since commit 81aded246 (ipv6: Handle PMTU in ICMP error handlers), the entries
> in neigh table may get expired. But in the situation:
> 
>           Host only
>     PC <------------> Virtual Machine
> 
> a packet is sent from PC to VM, and the packet looks like:
> -----------------------------------
> | IPv6 (src=PC-addr, dst=VM-addr) |
> |---------------------------------|
> |     ICMPv6 (Packet Too Big)     |
> |---------------------------------|
> | IPv6 (src=VM-addr, dst=VM-addr) |
> |---------------------------------|
> | ICMPv6 (Neighbor Advertisement) |
> -----------------------------------
> 
> Then the local addr on VM will be updated with an expire value. After the
> lifetime of the local addr is expired, the VM is unreachable from PC.
> 
> 	# ip -6 route list table local
> 	local fe80::1 dev lo  metric 0 *expire 596*

We first need to find out why you receive this Packet Too Big message,
can you capture this packet somehow? Then we have to see why this loopback
route gets a pmtu update from that packet. Is the destination address
of the Packet Too Big message really fe80::1?
