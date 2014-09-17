From: Jesper Dangaard Brouer <jbrouer@redhat.com>
Subject: CPU scheduler to TXQ binding? (ixgbe vs. igb)
Date: Wed, 17 Sep 2014 15:26:53 +0200
Message-ID: <20140917152653.1c824a22@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <therbert@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:2340 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754720AbaIQN1B (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Sep 2014 09:27:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The CPU to TXQ binding behavior of ixgbe vs. igb NIC driver are
somehow different.  Normally I setup NIC IRQ-to-CPU bindings 1-to-1,
with script set_irq_affinity [1].

For forcing use of a specific HW TXQ, I normally force the CPU binding
of the process, either with "taskset" or with "netperf -T lcpu,rcpu".

This works fine with driver ixgbe, but not with driver igb.  That is
with igb, the program forced to specific CPU, can still use another
TXQ. What am I missing?


I'm monitoring this with both:
 1) watch -d sudo tc -s -d q ls dev ethXX
 2) https://github.com/ffainelli/bqlmon

[1] https://github.com/netoptimizer/network-testing/blob/master/bin/set_irq_affinity
-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
