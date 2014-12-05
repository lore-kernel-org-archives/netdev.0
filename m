From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [patch net-next 1/2] net: sched: cls_basic: fix error path in
 basic_change()
Date: Fri, 05 Dec 2014 07:29:16 -0800
Message-ID: <5481CF4C.2060607@gmail.com>
References: <1417791023-28124-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, jhs@mojatatu.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f49.google.com ([209.85.218.49]:53446 "EHLO
	mail-oi0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750909AbaLEP3c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Dec 2014 10:29:32 -0500
Received: by mail-oi0-f49.google.com with SMTP id i138so579591oig.8
        for <netdev@vger.kernel.org>; Fri, 05 Dec 2014 07:29:31 -0800 (PST)
In-Reply-To: <1417791023-28124-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/05/2014 06:50 AM, Jiri Pirko wrote:
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> ---
>   net/sched/cls_basic.c | 5 ++---
>   1 file changed, 2 insertions(+), 3 deletions(-)
>
> diff --git a/net/sched/cls_basic.c b/net/sched/cls_basic.c
> index 7cf0a62..5aed341 100644
> --- a/net/sched/cls_basic.c
> +++ b/net/sched/cls_basic.c
> @@ -178,10 +178,9 @@ static int basic_change(struct net *net, struct sk_buff *in_skb,
>   			return -EINVAL;
>   	}
>
> -	err = -ENOBUFS;
>   	fnew = kzalloc(sizeof(*fnew), GFP_KERNEL);
> -	if (fnew == NULL)
> -		goto errout;
> +	if (!fnew)
> +		return -ENOBUFS;
>
>   	tcf_exts_init(&fnew->exts, TCA_BASIC_ACT, TCA_BASIC_POLICE);
>   	err = -EINVAL;
>

Nice catch, thanks!

Reviewed-by: John Fastabend <john.r.fastabend@intel.com>

-- 
John Fastabend         Intel Corporation
