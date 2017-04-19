From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 2/2 v2] net sched actions: add time filter for
 action dumping
Date: Tue, 18 Apr 2017 18:35:38 -0700
Message-ID: <1492565738.10587.155.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1492564489-28854-1-git-send-email-jhs@emojatatu.com>
         <1492564489-28854-2-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, jiri@resnulli.us,
        xiyou.wangcong@gmail.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:35887 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758204AbdDSBfl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2017 21:35:41 -0400
Received: by mail-pg0-f66.google.com with SMTP id 34so1605808pgx.3
        for <netdev@vger.kernel.org>; Tue, 18 Apr 2017 18:35:41 -0700 (PDT)
In-Reply-To: <1492564489-28854-2-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-04-18 at 21:14 -0400, Jamal Hadi Salim wrote:
> From: Jamal Hadi Salim <jhs@mojatatu.com>
> 

> +	if (tcaa[TCAA_ACT_TIME_FILTER])
> +		msecs_filter = nla_get_u32(tcaa[TCAA_ACT_TIME_FILTER]);


You forgot to add TCAA_ACT_TIME_FILTER in tcaa_policy

There is no guarantee user passed 32bit data here.

> +
>  	nlh = nlmsg_put(skb, NETLINK_CB(cb->skb).portid, cb->nlh->nlmsg_seq,
>  			cb->nlh->nlmsg_type, sizeof(*t), 0);
>  	if (!nlh)
>  		goto out_module_put;
>  
> +	if (msecs_filter) {
> +		unsigned long jiffy_msecs = msecs_to_jiffies(msecs_filter);
> +		jiffy_wanted = jiffies - jiffy_msecs;
> +	}
> +
>  	cb->args[2] = act_flags;
> +	cb->args[3] = jiffy_wanted;
>  
>  	t = nlmsg_data(nlh);
>  	t->tca_family = AF_UNSPEC;
