From: Brice Goglin <Brice.Goglin@inria.fr>
Subject: Re: [RFC] Idea about increasing efficency of skb allocation in	network
 devices
Date: Wed, 29 Jul 2009 10:20:55 +0200
Message-ID: <4A700667.5080108@inria.fr>
References: <20090727003609.GA30438@localhost.localdomain> <20090726.180254.202825489.davem@davemloft.net> <4A6D52FF.2030008@inria.fr> <4A6D5E1E.3090907@gmail.com> <20090727105554.GB15823@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2-relais-roc.national.inria.fr ([192.134.164.83]:15758 "EHLO
	mail2-relais-roc.national.inria.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751920AbZG2IUx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2009 04:20:53 -0400
In-Reply-To: <20090727105554.GB15823@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Neil Horman wrote:
>>> Is there an easy way to get this NUMA node from the application socket
>>> descriptor?
>>>       
>> Thats not easy, this information can change for every packet (think of
>> bonding setups, whith aggregation of devices on different NUMA nodes)
>>
>> We could add a getsockopt() call to peek this information from the next
>> data to be read from socket (returns node id where skb data is sitting,
>> hoping that NIC driver hadnt copybreak it (ie : allocate a small skb and
>> copy the device provided data on it before feeding packet to network stack))
>>
>>     
> Would a proc or debugfs interface perhaps be helpful here?  Something that
> perhaps showed a statistical distribution of how many packets were received by
> each process on each irq (operating under the assumption that each rx queue has
> its own msi irq, giving us an easy identifier).
>   

It could be intereting. But unprivileged user processes cannot read
/proc/irq/*/smp_affinity, so they would not be able to translate your
procfs information into a binding hint.

Brice

