From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next v3 3/6] net_sched: mirred: remove action when
 the target device is gone
Date: Fri, 13 Dec 2013 07:07:49 -0500
Message-ID: <52AAF895.8090805@mojatatu.com>
References: <1386913673-8210-1-git-send-email-xiyou.wangcong@gmail.com> <1386913673-8210-4-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f181.google.com ([209.85.223.181]:35244 "EHLO
	mail-ie0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752583Ab3LMMHv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Dec 2013 07:07:51 -0500
Received: by mail-ie0-f181.google.com with SMTP id e14so2489561iej.26
        for <netdev@vger.kernel.org>; Fri, 13 Dec 2013 04:07:51 -0800 (PST)
In-Reply-To: <1386913673-8210-4-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/13/13 00:47, Cong Wang wrote:
> When the target device is removed, the mirred action is
> still there but with the dev pointer setting to NULL.
> This makes the output from 'tc filter' ugly. There is no
> reason to keep it.
>
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> ---
>   include/net/tc_act/tc_mirred.h |  4 +++-
>   net/sched/act_mirred.c         | 15 +++++++--------
>   2 files changed, 10 insertions(+), 9 deletions(-)
>
> diff --git a/include/net/tc_act/tc_mirred.h b/include/net/tc_act/tc_mirred.h
> index cfe2943..2026cf6 100644
> --- a/include/net/tc_act/tc_mirred.h
> +++ b/include/net/tc_act/tc_mirred.h
> @@ -7,9 +7,11 @@ struct tcf_mirred {
>   	struct tcf_common	common;
>   	int			tcfm_eaction;
>   	int			tcfm_ifindex;
> -	int			tcfm_ok_push;
> +	unsigned int		tcfm_ok_push:1;
> +	unsigned int		tcfm_bind:1;

What has the above cleverness got to do with anything you intended?

cheers,
jamal
