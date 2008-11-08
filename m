From: Robert Olsson <robert@robur.slu.se>
Subject: [PATCH] pktgen: fix multiple queue warning
Date: Sat, 8 Nov 2008 12:29:32 +0100
Message-ID: <18709.30748.784246.990265@robur.slu.se>
References: <20081028193042.22781.15774.stgit@gitlost.lost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, jeff@garzik.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Robert Olsson <robert.olsson@its.uu.se>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from robur.slu.se ([130.238.98.12]:49940 "EHLO robur.slu.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753067AbYKHL3e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 8 Nov 2008 06:29:34 -0500
In-Reply-To: <20081028193042.22781.15774.stgit@gitlost.lost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Jeff Kirsher writes:


 > -	if (ntxq <= num_online_cpus() && (pkt_dev->flags & F_QUEUE_MAP_CPU)) {
 > +	if (ntxq > num_online_cpus() && (pkt_dev->flags & F_QUEUE_MAP_CPU)) {
 >  		printk(KERN_WARNING "pktgen: WARNING: QUEUE_MAP_CPU "
 > -		       "disabled because CPU count (%d) exceeds number ",
 > -		       num_online_cpus());
 > -		printk(KERN_WARNING "pktgen: WARNING: of tx queues "
 > -		       "(%d) on %s \n", ntxq, pkt_dev->odev->name);

 
 Jeff,

 This triggers with the niu driver which has 12 TX queues on our 8 CPU-core 
 system. Might be best to make sure that pkt_dev->cur_queue_map never exceeds 
 ntxq.

pkt_dev->cur_queue_map  = pkt_dev->cur_queue_map % pkt_dev->odev->real_num_tx_queues;

 Cheers.
					--ro
 
 
