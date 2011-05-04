From: "Wyborny, Carolyn" <carolyn.wyborny@intel.com>
Subject: RE: bug fix for out-of-tree igb driver
Date: Wed, 4 May 2011 11:36:03 -0700
Message-ID: <EDC0E76513226749BFBC9C3FB031318F016B806C85@orsmsx508.amr.corp.intel.com>
References: <4DC1959B.4010609@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: Ben Greear <greearb@candelatech.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:24917 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753588Ab1EDSgF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2011 14:36:05 -0400
In-Reply-To: <4DC1959B.4010609@candelatech.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



>-----Original Message-----
>From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
>On Behalf Of Ben Greear
>Sent: Wednesday, May 04, 2011 11:06 AM
>To: netdev
>Subject: bug fix for out-of-tree igb driver
>
>Just in case someone is using the out-of-tree igb driver, I
>think I found a bug.
>
>The tx_queue_mapping method should have r_idx >= adapter->num_tx_queues
>as shown below.  The driver had: r_idx > adapter->num_tx_queues
>originally.
>
>Its possible my code is buggy for sending queue_mapping of 1
>when num_tx_queues is 1, but either way, the driver
>shouldn't crash.
>
>Upstream igb driver in mainline kernels does not have this problem.
>
>static inline struct igb_ring *igb_tx_queue_mapping(struct igb_adapter
>*adapter,
>                                                     struct sk_buff
>*skb)
>{
>	unsigned int r_idx = skb->queue_mapping & (IGB_MAX_TX_QUEUES - 1);
>
>	if (r_idx >= adapter->num_tx_queues)
>		r_idx = r_idx % adapter->num_tx_queues;
>
>	return adapter->tx_ring[r_idx];
>}
>
>Thanks,
>Ben
>
>--
>Ben Greear <greearb@candelatech.com>
>Candela Technologies Inc  http://www.candelatech.com
>
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html

Thanks Ben,

I'll be fixing that ASAP and updating the driver version there.

Carolyn

Carolyn Wyborny
Linux Development
LAN Access Division
Intel Corporation



