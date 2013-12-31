From: David Miller <davem@davemloft.net>
Subject: Re: [net-next bugfix] net, rps: fix build failure when CONFIG_RPS
 isn't set
Date: Tue, 31 Dec 2013 15:54:59 -0500 (EST)
Message-ID: <20131231.155459.1250298598367444558.davem@davemloft.net>
References: <1388521861-17410-1-git-send-email-zwu.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, therbert@google.com,
	fengguang.wu@intel.com, wuzhy@linux.vnet.ibm.com
To: zwu.kernel@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36173 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754838Ab3LaUzE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Dec 2013 15:55:04 -0500
In-Reply-To: <1388521861-17410-1-git-send-email-zwu.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhi Yong Wu <zwu.kernel@gmail.com>
Date: Wed,  1 Jan 2014 04:31:01 +0800

> @@ -846,12 +846,16 @@ static inline void sock_rps_reset_flow_hash(__u32 hash)
>  
>  static inline void sock_rps_record_flow(const struct sock *sk)
>  {
> +#ifdef CONFIG_RPS
>  	sock_rps_record_flow_hash(sk->sk_rxhash);
> +#endif
>  }

Why is this necessary?  sock_rps_record_flow_hash() is provided
unconditionally, regardless of CONFIG_RPS.

I'm not applying this, it doesn't make any sense.  Either there is
no build failure, or the existing CONFIG_RPS ifdef inside of the
implementation of sock_rps_record_flow_hash() is bogus.
