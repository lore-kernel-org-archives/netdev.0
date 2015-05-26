From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH] sched: Avoid NULL pointer in the function, qdisc_get_rtab
Date: Tue, 26 May 2015 05:31:01 -0400
Message-ID: <55643D55.5070709@mojatatu.com>
References: <1432315985-11857-1-git-send-email-xerofoify@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Nicholas Krause <xerofoify@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:35060 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753367AbbEZNsE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2015 09:48:04 -0400
Received: by igbyr2 with SMTP id yr2so58402511igb.0
        for <netdev@vger.kernel.org>; Tue, 26 May 2015 06:48:04 -0700 (PDT)
In-Reply-To: <1432315985-11857-1-git-send-email-xerofoify@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/22/15 13:33, Nicholas Krause wrote:

>
> diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
> index ad9eed7..44a8995 100644
> --- a/net/sched/sch_api.c
> +++ b/net/sched/sch_api.c
> @@ -400,7 +400,7 @@ struct qdisc_rate_table *qdisc_get_rtab(struct tc_ratespec *r, struct nlattr *ta
>   	}
>
>   	rtab = kmalloc(sizeof(*rtab), GFP_KERNEL);
> -	if (rtab) {
> +	if (!rtab) {
>   		rtab->rate = *r;
>   		rtab->refcnt = 1;
>   		memcpy(rtab->data, nla_data(tab), 1024);
>

Did i miss something so clever it is not obvious? ;->
If rtab's kmalloc fails  you want to set rtab's fields?
And what is wrong with returning a null rtab again?

cheers,
jamal
