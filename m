From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v5 1/2] net sched actions: dump more than
 TCA_ACT_MAX_PRIO actions per batch
Date: Thu, 20 Apr 2017 09:09:58 -0700
Message-ID: <1492704598.22296.43.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1492693582-26810-1-git-send-email-jhs@emojatatu.com>
         <1492693582-26810-2-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jiri@resnulli.us, xiyou.wangcong@gmail.com,
        netdev@vger.kernel.org
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:33231 "EHLO
        mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754731AbdDTQKA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 12:10:00 -0400
Received: by mail-oi0-f66.google.com with SMTP id a189so11144236oib.0
        for <netdev@vger.kernel.org>; Thu, 20 Apr 2017 09:10:00 -0700 (PDT)
In-Reply-To: <1492693582-26810-2-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-04-20 at 09:06 -0400, Jamal Hadi Salim wrote:

>  	nest = nla_nest_start(skb, TCA_ACT_TAB);
>  	if (nest == NULL)
> @@ -1113,6 +1136,8 @@ static int tc_dump_action(struct sk_buff *skb, struct netlink_callback *cb)
>  	if (ret > 0) {
>  		nla_nest_end(skb, nest);
>  		ret = skb->len;
> +		memcpy(nla_data(count_attr), &cb->args[1], sizeof(u32));

This will not work on BigEndian 64bit hosts, since cb->args[1] is bigger
than 32bit.


> +		cb->args[1] = 0;
>  	} else
>  		nlmsg_trim(skb, b);
>  
