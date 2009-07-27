From: Brice Goglin <Brice.Goglin@inria.fr>
Subject: Re: [RFC] Idea about increasing efficency of skb allocation in network
 devices
Date: Mon, 27 Jul 2009 10:27:05 +0200
Message-ID: <4A6D64D9.6010601@inria.fr>
References: <20090727003609.GA30438@localhost.localdomain> <20090726.180254.202825489.davem@davemloft.net> <4A6D52FF.2030008@inria.fr> <4A6D5E1E.3090907@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, nhorman@tuxdriver.com,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3-relais-sop.national.inria.fr ([192.134.164.104]:43078
	"EHLO mail3-relais-sop.national.inria.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751066AbZG0I1D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2009 04:27:03 -0400
In-Reply-To: <4A6D5E1E.3090907@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
>> Is there an easy way to get this NUMA node from the application socket
>> descriptor?
>>     
>
> Thats not easy, this information can change for every packet (think of
> bonding setups, whith aggregation of devices on different NUMA nodes)
>   

If we return a mask of cpus near the NIC, we could return the mask
containing cpus that are close to any of the devices that were
aggregated in this bonding setup.
If no bonding, it's fine. If bonding, the behavior looks acceptable to me.

> We could add a getsockopt() call to peek this information from the next
> data to be read from socket (returns node id where skb data is sitting,
> hoping that NIC driver hadnt copybreak it (ie : allocate a small skb and
> copy the device provided data on it before feeding packet to network stack))
>
>
>   
>> Also, one question that was raised at the Linux Symposium is: how do you
>> know which processors run the receive queue for a specific connection ?
>> It would be nice to have a way to retrieve such information in the
>> application to avoid inter-node and inter-core/cache traffic.
>>     
>
> All this depends on the fact you have multiqueue devices or not, and
> trafic spreads on all queues or not.
>   

Again, on a per-connection basis, you should know whether your packets
are going through a single queue or to all of them? If going to a single
queue, return a mask of cpus near this exact queue. If going to multiple
queues (or if you don't know), just sumup the cpumask of all queues.

Brice

