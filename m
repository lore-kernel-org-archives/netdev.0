From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tun, bpf: fix suspicious RCU usage in
 tun_{attach,detach}_filter
Date: Thu, 31 Mar 2016 15:50:32 -0400 (EDT)
Message-ID: <20160331.155032.901890572470890195.davem@davemloft.net>
References: <56FD795C.9090903@stressinduktion.org>
	<20160331.153630.1640223846173244431.davem@davemloft.net>
	<56FD7F0B.5090602@stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, eric.dumazet@gmail.com,
	alexei.starovoitov@gmail.com, mkubecek@suse.cz,
	sasha.levin@oracle.com, jslaby@suse.cz, mst@redhat.com,
	netdev@vger.kernel.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58162 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752578AbcCaTue (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Mar 2016 15:50:34 -0400
In-Reply-To: <56FD7F0B.5090602@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Thu, 31 Mar 2016 21:48:27 +0200

> Tightest solution would probably be to combine both patches.
> 
> bool called_by_tuntap;
> 
> old_fp = rcu_dereference_protected(sk->sk_filter, called_by_tuntap ?
> lockdep_rtnl_is_held() : lockdep_sock_is_held());

Ok, I see what you're saying.

I misunderstood how the RTNL lockdep checks work and thought we could
get false positives from other entities taking RTNL.

Can you cook up the combined patch?

Thanks.
