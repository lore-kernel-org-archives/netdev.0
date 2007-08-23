From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [IPv6] Add v4mapped address inline
Date: Fri, 24 Aug 2007 03:00:02 +0900 (JST)
Message-ID: <20070824.030002.56135604.yoshfuji@linux-ipv6.org>
References: <46CDB896.8040408@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	lksctp-developers@lists.sourceforge.net, yoshfuji@linux-ipv6.org
To: brian.haley@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:58205 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753208AbXHWR6v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2007 13:58:51 -0400
In-Reply-To: <46CDB896.8040408@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

In article <46CDB896.8040408@hp.com> (at Thu, 23 Aug 2007 12:40:54 -0400), Brian Haley <brian.haley@hp.com> says:

> diff --git a/include/net/ipv6.h b/include/net/ipv6.h
> index 9059e0e..c2b6c11 100644
> --- a/include/net/ipv6.h
> +++ b/include/net/ipv6.h
> @@ -418,6 +418,12 @@ static inline int ipv6_addr_diff(const struct in6_addr *a1, const struct in6_add
>  	return __ipv6_addr_diff(a1, a2, sizeof(struct in6_addr));
>  }
>  
> +static inline int ipv6_addr_v4mapped(const struct in6_addr *a)
> +{
> +	return ((a->s6_addr32[0] | a->s6_addr32[1]) == 0 && 
> +		 a->s6_addr32[2] == htonl(0x0000ffff)); 
> +}
> +

Please put this just after ipv6_addr_any(), not after
ipv6_addr_diff().

--yoshfuji
