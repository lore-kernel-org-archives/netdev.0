From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next] net: move inet_dport/inet_num in
 sock_common
Date: Wed, 28 Nov 2012 10:20:17 -0800
Message-ID: <1354126817.14302.451.camel@edumazet-glaptop>
References: <1354028815.14302.35.camel@edumazet-glaptop>
	 <1354037000.2116.19.camel@joe-AO722>
	 <1354051475.14302.42.camel@edumazet-glaptop>
	 <1354069414.8918.13.camel@joe-AO722>
	 <1354075918.14302.77.camel@edumazet-glaptop>
	 <1354102061.14302.84.camel@edumazet-glaptop>
	 <1354107378.14302.149.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Ling Ma <ling.ma.program@gmail.com>,
	Joe Perches <joe@perches.com>,
	Ben Hutchings <bhutchings@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:38775 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755169Ab2K1SUX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2012 13:20:23 -0500
Received: by mail-pa0-f46.google.com with SMTP id bh2so6962064pad.19
        for <netdev@vger.kernel.org>; Wed, 28 Nov 2012 10:20:23 -0800 (PST)
In-Reply-To: <1354107378.14302.149.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-11-28 at 04:56 -0800, Eric Dumazet wrote:

> +#define INET_MATCH(__sk, __net, __cookie, __saddr, __daddr, __ports, __dif)	\
> +	((inet_sk(__sk)->inet_portpair == (__ports))		&&	\
> +	 (inet_sk(__sk)->inet_addrpair == (__addrpair))		&&	\
> +	 (!(__sk)->sk_bound_dev_if	||				\
> +	   ((__sk)->sk_bound_dev_if == (__dif))) 		&& 	\
> +	 net_eq(sock_net(__sk), (__net)))
> +#define INET_TW_MATCH(__sk, __net, __cookie, __saddr, __daddr, __ports, __dif)\
> +	((inet_twsk(__sk)->tw_portpair == (__ports))	&&		\
> +	 (inet_twsk(__sk)->tw_addrpair == (__addrpair))	&&		\
> +	 (!(__sk)->sk_bound_dev_if	||				\
> +	   ((__sk)->sk_bound_dev_if == (__dif)))	&&		\
> +	 net_eq(sock_net(__sk), (__net)))

Last minute change in a param name __cookie / __addrpair

I reverted this change as the 32bit part is not using the 'cookie', so
keeping __the cookie name makes sense.

I'll fix this and add performance results in the changelog.
