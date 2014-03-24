From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 4/9] net: ptp: use
 sk_unattached_filter_create() for BPF
Date: Mon, 24 Mar 2014 18:39:52 -0400 (EDT)
Message-ID: <20140324.183952.668431875118859796.davem@davemloft.net>
References: <1395404418-25376-1-git-send-email-dborkman@redhat.com>
	<1395404418-25376-5-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@plumgrid.com, netdev@vger.kernel.org,
	richard.cochran@omicron.at, jbenc@redhat.com
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45606 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751131AbaCXWjy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Mar 2014 18:39:54 -0400
In-Reply-To: <1395404418-25376-5-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Fri, 21 Mar 2014 13:20:13 +0100

> @@ -135,5 +137,10 @@ EXPORT_SYMBOL_GPL(skb_defer_rx_timestamp);
>  
>  void __init skb_timestamping_init(void)
>  {
> -	BUG_ON(sk_chk_filter(ptp_filter, ARRAY_SIZE(ptp_filter)));
> +	struct sock_filter ptp_filter[] = { PTP_FILTER };

Perhaps you want this to be static or static const?  Why copy
PTP_FILTER onto the stack at run time?

> +	struct sock_fprog ptp_prog = {
> +		.len = ARRAY_SIZE(ptp_filter), .filter = ptp_filter,
> +	};
> +
> +	BUG_ON(sk_unattached_filter_create(&ptp_insns, &ptp_prog));
>  }
