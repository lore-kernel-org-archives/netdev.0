From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] net: introduce build_skb()
Date: Mon, 14 Nov 2011 14:21:53 -0500 (EST)
Message-ID: <20111114.142153.804127798975712263.davem@davemloft.net>
References: <1321286614.2272.47.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, pstaszewski@itcare.pl, netdev@vger.kernel.org,
	bhutchings@solarflare.com, therbert@google.com, hadi@mojatatu.com,
	shemminger@vyatta.com, tgraf@infradead.org,
	herbert@gondor.hengli.com.au, jeffrey.t.kirsher@intel.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44270 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753733Ab1KNTXN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2011 14:23:13 -0500
In-Reply-To: <1321286614.2272.47.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 14 Nov 2011 17:03:34 +0100

 ...
> So the deal would be to allocate only the data buffer for the NIC to
> populate its RX ring buffer. And use build_skb() at RX completion to
> attach a data buffer (now filled with an ethernet frame) to a new skb,
> initialize the skb_shared_info portion, and give the hot skb to network
> stack.
> 
> build_skb() is the function to allocate an skb, caller providing the
> data buffer that should be attached to it. Drivers are expected to call 
> skb_reserve() right after build_skb() to adjust skb->data to the
> Ethernet frame (usually skipping NET_SKB_PAD and NET_IP_ALIGN, but some
> drivers might add a hardware provided alignment)
> 
> Data provided to build_skb() MUST have been allocated by a prior
> kmalloc() call, with enough room to add SKB_DATA_ALIGN(sizeof(struct
> skb_shared_info)) bytes at the end of the data without corrupting
> incoming frame.

Applied, I'll work on converting NIU over to this if I find some time.
