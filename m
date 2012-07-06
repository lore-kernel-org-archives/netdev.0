From: David Miller <davem@davemloft.net>
Subject: Re: BUG: unable to handle kernel paging request at 00000000d8be176d
Date: Thu, 05 Jul 2012 23:42:29 -0700 (PDT)
Message-ID: <20120705.234229.526162609862035833.davem@davemloft.net>
References: <20120705.142200.1828988382587831318.davem@davemloft.net>
	<20120706055859.GA27693@localhost>
	<1341555227.3265.54.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: wfg@linux.intel.com, netdev@vger.kernel.org,
	steffen.klassert@secunet.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33672 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751230Ab2GFGma (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jul 2012 02:42:30 -0400
In-Reply-To: <1341555227.3265.54.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 06 Jul 2012 08:13:47 +0200

> @@ -975,7 +975,7 @@ static int ip6_dst_lookup_tail(struct sock *sk,
>  	 * dst entry of the nexthop router
>  	 */
>  	rcu_read_lock();
> -	rt = (struct rt6_info *) dst;
> +	rt = (struct rt6_info *) *dst;
>  	n = rt->n;
>  	if (n && !(n->nud_state & NUD_VALID)) {
>  		struct inet6_ifaddr *ifp;

This is obviously correct, please submit this formally.

Fengguang Wu can I ask you politely not to quote the quilty patch in
it's entirety when reporting bugs?  That screws up my workflow because
that patch goes then gets installed as a new patch in patchwork and I
have to therefore tick it off every time you report a bug.
