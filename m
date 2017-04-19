From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/2 v2] net sched actions: dump more than
 TCA_ACT_MAX_PRIO actions per batch
Date: Tue, 18 Apr 2017 18:49:05 -0700
Message-ID: <1492566545.10587.159.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1492564489-28854-1-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, jiri@resnulli.us,
        xiyou.wangcong@gmail.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:32841 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758851AbdDSBtI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2017 21:49:08 -0400
Received: by mail-pg0-f68.google.com with SMTP id 63so1663905pgh.0
        for <netdev@vger.kernel.org>; Tue, 18 Apr 2017 18:49:07 -0700 (PDT)
In-Reply-To: <1492564489-28854-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-04-18 at 21:14 -0400, Jamal Hadi Salim wrote:
> From: Jamal Hadi Salim <jhs@mojatatu.com>

So there is no more limit ? How user is supposed to size the buffer for
recvmsg() ?

>  	t->tca__pad1 = 0;
> @@ -1113,6 +1133,9 @@ static int tc_dump_action(struct sk_buff *skb, struct netlink_callback *cb)
>  	if (ret > 0) {
>  		nla_nest_end(skb, nest);
>  		ret = skb->len;
> +		if (nla_put_u32(skb, TCAA_ACT_COUNT, cb->args[1]))
> +			goto out_module_put;
> +		cb->args[1] = 0;


I really do not see how you manage to get room to add one additional
attribute, if dump had to stop at N actions, filling whole skb.

You might be lucky because nla_put_u32() wants a bit less space than an
action ?

Presumably you need to reserve space before the dump of actions.
