From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 3/4 - rev 2] Initilize and populate age field
Date: Tue, 21 Aug 2007 12:55:42 +0200
Message-ID: <20070821105542.GN32236@postel.suug.ch>
References: <20070820134617.1226c97b.varunc@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, kaber@trash.net,
	socketcan@hartkopp.net, shemminger@linux-foundation.org,
	krkumar2@in.ibm.com, varuncha@in.ibm.com
To: Varun Chandramohan <varunc@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:53885 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751389AbXHUKzV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Aug 2007 06:55:21 -0400
Content-Disposition: inline
In-Reply-To: <20070820134617.1226c97b.varunc@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Varun Chandramohan <varunc@linux.vnet.ibm.com> 2007-08-20 13:46
> The age field is filled with the current time at the time of creation of the route. When the routes are dumped
> then the age value stored in the route structure is subtracted from the current time value and the difference is the age expressed in secs.
> 
> Signed-off-by: Varun Chandramohan <varunc@linux.vnet.ibm.com>
> @@ -985,6 +987,14 @@ int fib_dump_info(struct sk_buff *skb, u
>  			NLA_PUT_U32(skb, RTA_FLOW, fi->fib_nh[0].nh_tclassid);
>  #endif
>  	}
> +
> +	do_gettimeofday(&tv);
> +	if (!*age) {
> +		*age = timeval_to_sec(&tv);
> +		NLA_PUT_U32(skb, RTA_AGE, *age);

Why don't you take the timestamp at the time of allocating the alias?
This time-since-first-dump is very confusing.

> +	} else {
> +		NLA_PUT_U32(skb, RTA_AGE, timeval_to_sec(&tv) - *age);
> +	}
>  #ifdef CONFIG_IP_ROUTE_MULTIPATH
>  	if (fi->fib_nhs > 1) {
>  		struct rtnexthop *rtnh;
