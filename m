From: Brian Haley <brian.haley@hp.com>
Subject: Re: [RFC, PATCH] IPV6 : add 64 bits components in struct in6_addr
 to speedup ipv6_addr_equal() & ipv6_addr_any()
Date: Mon, 30 Apr 2007 12:27:07 -0400
Message-ID: <463618DB.7020309@hp.com>
References: <20070430162851.ca3c7869.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: yoshfuji Hideaki <yoshfuji@linux-ipv6.org>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.hp.com ([192.151.27.10]:34575 "EHLO mailhub.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1946340AbXD3Q1K (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Apr 2007 12:27:10 -0400
In-Reply-To: <20070430162851.ca3c7869.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet wrote:
> On 64bit arches, we can speedup some IPV6 addresses compares, using 64 bits fields in struct in6_addr.

> diff --git a/include/linux/in6.h b/include/linux/in6.h
> index 2a61c82..a4241a6 100644
> --- a/include/linux/in6.h
> +++ b/include/linux/in6.h
> @@ -34,10 +34,12 @@ struct in6_addr
>  		__u8		u6_addr8[16];
>  		__be16		u6_addr16[8];
>  		__be32		u6_addr32[4];
> +		__be64		u6_addr64[2];
>  	} in6_u;
>  #define s6_addr			in6_u.u6_addr8
>  #define s6_addr16		in6_u.u6_addr16
>  #define s6_addr32		in6_u.u6_addr32
> +#define s6_addr64		in6_u.u6_addr64
>  };

I also had this idea back in 2004:

 >> I will eventually do a 64-bit comparison to see if putting an
 >> #ifdef CONFIG_64BIT is worth it.
 >
 > No, because we cannot assume 64bit alignment.
 >
 > --yoshfuji

The problem is that drivers don't necessarily align the address on the 
correct boundary, so on some 64-bit arches this could be fatal.  There's 
ways around it since I did it in a previous life, but you'd need to copy 
the addresses and hide them in the skb in the rare case, neither of 
which is a great thing to do.

Unless Yoshifuji has a better solution...

-Brian
