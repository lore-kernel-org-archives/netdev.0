From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the akpm-current tree with the net-next
 tree
Date: Thu, 10 Dec 2015 15:54:41 +1100
Message-ID: <20151210155441.2a417341@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>
To: Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrew,

Today's linux-next merge of the akpm-current tree got a conflict in:

  include/net/sock.h

between commits:

  297dbde19cf6 ("netprio_cgroup: limit the maximum css->id to USHRT_MAX")
  2a56a1fec290 ("net: wrap sock->sk_cgrp_prioidx and ->sk_classid inside a struct")

from the net-next tree and commit:

  c4b672bd7b34 ("net: tcp_memcontrol: simplify linkage between socket and page counter")

from the akpm-current tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc include/net/sock.h
index c57e7ce0d097,edd552ef8e38..000000000000
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@@ -309,8 -292,8 +293,8 @@@ struct cg_proto
    *	@sk_send_head: front of stuff to transmit
    *	@sk_security: used by security modules
    *	@sk_mark: generic packet mark
 -  *	@sk_classid: this socket's cgroup classid
 +  *	@sk_cgrp_data: cgroup data for this cgroup
-   *	@sk_cgrp: this socket's cgroup-specific proto data
+   *	@sk_memcg: this socket's memory cgroup association
    *	@sk_write_pending: a write to stream socket waits to start
    *	@sk_state_change: callback to indicate change in the state of the sock
    *	@sk_data_ready: callback to indicate there is data to be processed
@@@ -443,8 -428,11 +427,8 @@@ struct sock 
  #ifdef CONFIG_SECURITY
  	void			*sk_security;
  #endif
 -	__u32			sk_mark;
 -#ifdef CONFIG_CGROUP_NET_CLASSID
 -	u32			sk_classid;
 -#endif
 +	struct sock_cgroup_data	sk_cgrp_data;
- 	struct cg_proto		*sk_cgrp;
+ 	struct mem_cgroup	*sk_memcg;
  	void			(*sk_state_change)(struct sock *sk);
  	void			(*sk_data_ready)(struct sock *sk);
  	void			(*sk_write_space)(struct sock *sk);
