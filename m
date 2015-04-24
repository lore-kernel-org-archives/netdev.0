From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp: avoid looping in tcp_send_fin()
Date: Fri, 24 Apr 2015 11:07:44 -0400 (EDT)
Message-ID: <20150424.110744.1450285878142227065.davem@davemloft.net>
References: <1429807692.22254.59.camel@edumazet-glaptop2.roam.corp.google.com>
	<20150423.131234.2270841808622853554.davem@davemloft.net>
	<1429810959.22254.74.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johunt@akamai.com, netdev@vger.kernel.org, edumazet@google.com,
	ncardwell@google.com, ycheng@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50918 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757392AbbDXPHq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Apr 2015 11:07:46 -0400
In-Reply-To: <1429810959.22254.74.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 23 Apr 2015 10:42:39 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Presence of an unbound loop in tcp_send_fin() had always been hard
> to explain when analyzing crash dumps involving gigantic dying processes
> with millions of sockets.
> 
> Lets try a different strategy :
> 
> In case of memory pressure, try to add the FIN flag to last packet
> in write queue, even if packet was already sent. TCP stack will
> be able to deliver this FIN after a timeout event. Note that this
> FIN being delivered by a retransmit, it also carries a Push flag
> given our current implementation.
> 
> By checking sk_under_memory_pressure(), we anticipate that cooking
> many FIN packets might deplete tcp memory.
> 
> In the case we could not allocate a packet, even with __GFP_WAIT
> allocation, then not sending a FIN seems quite reasonable if it allows
> to get rid of this socket, free memory, and not block the process from
> eventually doing other useful work.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

This is really nice, and long overdue, so I'm going to apply this now.

Thanks Eric.
