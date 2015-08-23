From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] route: fix breakage after moving lwtunnel
 state
Date: Sun, 23 Aug 2015 16:51:03 -0700 (PDT)
Message-ID: <20150823.165103.2104601245219561984.davem@davemloft.net>
References: <a80cafb781c91314f90613c3e7d2ed4268eb4f06.1440153500.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jbenc@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47198 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753356AbbHWXvE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Aug 2015 19:51:04 -0400
In-Reply-To: <a80cafb781c91314f90613c3e7d2ed4268eb4f06.1440153500.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Benc <jbenc@redhat.com>
Date: Fri, 21 Aug 2015 12:41:14 +0200

> @@ -99,6 +99,9 @@ struct dst_entry {
>  	atomic_t		__refcnt;	/* client references	*/
>  	int			__use;
>  	unsigned long		lastuse;
> +#ifndef CONFIG_64BIT
> +	struct lwtunnel_state   *lwtstate;
> +#endif
>  	union {
>  		struct dst_entry	*next;
>  		struct rtable __rcu	*rt_next;

I'm going to apply this to fix the build error without reverting your
change entirely, but this is really an undesirable solution.

This cache line of the SKB is for write heavy members of struct
dst_entry and so if you put a read-mostly member here it's going to
result in performance problems.
