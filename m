From: David Miller <davem@redhat.com>
Subject: Re: [PATCH net-next] tcp: fix a potential deadlock in
 tcp_get_info()
Date: Fri, 22 May 2015 13:50:42 -0400 (EDT)
Message-ID: <20150522.135042.1383929510137041615.davem@redhat.com>
References: <20150521.232541.173137306546517818.davem@davemloft.net>
	<1432266206.4060.119.camel@edumazet-glaptop2.roam.corp.google.com>
	<1432270279.4060.128.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mleitner@redhat.com, edumazet@google.com, netdev@vger.kernel.org,
	ycheng@google.com, mattmathis@google.com, cgallek@google.com,
	kafai@fb.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48897 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757504AbbEVRuo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 May 2015 13:50:44 -0400
In-Reply-To: <1432270279.4060.128.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 21 May 2015 21:51:19 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Taking socket spinlock in tcp_get_info() can deadlock, as
> inet_diag_dump_icsk() holds the &hashinfo->ehash_locks[i],
> while packet processing can use the reverse locking order.
> 
> We could avoid this locking for TCP_LISTEN states, but lockdep would
> certainly get confused as all TCP sockets share same lockdep classes.
 ...
> Lets use u64_sync infrastructure instead. As a bonus, 64bit
> arches get optimized, as these are nop for them.
> 
> Fixes: 0df48c26d841 ("tcp: add tcpi_bytes_acked to tcp_info")
> Signed-off-by: Eric Dumazet <edumazet@google.com>

This bug exists in 'net' so I've applied it there.

Thanks Eric.
