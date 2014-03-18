From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] net: sched: use no more than one page in
 struct fw_head
Date: Tue, 18 Mar 2014 14:18:32 -0400 (EDT)
Message-ID: <20140318.141832.128982738782126838.davem@davemloft.net>
References: <20140317.223151.719003141867577870.davem@davemloft.net>
	<1395111761.9114.11.camel@edumazet-glaptop2.roam.corp.google.com>
	<1395112849.9114.17.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: john.fastabend@gmail.com, netdev@vger.kernel.org, tgraf@suug.ch
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54215 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757008AbaCRSSf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Mar 2014 14:18:35 -0400
In-Reply-To: <1395112849.9114.17.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 17 Mar 2014 20:20:49 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> In commit b4e9b520ca5d ("[NET_SCHED]: Add mask support to fwmark
> classifier") Patrick added an u32 field in fw_head, making it slightly
> bigger than one page.
> 
> Lets use 256 slots to make fw_hash() more straight forward, and move
> @mask to the beginning of the structure as we often use a small number
> of skb->mark. @mask and first hash buckets share the same cache line.
> 
> This brings back the memory usage to less than 4000 bytes, and permits
> John to add a rcu_head at the end of the structure later without any
> worry.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
