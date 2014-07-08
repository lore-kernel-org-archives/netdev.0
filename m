From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: Performance fix for process_backlog
Date: Mon, 07 Jul 2014 19:25:19 -0700 (PDT)
Message-ID: <20140707.192519.1302110449886053251.davem@davemloft.net>
References: <alpine.DEB.2.02.1406300949290.5624@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48297 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751412AbaGHCZW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jul 2014 22:25:22 -0400
In-Reply-To: <alpine.DEB.2.02.1406300949290.5624@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Mon, 30 Jun 2014 09:50:40 -0700 (PDT)

> In process_backlog the input_pkt_queue is only checked once for new
> packets and quota is artificially reduced to reflect precisely the
> number of packets on the input_pkt_queue so that the loop exits
> appropriately.
> 
> This patches changes the behavior to be more straightforward and
> less convoluted. Packets are processed until either the quota
> is met or there are no more packets to process.
> 
> This patch seems to provide a small, but noticeable performance
> improvement. The performance improvement is a result of staying
> in the process_backlog loop longer which can reduce number of IPI's.
> 
> Performance data using super_netperf TCP_RR with 200 flows:
...
> Signed-off-by: Tom Herbert <therbert@google.com>

Applied, thanks Tom.
