From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sctp: check duplicate node before inserting a new
 transport
Date: Fri, 17 Feb 2017 15:19:07 -0500 (EST)
Message-ID: <20170217.151907.1987368624831286456.davem@davemloft.net>
References: <ba2afff1b2cf9e0026a23dde02d207583efa3d83.1487320524.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        marcelo.leitner@gmail.com, nhorman@tuxdriver.com,
        vyasevich@gmail.com
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48356 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934365AbdBQUTJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 17 Feb 2017 15:19:09 -0500
In-Reply-To: <ba2afff1b2cf9e0026a23dde02d207583efa3d83.1487320524.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Fri, 17 Feb 2017 16:35:24 +0800


> +	list = rhltable_lookup(&sctp_transport_hashtable, &arg,
> +			       sctp_hash_params);
> +
> +	rhl_for_each_entry_rcu(transport, tmp, list, node)
> +		if (transport->asoc->ep == t->asoc->ep) {
> +			err = -EEXIST;
> +			goto out;
> +		}
> +
>  	err = rhltable_insert_key(&sctp_transport_hashtable, &arg,
>  				  &t->node, sctp_hash_params);
> +
> +out:

Well, what if another thread of control inserts a matching transport
after you've checked the list but before rhltable_insert_key() does
it's work?

What write side lock is being held to protect the table from
modifications here?
