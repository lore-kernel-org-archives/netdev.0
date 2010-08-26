From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: fix three tcp sysctls tuning
Date: Wed, 25 Aug 2010 23:02:40 -0700 (PDT)
Message-ID: <20100825.230240.104045673.davem@davemloft.net>
References: <20100825.165759.27789477.davem@davemloft.net>
	<20100826003834.GA17882@kryten>
	<1282799753.2681.714.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: anton@samba.org, netdev@vger.kernel.org, miltonm@bga.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43233
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751922Ab0HZGCZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Aug 2010 02:02:25 -0400
In-Reply-To: <1282799753.2681.714.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 26 Aug 2010 07:15:53 +0200

> As discovered by Anton Blanchard, current code to autotune 
> tcp_death_row.sysctl_max_tw_buckets, sysctl_tcp_max_orphans and
> sysctl_max_syn_backlog makes litle sense.
> 
> The bigger a page is, the less tcp_max_orphans is : 4096 on a 512GB
> machine in Anton's case.
> 
> (tcp_hashinfo.bhash_size * sizeof(struct inet_bind_hashbucket))
> is much bigger if spinlock debugging is on. Its wrong to select bigger
> limits in this case (where kernel structures are also bigger)
> 
> bhash_size max is 65536, and we get this value even for small machines. 
> 
> A better ground is to use size of ehash table, this also makes code
> shorter and more obvious.
> 
> Based on a patch from Anton, and another from David.
> 
> Reported-and-tested-by: Anton Blanchard <anton@samba.org>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

I had something in my tree already, but since I didn't push it out
it's just as easy for me to use this patch instead :-)

Thanks everyone!
