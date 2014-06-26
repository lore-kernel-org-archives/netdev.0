From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv4: fix dst race in sk_dst_get()
Date: Wed, 25 Jun 2014 17:42:14 -0700 (PDT)
Message-ID: <20140625.174214.1193347044692011852.davem@davemloft.net>
References: <alpine.DEB.2.02.1406221202460.14871@dtop>
	<1403512412.16682.23.camel@edumazet-glaptop2.roam.corp.google.com>
	<1403629511.3796.35.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dormando@rydia.net, preobr@google.com,
	steffen.klassert@secunet.com, paulmck@linux.vnet.ibm.com,
	netdev@vger.kernel.org, kcc@google.com, dvyukov@google.com,
	larsbull@google.com, edumazet@google.com, brutus@google.com,
	maze@google.com, alexei.starovoitov@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39626 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756873AbaFZAmR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2014 20:42:17 -0400
In-Reply-To: <1403629511.3796.35.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 24 Jun 2014 10:05:11 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> When IP route cache had been removed in linux-3.6, we broke assumption
> that dst entries were all freed after rcu grace period. DST_NOCACHE
> dst were supposed to be freed from dst_release(). But it appears
> we want to keep such dst around, either in UDP sockets or tunnels.
> 
> In sk_dst_get() we need to make sure dst refcount is not 0
> before incrementing it, or else we might end up freeing a dst
> twice.
> 
> DST_NOCACHE set on a dst does not mean this dst can not be attached
> to a socket or a tunnel.
> 
> Then, before actual freeing, we need to observe a rcu grace period
> to make sure all other cpus can catch the fact the dst is no longer
> usable.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Dormando <dormando@rydia.net>

Applied and queued up for -stable, thanks Eric.
