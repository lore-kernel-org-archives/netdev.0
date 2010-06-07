From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: RFS seems to have incompatiblities with bridged vlans
Date: Mon, 7 Jun 2010 14:59:10 -0700
Message-ID: <20100607145910.2458ac87@nehalam>
References: <62C40338-045A-417E-9B90-E59A320E1343@dlh.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Peter Lieven <pl@dlh.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:34145 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752431Ab0FGV7Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Jun 2010 17:59:16 -0400
In-Reply-To: <62C40338-045A-417E-9B90-E59A320E1343@dlh.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 7 Jun 2010 22:36:11 +0200
Peter Lieven <pl@dlh.net> wrote:

> Hi,
> 
> i today tried out 2.6.32-rc2 and I see a lot of warning messages like this:
> 
> Jun  7 22:33:15 172.21.55.20 kernel: [ 3012.575884] br141 received packet on queue 4, but number of RX queues is 1
> 
> The host is a SMP system with 8 cores, so I think there is expected to be one rx queue per CPU, but it seems
> the bridge iface has only one.
> 

The bridge interface has no queues. It doesn't queue any packets. 
The test in receive packet path is not appropriate in this case.
Not sure what the right fix is. Pretending the bridge device has
multiple queues (num_queues == NUM_CPUS) is a possibility but
seems like overhead without real increase in parallelism.



