From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [patch net-next 1/2] net: sched: cls_basic: fix error path in
 basic_change()
Date: Fri, 05 Dec 2014 20:07:05 +0300
Message-ID: <5481E639.1070408@cogentembedded.com>
References: <1417791023-28124-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jhs@mojatatu.com
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:43761 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751183AbaLERHJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Dec 2014 12:07:09 -0500
Received: by mail-lb0-f174.google.com with SMTP id w7so896087lbi.33
        for <netdev@vger.kernel.org>; Fri, 05 Dec 2014 09:07:07 -0800 (PST)
In-Reply-To: <1417791023-28124-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 12/05/2014 05:50 PM, Jiri Pirko wrote:

> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

    Care to explain what's wrong?

> ---
>   net/sched/cls_basic.c | 5 ++---
>   1 file changed, 2 insertions(+), 3 deletions(-)

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

WBR, Sergei
