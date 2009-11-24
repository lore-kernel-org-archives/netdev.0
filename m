From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] irq: Add node_affinity CPU masks for smarter irqbalance
 hints
Date: Tue, 24 Nov 2009 21:46:28 +0100
Message-ID: <4B0C4624.9080607@gmail.com>
References: <20091124.093956.247147202.davem@davemloft.net>	<1259085412.2631.48.camel@ppwaskie-mobl2> <4B0C2547.8030408@gmail.com>	<20091124.105442.06273019.davem@davemloft.net>	<4B0C2CCA.6030006@gmail.com> <87iqczwtia.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	peter.p.waskiewicz.jr@intel.com, peterz@infradead.org,
	arjan@linux.intel.com, yong.zhang0@gmail.com,
	linux-kernel@vger.kernel.org, arjan@linux.jf.intel.com,
	netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:53924 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933280AbZKXUqm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Nov 2009 15:46:42 -0500
In-Reply-To: <87iqczwtia.fsf@basil.nowhere.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andi Kleen a =E9crit :
> They are typically allocated with dma_alloc_coherent(), which does
> allocate a continuous area.  In theory you could do interleaving
> with IOMMus, but just putting it on the same node as the device
> is probably better.

There are two parts, biggest one allocated with vmalloc()
(to hold struct ixgbe_rx_buffer array, 32 bytes or more per entry),
only used by driver (not adapter)

and one allocated with pci_alloc_consistent()=20
(to hold ixgbe_adv_tx_desc array, 16 bytes per entry)

vmalloc() one could be spreaded on many nodes.
I am not speaking about the pci_alloc_consistent() one :)


