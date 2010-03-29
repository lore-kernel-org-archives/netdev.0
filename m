From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH net-next-2.6] ipv6: Use __fls() instead of fls() in __ipv6_addr_diff().
Date: Tue, 30 Mar 2010 00:49:07 +0900
Message-ID: <4BB0CBF3.805@linux-ipv6.org>
References: <201003260801.o2Q8134t023352@94.43.138.210.xn.2iij.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:56480 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751156Ab0C2Pt3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Mar 2010 11:49:29 -0400
In-Reply-To: <201003260801.o2Q8134t023352@94.43.138.210.xn.2iij.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry, I withdraw this because this is incorrect;
__fls() returns fls() - 1.

--yoshfuji

(2010/03/26 17:01), YOSHIFUJI Hideaki wrote:
> Because we have ensured that the argument is non-zero,
> it is better to use __fls() and generate better code.
> 
> Signed-off-by: YOSHIFUJI Hideaki<yoshfuji@linux-ipv6.org>
> ---
>   include/net/ipv6.h |    2 +-
>   1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/include/net/ipv6.h b/include/net/ipv6.h
> index e72fb10..619ab34 100644
> --- a/include/net/ipv6.h
> +++ b/include/net/ipv6.h
> @@ -422,7 +422,7 @@ static inline int __ipv6_addr_diff(const void *token1, const void *token2, int a
>   	for (i = 0; i<  addrlen; i++) {
>   		__be32 xb = a1[i] ^ a2[i];
>   		if (xb)
> -			return i * 32 + 32 - fls(ntohl(xb));
> +			return i * 32 + 32 - __fls(ntohl(xb));
>   	}
> 
>   	/*

