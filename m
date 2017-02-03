From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC net-next 4/4] bridge: add ability to turn off fdb
 used updates
Date: Thu, 02 Feb 2017 21:47:37 -0500 (EST)
Message-ID: <20170202.214737.1978812863222769540.davem@davemloft.net>
References: <1485876718-18091-1-git-send-email-nikolay@cumulusnetworks.com>
        <1485876718-18091-5-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
        stephen@networkplumber.org
To: nikolay@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37774 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751771AbdBCCrm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 21:47:42 -0500
In-Reply-To: <1485876718-18091-5-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Date: Tue, 31 Jan 2017 16:31:58 +0100

> @@ -197,7 +197,8 @@ int br_handle_frame_finish(struct net *net, struct sock *sk, struct sk_buff *skb
>  		if (dst->is_local)
>  			return br_pass_frame_up(skb);
>  
> -		dst->used = jiffies;
> +		if (br->used_enabled)
> +			dst->used = jiffies;

Have you tried:

	if (dst->used != jiffies)
		dst->used = jiffies;

If that isn't effective, you can tweak the test to decrease the
granularity of the value.  Basically, if dst->used is within
1 HZ of jiffies, don't do the write.

I suspect this might help a lot, and not require a new bridging
option.
