From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2/5] netfilter: Fix format string mismatch in
 mangle_content_len()
Date: Tue, 29 Apr 2014 15:21:21 +0100
Message-ID: <20140429142119.GA12499@macbook.localnet>
References: <1396280619-31152-1-git-send-email-standby24x7@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, pablo@netfilter.org,
	kadlec@blackhole.kfki.hu, netfilter-devel@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Masanari Iida <standby24x7@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:50092 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933392AbaD2OVq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Apr 2014 10:21:46 -0400
Content-Disposition: inline
In-Reply-To: <1396280619-31152-1-git-send-email-standby24x7@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 01, 2014 at 12:43:36AM +0900, Masanari Iida wrote:
> Fix format string mismatch in mangle_connect_len()

All these patches seem like pointless noise to me. In none of these
cases can the value legitimately be negative. If anything, you should
fix the types to be unsigned.

> 
> Signed-off-by: Masanari Iida <standby24x7@gmail.com>
> ---
>  net/netfilter/nf_nat_sip.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/netfilter/nf_nat_sip.c b/net/netfilter/nf_nat_sip.c
> index b4d691d..5f98845 100644
> --- a/net/netfilter/nf_nat_sip.c
> +++ b/net/netfilter/nf_nat_sip.c
> @@ -434,7 +434,7 @@ static int mangle_content_len(struct sk_buff *skb, unsigned int protoff,
>  			      &matchoff, &matchlen) <= 0)
>  		return 0;
>  
> -	buflen = sprintf(buffer, "%u", c_len);
> +	buflen = sprintf(buffer, "%d", c_len);
>  	return mangle_packet(skb, protoff, dataoff, dptr, datalen,
>  			     matchoff, matchlen, buffer, buflen);
>  }
> -- 
> 1.9.1.352.gd393d14
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netfilter-devel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
