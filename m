From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [RFC net-next 2/3] VRF driver and needed infrastructure
Date: Mon, 08 Jun 2015 22:17:02 +0200
Message-ID: <1433794622.4616.11.camel@stressinduktion.org>
References: <cover.1433561681.git.shm@cumulusnetworks.com>
	 <dafc9b784df4cb52691f7dce0f280fc1b2b14532.1433561681.git.shm@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: nicolas.dichtel@6wind.com, dsahern@gmail.com,
	ebiederm@xmission.com, hadi@mojatatu.com, davem@davemloft.net,
	stephen@networkplumber.org, netdev@vger.kernel.org,
	roopa@cumulusnetworks.com, gospo@cumulusnetworks.com,
	jtoppins@cumulusnetworks.com, nikolay@cumulusnetworks.com
To: Shrijeet Mukherjee <shm@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:56174 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753587AbbFHURL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jun 2015 16:17:11 -0400
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id 9D191207BC
	for <netdev@vger.kernel.org>; Mon,  8 Jun 2015 16:17:10 -0400 (EDT)
In-Reply-To: <dafc9b784df4cb52691f7dce0f280fc1b2b14532.1433561681.git.shm@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Mo, 2015-06-08 at 11:35 -0700, Shrijeet Mukherjee wrote:
> From: Shrijeet Mukherjee <shm@cumulusnetworks.com>
> 
> This driver borrows heavily from IPvlan and teaming drivers.
> 
> Routing domains (VRF-lite) are created by instantiating a device
> and enslaving all routed interfaces that participate in the domain.
> As part of the enslavement, all local routes pointing to enslaved
> devices are re-pointed to the vrf device, thus forcing outgoing
> sockets to bind to the vrf to function.
> 
> Standard FIB rules can then bind the VRF device to tables and regular
> fib rule processing is followed.
> 
> Routed traffic through the box, is fwded by using the VRF device as
> the IIF and following the IIF rule to a table which is mated with
> the VRF.
> 
> Locally originated traffic is directed at the VRF device using
> SO_BINDTODEVICE or cmsg headers. This in turn drops the packet into
> the xmit function of the vrf driver, which then completes the ip lookup
> and output.
> 
> This solution is completely orthogonal to namespaces and allow the L3
> equivalent of vlans to exist allowing the routing space to be
> partitioned.
> 
> Example use is
>    ip link add vrf0 type vrf table 5
>    ip link set eth1 master vrf0
>    ip link set vrf0 up
> 
>    ip rule add iif vrf0 table 5
>    ip rule add oif vrf0 table 5
> 
> TODO:
> This changeset is for IPv4 only
> Connected route management can be made much better, but is deferred to
> user space for now.

One thing that got lost is that we should prohibit user space applications
to bind to devices which are vrf interfaces without having CAP_NET_ADMIN
capability, so user space programs can be in future restricted to a specific
VRF.

Bye,
Hannes
