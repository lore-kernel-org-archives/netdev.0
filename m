From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] ipv6: make sure dev is not NULL before call
 ip6_frag_reasm
Date: Mon, 08 May 2017 07:50:30 -0700
Message-ID: <1494255030.7796.56.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1494212964-17861-1-git-send-email-liuhangbin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Hangbin Liu <liuhangbin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:36093 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754315AbdEHOud (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 8 May 2017 10:50:33 -0400
Received: by mail-pg0-f67.google.com with SMTP id 64so3364266pgb.3
        for <netdev@vger.kernel.org>; Mon, 08 May 2017 07:50:33 -0700 (PDT)
In-Reply-To: <1494212964-17861-1-git-send-email-liuhangbin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-05-08 at 11:09 +0800, Hangbin Liu wrote:
> Since ip6_frag_reasm() will call __in6_dev_get(dev), which will access
> dev->ip6_ptr. We need to make sure dev is not NULL.
> 
> Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
> ---
>  net/ipv6/reassembly.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
> index e1da5b8..e3ebd62 100644
> --- a/net/ipv6/reassembly.c
> +++ b/net/ipv6/reassembly.c
> @@ -348,7 +348,7 @@ static int ip6_frag_queue(struct frag_queue *fq, struct sk_buff *skb,
>  		fq->q.flags |= INET_FRAG_FIRST_IN;
>  	}
>  
> -	if (fq->q.flags == (INET_FRAG_FIRST_IN | INET_FRAG_LAST_IN) &&
> +	if (dev && fq->q.flags == (INET_FRAG_FIRST_IN | INET_FRAG_LAST_IN) &&
>  	    fq->q.meat == fq->q.len) {
>  		int res;
>  		unsigned long orefdst = skb->_skb_refdst;


How dev could be possibly NULL here ?
