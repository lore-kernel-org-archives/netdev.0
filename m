From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next] ipv6: allow userspace to create address with
 IFLA_F_TEMPORARY flag
Date: Tue, 29 Oct 2013 15:44:15 -0400 (EDT)
Message-ID: <20131029.154415.509757973218262289.davem@davemloft.net>
References: <20131028233158.GA26185@order.stressinduktion.org>
	<20131028.204306.2213130677400093266.davem@davemloft.net>
	<AE90C24D6B3A694183C094C60CF0A2F6026B73BB@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, jiri@resnulli.us, vyasevich@gmail.com,
	netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, thaller@redhat.com,
	stephen@networkplumber.org
To: David.Laight@ACULAB.COM
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48008 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751561Ab3J2ToR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Oct 2013 15:44:17 -0400
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B73BB@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "David Laight" <David.Laight@ACULAB.COM>
Date: Tue, 29 Oct 2013 09:37:06 -0000

>> Note that you don't even need to put the DHCP protocol core into the
>> kernel to fix the promiscuous problem.  You just have to use the
>> current kernel interfaces correctly.
>> 
>> It used to be the case a very long time ago that you couldn't even
>> receive broadcast UDP datagrams on a socket until an address was
>> configured on it.
>> 
>> So everyone turns on promiscuous mode and uses RAW sockets or
>> AF_PACKET.
>> 
>> Stupid?  yes.
> 
> Not only that, but the dhcp client could use a normal UDP socket
> to keep the lease renewed - I suspect it has only ever needed
> to use the BPF interface (I didn't think it set promiscuous)
> when acquiring the initial lease.

You don't even need it for that, you can use a normal vanilla UDP
socket for the entire set of transactions.

When we initially seek a lease, we get our response in a broadcast
packet and the kernel is perfectly willing to receive that broadcast
packet, as stated, even when no IP address is assigned to the
interface.

The BPF program is only necessary if you don't use UDP sockets and use
RAW ones instead.  Look at what it's used for, it's purely matching
protocol UDP, port N.
