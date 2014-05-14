From: David Miller <davem@davemloft.net>
Subject: Re: net: unix: Align send data_len up to PAGE_SIZE
Date: Wed, 14 May 2014 15:15:04 -0400 (EDT)
Message-ID: <20140514.151504.1740922429122469259.davem@davemloft.net>
References: <1399906332.31472.1.camel@tkhai>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com
To: ktkhai@parallels.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53492 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751877AbaENTPG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2014 15:15:06 -0400
In-Reply-To: <1399906332.31472.1.camel@tkhai>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kirill Tkhai <ktkhai@parallels.com>
Date: Mon, 12 May 2014 18:52:12 +0400

>  		data_len = min_t(size_t,
>  				 len - SKB_MAX_ALLOC,
>  				 MAX_SKB_FRAGS * PAGE_SIZE);
> +		data_len = min_t(size_t,
> +				 len,
> +				 PAGE_ALIGN(data_len));
> +	}

When I see:

		x = min(y - N, z1);
		x = min(y, z2);

I'm a bit suspicious.  Why are you not subtracting the constant
factor out of the first variable in the second min() call?
