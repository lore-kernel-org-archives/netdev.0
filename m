From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pktgen: fix multiple queue warning
Date: Sun, 16 Nov 2008 23:30:06 -0800 (PST)
Message-ID: <20081116.233006.128063706.davem@davemloft.net>
References: <20081028193042.22781.15774.stgit@gitlost.lost>
	<18709.30748.784246.990265@robur.slu.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	jeff@garzik.org, jesse.brandeburg@intel.com,
	robert.olsson@its.uu.se
To: robert@robur.slu.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55939
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757501AbYKQHaG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Nov 2008 02:30:06 -0500
In-Reply-To: <18709.30748.784246.990265@robur.slu.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Robert Olsson <robert@robur.slu.se>
Date: Sat, 8 Nov 2008 12:29:32 +0100

> Jeff Kirsher writes:
> 
>  > -	if (ntxq <= num_online_cpus() && (pkt_dev->flags & F_QUEUE_MAP_CPU)) {
>  > +	if (ntxq > num_online_cpus() && (pkt_dev->flags & F_QUEUE_MAP_CPU)) {
>  >  		printk(KERN_WARNING "pktgen: WARNING: QUEUE_MAP_CPU "
>  > -		       "disabled because CPU count (%d) exceeds number ",
>  > -		       num_online_cpus());
>  > -		printk(KERN_WARNING "pktgen: WARNING: of tx queues "
>  > -		       "(%d) on %s \n", ntxq, pkt_dev->odev->name);
> 
>  This triggers with the niu driver which has 12 TX queues on our 8 CPU-core 
>  system. Might be best to make sure that pkt_dev->cur_queue_map never exceeds 
>  ntxq.
> 
> pkt_dev->cur_queue_map  = pkt_dev->cur_queue_map % pkt_dev->odev->real_num_tx_queues;

Can someone cook up a patch to fix this?

Thanks.
