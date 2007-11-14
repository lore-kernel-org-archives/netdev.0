From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH] bonding: Documentation update
Date: Wed, 14 Nov 2007 10:00:05 -0800
Message-ID: <473B37A5.8090503@hp.com>
References: <11074.1195009133@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Jeff Garzik <jgarzik@pobox.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0014.houston.hp.com ([15.201.24.17]:38224 "EHLO
	g4t0014.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751720AbXKNSHL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 13:07:11 -0500
In-Reply-To: <11074.1195009133@death>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>  12. Configuring Bonding for Maximum Throughput
>  ==============================================
> @@ -1684,7 +1757,7 @@ balance-rr: This mode is the only mode that will permit a single
>  	interfaces. It is therefore the only mode that will allow a
>  	single TCP/IP stream to utilize more than one interface's
>  	worth of throughput.  This comes at a cost, however: the
> -	striping often results in peer systems receiving packets out
> +	striping generally results in peer systems receiving packets out
>  	of order, causing TCP/IP's congestion control system to kick
>  	in, often by retransmitting segments.
>  
> @@ -1696,22 +1769,20 @@ balance-rr: This mode is the only mode that will permit a single
>  	interface's worth of throughput, even after adjusting
>  	tcp_reordering.
>  
> -	Note that this out of order delivery occurs when both the
> -	sending and receiving systems are utilizing a multiple
> -	interface bond.  Consider a configuration in which a
> -	balance-rr bond feeds into a single higher capacity network
> -	channel (e.g., multiple 100Mb/sec ethernets feeding a single
> -	gigabit ethernet via an etherchannel capable switch).  In this
> -	configuration, traffic sent from the multiple 100Mb devices to
> -	a destination connected to the gigabit device will not see
> -	packets out of order.  However, traffic sent from the gigabit
> -	device to the multiple 100Mb devices may or may not see
> -	traffic out of order, depending upon the balance policy of the
> -	switch.  Many switches do not support any modes that stripe
> -	traffic (instead choosing a port based upon IP or MAC level
> -	addresses); for those devices, traffic flowing from the
> -	gigabit device to the many 100Mb devices will only utilize one
> -	interface.
> +	Note that the fraction of packets that will be delivered out of
> +	order is highly variable, and is unlikely to be zero.  The level
> +	of reordering depends upon a variety of factors, including the
> +	networking interfaces, the switch, and the topology of the
> +	configuration.  Speaking in general terms, higher speed network
> +	cards produce more reordering (due to factors such as packet
> +	coalescing), and a "many to many" topology will reorder at a
> +	higher rate than a "many slow to one fast" configuration.

Not quibbling with the wording, but when you have a chance I would be 
curious to see the data for the percentages of many to many vs many to one.

> +	Many switches do not support any modes that stripe traffic
> +	(instead choosing a port based upon IP or MAC level addresses);
> +	for those devices, traffic for a particular connection flowing
> +	through the switch to a balance-rr bond will not utilize greater
> +	than one interface's worth of bandwidth.

Shouldn't that be "Many switches do not support any modes that stripe 
traffic of a single flow?"

Shame that port is such an overloaded term.

>  
>  	If you are utilizing protocols other than TCP/IP, UDP for
>  	example, and your application can tolerate out of order


> @@ -1911,6 +1982,10 @@ Failover may be delayed via the downdelay bonding module option.
>  13.2 Duplicated Incoming Packets
>  --------------------------------
>  
> +	NOTE: Starting with version 3.0.2, the bonding driver has logic to
> +suppress duplicate packets, which should largely eliminate this problem.
> +The following description is kept for reference.
> +
>  	It is not uncommon to observe a short burst of duplicated
>  traffic when the bonding device is first used, or after it has been
>  idle for some period of time.  This is most easily observed by issuing
> @@ -2071,6 +2146,9 @@ The new driver was designed to be SMP safe from the start.
>  EtherExpress PRO/100 and a 3com 3c905b, for example).  For most modes,
>  devices need not be of the same speed.
>  
> +	Starting with version 3.2.1, bonding also supports Infiniband
> +slaves in active-backup mode.
> +
>  3.  How many bonding devices can I have?
>  
>  	There is no limit.
> @@ -2129,11 +2207,15 @@ switches currently available support 802.3ad.
>  
>  8.  Where does a bonding device get its MAC address from?

Not part of your change, but since you are editing the section, drop the 
"from" in the section title, or perhaps put it at the beginning so we 
don't have a dangling whatchamacallit.

rick jones
