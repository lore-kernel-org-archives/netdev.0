From: Eldon Koyle <esk-netdev@esk.cs.usu.edu>
Subject: ixgbe RSS not working as expected with 8021q and bridging
Date: Thu, 10 Dec 2009 16:11:03 -0700
Message-ID: <20091210231103.GA20231@esk.cs.usu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from esk.cs.usu.edu ([129.123.28.15]:47149 "EHLO esk.cs.usu.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754891AbZLJXkH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Dec 2009 18:40:07 -0500
Received: from esk by esk.cs.usu.edu with local (Exim 4.69)
	(envelope-from <esk@esk.cs.usu.edu>)
	id 1NIsA3-0005IK-R6
	for netdev@vger.kernel.org; Thu, 10 Dec 2009 16:11:03 -0700
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We have built a firewall with two 10 Gbit interfaces (intel 82598EB) and
are doing some testing.  A simple bridge between the two interfaces acts
as expected with packets being distributed fairly evenly across all of
the rx/tx queues.

We then switched to tagged vlans on both interfaces (10 vlans each, 8
source and 8 dest addresses per vlan) and bridged eth0.N to eth1.N, and
many of our queues (and CPUs) remained idle, and all of our VLAN traffic
went out on the same tx queue.  Are multiple transmit queues supported
with 802.1q?  How do we figure out what is causing some of our receive
queues to be unused?

We are using 2.6.31 (from Debian) and ixgbe-2.0.44.14 .

eth0:
     tx_queue_0_packets: 0
     tx_queue_1_packets: 0
     tx_queue_2_packets: 138
     tx_queue_3_packets: 123960995
     tx_queue_4_packets: 0
     tx_queue_5_packets: 0
     tx_queue_6_packets: 36
     tx_queue_7_packets: 36833
     rx_queue_0_packets: 24841529
     rx_queue_1_packets: 24832268
     rx_queue_2_packets: 0
     rx_queue_3_packets: 24835876
     rx_queue_4_packets: 0
     rx_queue_5_packets: 24833101
     rx_queue_6_packets: 0
     rx_queue_7_packets: 24833463

eth1:
     tx_queue_0_packets: 0
     tx_queue_1_packets: 0
     tx_queue_2_packets: 138
     tx_queue_3_packets: 124174228
     tx_queue_4_packets: 0
     tx_queue_5_packets: 0
     tx_queue_6_packets: 82
     tx_queue_7_packets: 78
     rx_queue_0_packets: 24832675
     rx_queue_1_packets: 24789655
     rx_queue_2_packets: 0
     rx_queue_3_packets: 24793220
     rx_queue_4_packets: 0
     rx_queue_5_packets: 24797484
     rx_queue_6_packets: 0
     rx_queue_7_packets: 24786851


-- 
Eldon Koyle
-- 
BOFH excuse #46:
waste water tank overflowed onto computer
