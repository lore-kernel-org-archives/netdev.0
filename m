From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: Re: [PATCH 2/3] [UDP]: Restore missing inDatagrams increments
Date: Wed, 05 Dec 2007 16:39:48 +0800
Message-ID: <475663D4.9040806@cn.fujitsu.com>
References: <20071204125844.GA2750@gondor.apana.org.au> <20071204130109.GA3098@gondor.apana.org.au> <47560215.6050104@cn.fujitsu.com> <20071205021559.GA27707@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [222.73.24.84] ([222.73.24.84]:57067 "EHLO song.cn.fujitsu.com"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751202AbXLEImg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Dec 2007 03:42:36 -0500
In-Reply-To: <20071205021559.GA27707@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu said the following on 2007-12-5 10:15:
> +#define UDPX_INC_STATS_BH(sk, field) \
> +	do { \
> +		if ((sk)->sk_family == AF_INET) \
> +			UDP_INC_STATS_BH(field, 0); \
> +		else \
> +			UDP6_INC_STATS_BH(field, 0); \
> +	} while (0);
> +

Because there are lot of address families, not only AF_INET
and AF_INET6.
How about?
---
switch (sk->sk_family) {
case AF_INET:
	...
case AF_INET6:
	...
default:
}

--
WCN

