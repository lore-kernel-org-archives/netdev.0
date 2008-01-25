From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] fib_trie: rescan if key is lost during dump
Date: Fri, 25 Jan 2008 09:23:00 +0100
Message-ID: <20080125082300.GA2257@ff.dom.local>
References: <20080124135112.32b5c1c7@deepthought>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, kaber@trash.net,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.155]:12794 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755335AbYAYIQS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jan 2008 03:16:18 -0500
Received: by fg-out-1718.google.com with SMTP id e21so566897fga.17
        for <netdev@vger.kernel.org>; Fri, 25 Jan 2008 00:16:16 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20080124135112.32b5c1c7@deepthought>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 24-01-2008 22:51, Stephen Hemminger wrote:
> Normally during a dump the key of the last dumped entry is used for
> continuation, but since lock is dropped it might be lost. In that case
> fallback to the old counter based N^2 behaviour.  This means the dump will end up
> skipping some routes which matches what FIB_HASH does.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
...
> @@ -1918,35 +1931,37 @@ static int fn_trie_dump(struct fib_table
>  	struct leaf *l;
>  	struct trie *t = (struct trie *) tb->tb_data;
>  	t_key key = cb->args[2];
> +	int count = cb->args[3];
>  
>  	rcu_read_lock();

Sorry, but I lost the point: is rtnl held or not held here at the moment?
If held, how this rcu_read_lock can help? Maybe some additional comment
in the code?

Thanks,
Jarek P.
