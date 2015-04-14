From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Patch net-next] fou: avoid missing unlock in failure path
Date: Tue, 14 Apr 2015 10:01:09 -0700
Message-ID: <1429030869.7346.41.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1429029150-31710-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Tom Herbert <tom@herbertland.com>,
	Dan Carpenter <dan.carpenter@oracle.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f179.google.com ([209.85.223.179]:34359 "EHLO
	mail-ie0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932176AbbDNRBM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2015 13:01:12 -0400
Received: by iedfl3 with SMTP id fl3so22723187ied.1
        for <netdev@vger.kernel.org>; Tue, 14 Apr 2015 10:01:11 -0700 (PDT)
In-Reply-To: <1429029150-31710-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-04-14 at 09:32 -0700, Cong Wang wrote:
> Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
> Cc: Dan Carpenter <dan.carpenter@oracle.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> ---
>  net/ipv4/fou.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
> 
> diff --git a/net/ipv4/fou.c b/net/ipv4/fou.c
> index 2637102..1df3399 100644
> --- a/net/ipv4/fou.c
> +++ b/net/ipv4/fou.c
> @@ -711,11 +711,10 @@ static int fou_nl_dump(struct sk_buff *skb, struct netlink_callback *cb)
>  				    cb->nlh->nlmsg_seq, NLM_F_MULTI,
>  				    skb, FOU_CMD_GET);
>  		if (ret)
> -			goto done;
> +			break;
>  	}
>  	mutex_unlock(&fn->fou_lock);
>  
> -done:
>  	cb->args[0] = idx;
>  	return skb->len;
>  }

When was this bug added ?
