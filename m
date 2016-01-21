From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] net: sock: remove dead cgroup methods from struct proto
Date: Thu, 21 Jan 2016 15:56:28 -0500
Message-ID: <20160121205628.GA14909@cmpxchg.org>
References: <1453402871-2548-1-git-send-email-hannes@cmpxchg.org>
 <56A131D7.4040102@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gum.cmpxchg.org ([85.214.110.215]:53968 "EHLO gum.cmpxchg.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751103AbcAUU5L (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Jan 2016 15:57:11 -0500
Content-Disposition: inline
In-Reply-To: <56A131D7.4040102@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 21, 2016 at 10:30:31PM +0300, Sergei Shtylyov wrote:
> Hello.
> 
> On 01/21/2016 10:01 PM, Johannes Weiner wrote:
> 
> >The cgroup methods are no longer used after baac50b ("net:
> 
>    12-digit ID is now enforced by scripts/checkpatch.pl.

Thanks for the headsup, that hasn't made it into my copy of
checkpatch.pl yet.

Here is the updated patch:

>From ac0fd0c5f31cdc73c52fd86f40af419c1871fbcf Mon Sep 17 00:00:00 2001
From: Johannes Weiner <hannes@cmpxchg.org>
Date: Thu, 21 Jan 2016 13:34:47 -0500
Subject: [PATCH] net: sock: remove dead cgroup methods from struct proto

The cgroup methods are no longer used after baac50bbc3cd ("net:
tcp_memcontrol: simplify linkage between socket and page counter").
The hunk to delete them was included in the original patch but must
have gotten lost during conflict resolution on the way upstream.

Fixes: baac50bbc3cd ("net: tcp_memcontrol: simplify linkage between socket and page counter")
Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/net/sock.h | 12 ------------
 1 file changed, 12 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index b9e7b3d863a0..f5ea148853e2 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1036,18 +1036,6 @@ struct proto {
 #ifdef SOCK_REFCNT_DEBUG
 	atomic_t		socks;
 #endif
-#ifdef CONFIG_MEMCG_KMEM
-	/*
-	 * cgroup specific init/deinit functions. Called once for all
-	 * protocols that implement it, from cgroups populate function.
-	 * This function has to setup any files the protocol want to
-	 * appear in the kmem cgroup filesystem.
-	 */
-	int			(*init_cgroup)(struct mem_cgroup *memcg,
-					       struct cgroup_subsys *ss);
-	void			(*destroy_cgroup)(struct mem_cgroup *memcg);
-	struct cg_proto		*(*proto_cgroup)(struct mem_cgroup *memcg);
-#endif
 	int			(*diag_destroy)(struct sock *sk, int err);
 };
 
-- 
2.7.0
