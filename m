From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: codel: fix build errors
Date: Mon, 14 May 2012 17:59:21 -0400 (EDT)
Message-ID: <20120514.175921.1196526858340183817.davem@davemloft.net>
References: <1337032626-7104-1-git-send-email-levinsasha928@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, dave.taht@bufferbloat.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: levinsasha928@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:59806 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757935Ab2ENWAZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 May 2012 18:00:25 -0400
In-Reply-To: <1337032626-7104-1-git-send-email-levinsasha928@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sasha Levin <levinsasha928@gmail.com>
Date: Mon, 14 May 2012 23:57:06 +0200

> Fix the following build error:
  ...
> Signed-off-by: Sasha Levin <levinsasha928@gmail.com>

Applied, but:

>  	struct tc_fq_codel_xstats st = {
>  		.type				= TCA_FQ_CODEL_XSTATS_QDISC,
> -		.qdisc_stats.maxpacket		= q->cstats.maxpacket,
> -		.qdisc_stats.drop_overlimit	= q->drop_overlimit,
> -		.qdisc_stats.ecn_mark		= q->cstats.ecn_mark,
> -		.qdisc_stats.new_flow_count	= q->new_flow_count,
>  	};
>  	struct list_head *pos;
>  
> +	st.qdisc_stats.maxpacket = q->cstats.maxpacket;
> +	st.qdisc_stats.drop_overlimit = q->drop_overlimit;
> +	st.qdisc_stats.ecn_mark = q->cstats.ecn_mark;
> +	st.qdisc_stats.new_flow_count = q->new_flow_count;
> +

This is now a very inefficient initialization of this structure.

GCC is going to fill all the non-explictly-initialized fields with
zero, then we'll write to the same fields again in the st.qdisc*
assignments.

Eric please resolve this, I hate knowing we have code like this :-)
