From: Ben Greear <greearb@candelatech.com>
Subject: bug fix for out-of-tree igb driver
Date: Wed, 04 May 2011 11:06:19 -0700
Message-ID: <4DC1959B.4010609@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:48573 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755170Ab1EDSGU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2011 14:06:20 -0400
Received: from [192.168.100.195] (firewall.candelatech.com [70.89.124.249])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id p44I6JaY007085
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 4 May 2011 11:06:20 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Just in case someone is using the out-of-tree igb driver, I
think I found a bug.

The tx_queue_mapping method should have r_idx >= adapter->num_tx_queues
as shown below.  The driver had: r_idx > adapter->num_tx_queues originally.

Its possible my code is buggy for sending queue_mapping of 1
when num_tx_queues is 1, but either way, the driver
shouldn't crash.

Upstream igb driver in mainline kernels does not have this problem.

static inline struct igb_ring *igb_tx_queue_mapping(struct igb_adapter *adapter,
                                                     struct sk_buff *skb)
{
	unsigned int r_idx = skb->queue_mapping & (IGB_MAX_TX_QUEUES - 1);

	if (r_idx >= adapter->num_tx_queues)
		r_idx = r_idx % adapter->num_tx_queues;

	return adapter->tx_ring[r_idx];
}

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

