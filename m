From: Ben Greear <greearb@candelatech.com>
Subject: Small pktgen bug.
Date: Wed, 04 Nov 2009 18:22:09 -0800
Message-ID: <4AF236D1.7020006@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:47805 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755101AbZKECWE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 21:22:04 -0500
Received: from [192.168.100.195] (firewall.candelatech.com [70.89.124.249])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id nA52M9uh001520
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 4 Nov 2009 18:22:09 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is a subtle bug in pktgen tx_bytes accounting.

If one is using clone_skb, then the cur_pkt_size may be modified
without a new skb actually being created (quite yet) by setting
min_pkt_size through the proc fs.

I think if you just saved pkt_dev->skb->len before transmitting and used
that to increment pkt_dev->tx_bytes that would fix the counter
problem.

	if (unlikely(netif_tx_queue_stopped(txq) || netif_tx_queue_frozen(txq)))
		ret = NETDEV_TX_BUSY;
	else
		ret = (*xmit)(pkt_dev->skb, odev);

	switch (ret) {
	case NETDEV_TX_OK:
		txq_trans_update(txq);
		pkt_dev->last_ok = 1;
		pkt_dev->sofar++;
		pkt_dev->seq_num++;
		pkt_dev->tx_bytes += pkt_dev->cur_pkt_size;
		break;


Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

