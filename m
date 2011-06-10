From: Tim Chen <tim.c.chen@linux.intel.com>
Subject: Re: [PATCH net-next-2.6] inetpeer: lower false sharing effect
Date: Fri, 10 Jun 2011 10:05:31 -0700
Message-ID: <1307725531.17300.58.camel@schen9-DESK>
References: <1307600810.3980.85.camel@edumazet-laptop>
	 <1307664235.17300.44.camel@schen9-DESK>
	 <1307680287.3210.2.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Andi Kleen <andi@firstfloor.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:24699 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751622Ab1FJREi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Jun 2011 13:04:38 -0400
In-Reply-To: <1307680287.3210.2.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-06-10 at 06:31 +0200, Eric Dumazet wrote:

> 
> Thanks Tim
> 
> I have some questions for further optimizations.
> 
> 1) How many different destinations are used in your stress load ?
> 2) Could you provide a distribution of the size of packet lengthes ?
>    Or maybe the average length would be OK
> 
> 
> 

Actually I have one load generator and one server connected to each
other via a 10Gb link.

The server is a 40 core 4 socket Westmere-EX machine and the load
generator is a 12 core 2 socket Westmere-EP machine.

There are 40 memcached daemons on the server each bound to a cpu core
and listening on a distinctive UDP port.  The load generator has 40
threads, with each thread sending memcache request to a particular UDP
port.


The load generator's memcache request packet has a UDP payload of 25
bytes.  The response packet from the daemon has a UDP payload of 13
bytes.

The UPD packets on the load generator and server are distributed across
16 Tx-Rx queues by hashing on the UDP ports (with slight modification of
the hash flags of ixgbe).

Thanks.

Tim


