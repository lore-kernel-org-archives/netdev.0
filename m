From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] netlink: move nl_table in read_mostly section
Date: Thu, 14 May 2015 17:49:35 -0400 (EDT)
Message-ID: <20150514.174935.933671221344067206.davem@davemloft.net>
References: <1431476690.566.107.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42341 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161106AbbENVti (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 May 2015 17:49:38 -0400
In-Reply-To: <1431476690.566.107.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 12 May 2015 17:24:50 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> netlink sockets creation and deletion heavily modify nl_table_users
> and nl_table_lock.
> 
> If nl_table is sharing one cache line with one of them, netlink
> performance is really bad on SMP.
> 
> ffffffff81ff5f00 B nl_table
> ffffffff81ff5f0c b nl_table_users
> 
> Putting nl_table in read_mostly section increased performance
> of my open/delete netlink sockets test by about 80 %
> 
> This came up while diagnosing a getaddrinfo() problem.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
