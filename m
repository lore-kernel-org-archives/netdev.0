From: Brice Goglin <Brice.Goglin@inria.fr>
Subject: Re: [RFC] Idea about increasing efficency of skb allocation in network
 devices
Date: Mon, 27 Jul 2009 09:10:55 +0200
Message-ID: <4A6D52FF.2030008@inria.fr>
References: <20090727003609.GA30438@localhost.localdomain> <20090726.180254.202825489.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2-relais-roc.national.inria.fr ([192.134.164.83]:32033 "EHLO
	mail2-relais-roc.national.inria.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753652AbZG0HUu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2009 03:20:50 -0400
In-Reply-To: <20090726.180254.202825489.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Neil Horman <nhorman@tuxdriver.com>
> Date: Sun, 26 Jul 2009 20:36:09 -0400
>
>   
>> 	Since Network devices dma their memory into a provided DMA
>> buffer (which can usually be at an arbitrary location, as they must
>> cross potentially several pci busses to reach any memory location),
>> I'm postulating that it would increase our receive path efficiency
>> to provide a hint to the driver layer as to which node to allocate
>> an skb data buffer on.  This hint would be determined by a feedback
>> mechanism.  I was thinking that we could provide a callback function
>> via the skb, that accepted the skb and the originating net_device.
>> This callback can track statistics on which numa nodes consume
>> (read: copy data from) skbs that were produced by specific net
>> devices.  Then, when in the future that netdevice allocates a new
>> skb (perhaps via netdev_alloc_skb), we can use that statistical
>> profile to determine if the data buffer should be allocated on the
>> local node, or on a remote node instead.
>>     
>
> No matter what, you will do an inter-node memory operation.
>
> Unless, the consumer NUMA node is the same as the one the
> device is on.
>
> Because since the device is on a NUMA node, if you DMA remotely
> you've eaten the NUMA cost already.
>
> If you always DMA to the device's NUMA node (what we try to do now) at
> least the is the possibility of eliminating cross-NUMA traffic.
>
> Better to move the application or stack processing towards the NUMA
> node the network device is on, I think.
>   

Is there an easy way to get this NUMA node from the application socket
descriptor?
Also, one question that was raised at the Linux Symposium is: how do you
know which processors run the receive queue for a specific connection ?
It would be nice to have a way to retrieve such information in the
application to avoid inter-node and inter-core/cache traffic.

Brice

